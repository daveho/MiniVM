#! /usr/bin/ruby

# Weave together all of the MiniVM classes and the driver program
# into a single file.

# Find the immediate dependencies of given source file
def find_immediate_deps(src)
	result = []
	File.open(src) do |f|
		f.each_line do |line|
			if m = /^require '(.*)'/.match(line)
				dep = "#{m[1]}.rb"
				if FileTest.exist?(dep)
					result.push(dep)
				end
			end
		end
	end
	return result
end

# Print a line of Ruby source code (if it is not a comment)
def print_line(line)
	line = line.gsub("\t", '  ')
	puts line if !/^\s*#/.match(line)
end

# "Spew" a Ruby file containing a single class
def spew(src)
	File.open(src) do |f|
		mode = :start
		f.each_line do |line|
			case mode
			when :start
				if /^class/.match(line)
					print_line(line)
					mode = :go
				end
			when :go
				print_line(line)
				mode = :done if /^end/.match(line)
			end
		end
	end
end

# Find transitive dependencies of MiniVM.rb
work = ['MiniVM.rb']
known = {}
alldeps = []
while !work.empty?
	src = work.shift
	deps = find_immediate_deps(src)
	deps.each do |dep|
		if !known.has_key?(dep)
			work.push(dep)
			known[dep] = 1
			alldeps.push(dep)
		end
	end
end

print <<"EOF";
#! /usr/bin/ruby

require 'optparse'

EOF

alldeps.reverse.each do |dep|
	spew(dep)
	puts ""
end

File.open('MiniVM.rb') do |f|
	mode = :start
	f.each_line do |line|
		case mode
		when :start
			if /^mode =/.match(line)
				print_line(line)
				mode = :go
			end
		when :go
			print_line(line)
		end
	end
end

# vim:ts=4:
