#! /usr/bin/ruby

# MiniVM - Copyright (c) 2012, David H. Hovemeyer
# Free software - see LICENSE.txt for license terms

require 'BinaryFile.rb'
require 'ExeFile.rb'
require 'VirtualMachine.rb'
require 'optparse'

interactive = false
optparse = OptionParser.new do |opts|
	opts.banner =  "Usage: Execute.rb [options] <exefile>"

	opts.on('-i', '--interactive', 'run program interactively') do
		interactive = true
	end
end

optparse.parse!
if ARGV.length != 1
	puts optparse
	exit 1
end

# Read the executable file (instructions and constant data)
f = File.open(ARGV[0])
f.extend(BinaryFile)
exe = ExeFile.read(f)
#puts "Read #{exe.get_instructions().length} instructions"

# Interpret the instructions in the executable
vm = VirtualMachine.new(exe)

if interactive
	def vm.print_state
		system("clear")

		# Print assembly instructions (w/ current highlighted)
		pc = get_pc()
		addr = 0
		get_exe().get_instructions().each do |ins|
			print (addr == pc) ? "==> " : "    ";
			print "%03d " % addr
			puts ins.get_prop(:source)
			addr += 1
		end
		puts ""

		# Print stack
		opstack = get_opstack()
		(1 .. opstack.length).each do |i|
			val = opstack[opstack.length - i]
			puts val
		end
	end
end

while !vm.halted?
	if interactive
		vm.print_state() 
		STDIN.gets
	end
	vm.stepi()
end

# vim: tabstop=4
