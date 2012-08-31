#! /usr/bin/ruby

# MiniVM - Copyright (c) 2012, David H. Hovemeyer
# Free software - see LICENSE.txt for license terms

# MiniVM assembler

require 'BinaryFile.rb'
require 'ExeFile.rb'
require 'Opcode.rb'
require 'Syscall.rb'
require 'Constant.rb'

class Assembler
	def initialize(f)
		@f = f
		@exe = ExeFile.new()
		@labels = {}
	end

	def assemble
		_read_instructions()
		_resolve_labels()
		_build_constant_pool()
	end

	def get_exe
		return @exe
	end

	def _read_instructions
		index = 0
		
		@f.each_line do |line|
			line.strip!
			if line.empty?
				# blank line - ignore
			elsif m = line.match(/^;/)
				# comment - ignore
			elsif m = line.match(/^([A-Za-z_][A-Za-z_0-9]*)\s*:$/)
				#puts "Label: #{m[1]}"
				@labels[m[1]] = index
			else
				# see if line begins with known instruction mnemonic
				if m = line.match(/^([A-Za-z_][A-Za-z_0-9]*)(\s+(.*))?$/)
					# find Opcode based on the mnemonic
					sym = "i_#{m[1]}".to_sym()
					op = Opcode::BY_SYM[sym]
					raise "Unknown mnemonic #{m[1]}" if op.nil?
					#puts "Instruction: #{sym}"
		
					# Gather arguments
					if (m[2].nil?)
						args = []
					else
						args = _parse_args(m[2])
					end
		
					ins = Instruction.new(op)
					index += 1
		
					_handle_args(ins, args)
		
					@exe.get_instructions().push(ins)
				else
					raise "Syntax error: #{line}"
				end
			end
		end
	end

	def _parse_args(argstr)
		args = []

		argstr.lstrip!()

		while true
			# Skip leading whitespace
			return args if (argstr.strip().empty?)

			if m = argstr.match(/^([0-9]+)(.*)$/)
				# integer literal
				args.push(m[1].to_i)
				argstr = m[2]
			elsif m = argstr.match(/^("(\\.|[^"])*")(.*)$/)
				# string constant
				args.push(_handle_escapes(m[1].slice(1, m[1].length - 2)))
				argstr = m[3]
			elsif m = argstr.match(/^(\$[a-z]+)(.*)$/)
				# syscall name
				args.push(m[1])
				argstr = m[2]
			elsif m = argstr.match(/^([A-Za-z_][A-Za-z_]*)(.*)$/)
				# Identifier (e.g., target label)
				args.push(m[1])
				argstr = m[2]
			else
				raise "Unrecognized argument: #{argstr}"
			end

			argstr.lstrip!()

			if !argstr.empty?
				# Consume the comma separating the arguments
				raise "Arguments must be separated by commas: #{argstr}" if !(m = argstr.match(/^,(.*)$/))
				argstr = m[1]
				argstr.lstrip!()
			end
		end
	end

	@@escapes = {
		'n' => "\n",
		't' => "\t",
		'r' => "\r",
		'b' => "\b",
		'f' => "\f",
		'\\' => "\\",
	}

	def _handle_escapes(s)
		result = ''
		state = :scan
		s.each_char do |c|
			#puts "#{c}"
			case state
			when :scan
				if c == '\\'
					state = :escape
				else
					result << c
				end
			when :escape
				ch = @@escapes[c]
				raise "Unknown escape sequence: \\#{c}" if ch.nil?
				result << ch
				state = :scan
			end
		end
		return result
	end

	def _handle_args(ins, args)
		#puts "args: #{args.join(',')}"
		op = ins.get_op()
		nparms = op.get_fields().length
		#puts "#{op.get_sym()}: fields=#{op.get_fields()}"

		unless args.length == nparms
			raise "Wrong number of args for #{ins.get_op().get_sym()} (got #{args.length}, expected #{nparms})"
		end
	
		op = ins.get_op()
		
		(0 .. nparms-1).each do |i|
			field = op.get_fields()[i]
			fieldname = op.get_fieldnames()[i]
	
			case fieldname
			when :iconst, :nargs, :nclear, :nlocals, :index
				ins.set_prop(fieldname, args[i].to_i())
			when :strconst
				# For now, set the string constant in the Instruction object.
				# When we build the constant pool, we'll replace it with its
				# constant pool entry.
				ins.set_prop(:strconst_val, args[i])
			when :addr
				# For now, store the label name.
				# When we resolve jumps, we'll replace it with the
				# actual target address.
				ins.set_prop(:target_label, args[i])
			when :syscall
				syscall = Syscall::BY_NAME[args[i]]
				raise "Unknown syscall: #{args[i]}" if syscall.nil?
				ins.set_prop(:syscall, syscall.get_syscall_num())
			else
				raise "Don't know how to handle #{fieldname} arg"
			end
		end
	end

	def _resolve_labels
		@exe.get_instructions().each do |ins|
			target_label = ins.get_prop(:target_label)
			if !target_label.nil?
				target_addr = @labels[target_label]
				raise "Label #{target_label} is not defined" if target_addr.nil?
				ins.set_prop(:addr, target_addr)
			end
		end
	end

	def _build_constant_pool
		pool = {}
		@exe.get_instructions().each do |ins|
			# Right now we only have string constants in the constant pool
			if val = ins.get_prop(:strconst_val)
				index = pool[val]
				if index.nil?
					const = Constant.new(:str, val)
					index = @exe.get_constants().length
					@exe.get_constants().push(const)
					pool[val] = index
				end
				ins.set_prop(:strconst, index)
			end
		end
	end
end

raise "Usage: Assembler.rb <asmfile> <outfile>" unless ARGV.length == 2

f = File.open(ARGV[0])

a = Assembler.new(f)
a.assemble()
f.close()

exe = a.get_exe()

outf = File.open(ARGV[1], 'w')
outf.extend(BinaryFile)
ExeFile.write(outf, exe)
outf.close()

# vim: tabstop=4
