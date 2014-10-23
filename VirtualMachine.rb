# MiniVM - Copyright (c) 2012-2014 David H. Hovemeyer
# Free software - see LICENSE.txt for license terms

require 'Syscall'

# A VirtualMachine object executes the instructions in an ExeFile
class VirtualMachine
	class Frame
		# Allow access to the base index
		attr_accessor :base

		def initialize(nargs, nlocals)
			@nargs, @nlocals = nargs, nlocals
		end

		def get_arg(opstack, index)
			raise "Invalid argument index #{index} (frame has #{@nargs} args)" if !(0..@nargs-1).include?(index)
			return opstack[@base + index]
		end

		def get_local(opstack, index)
			raise "Invalid argument index #{index} (frame has #{@nlocals} locals)" if !(0..@nlocals-1).include?(index)
			return opstack[@base + @nargs + 1 + index]
		end

		def set_local(opstack, index, val)
			raise "Invalid argument index #{index} (frame has #{@nlocals} locals)" if !(0..@nlocals-1).include?(index)
			opstack[@base + @nargs + 1 + index] = val
		end

		def enter(opstack)
			# @base is the index of the first argument (if any)
			@base = opstack.length - @nargs - 1

			raise "Frame base index is negative!" if @base < 0

			# Push 0 values for uninitialized locals
			(1 .. @nlocals).each do |i|
				opstack.push(0)
			end
		end

		def leave(opstack)
			# The procedure should have left a single value on the
			# opstack (past the args, return address, and locals)
			expected = @base + @nargs + @nlocals + 2
			if opstack.length != expected
				#puts "base is #{@base}"
				#opstack.dump()
				raise "Returning from procedure: operand stack wrong size (is #{opstack.length}, expected #{expected})"
			end
			retval = opstack.pop()

			# pop off locals
			opstack.popn(@nlocals)

			# pop off return address
			retaddr = opstack.pop()

			# pop off arguments
			opstack.popn(@nargs)

			# push the return value on the calling frame's opstack
			opstack.push(retval)

			return retaddr
		end
	end

	attr_reader :exe, :pc, :opstack, :framestack
	attr_accessor :printed

	def initialize(exe)
		@exe = exe
		@opstack = []
		def @opstack.popn(nclear)
			(1 .. nclear).each {|i| pop() }
		end
#		def @opstack.dump
#			puts ">>> DUMP <<<"
#			(1 .. length()).each do |i|
#				puts "  #{self[length() - i]}"
#			end
#		end
		@framestack = []
		@pc = 0
		@halted = false

		# Push a dummy return address for the entry point procedure
		@opstack.push(-1)
	end

	@@opcode_to_arith_method = {
		:i_add => :+,
		:i_sub => :-,
		:i_mul => :*,
		:i_div => :/,
		:i_exp => :**,
	}

	@@check_comparison_result = {
		:i_je => lambda {|res| res == 0 },
		:i_jne => lambda {|res| res != 0 },
		:i_jlt => lambda {|res| res < 0 },
		:i_jgt => lambda {|res| res > 0 },
		:i_jlte => lambda {|res| res <= 0 },
		:i_jgte => lambda {|res| res >= 0 },
	}

	# Execute one instruction
	def stepi
		@printed = nil

		ins = @exe.instructions[@pc]
		raise "No instruction at pc=#{@pc}" if ins.nil?

		nextpc = @pc + 1

		opc = ins.op.sym

		case opc
		when :i_nop
			# do nothing
		when :i_ldc_i
			@opstack.push(ins.get_prop(:iconst))
		when :i_ldc_str
			index = ins.get_prop(:strconst)
			const = @exe.constants[index]
			raise "Reference to nonexistent constant #{index}" if const.nil?
			@opstack.push(const.value)
		when :i_add, :i_sub, :i_mul, :i_div, :i_exp
			rhs = @opstack.pop()
			lhs = @opstack.pop()
			result = lhs.send(@@opcode_to_arith_method[opc], rhs)
			@opstack.push(result)
		when :i_cmp
			rhs = @opstack.pop()
			lhs = @opstack.pop()
			@opstack.push(lhs <=> rhs)
		when :i_je, :i_jne, :i_jlt, :i_jgt, :i_jlte, :i_jgte
			res = @opstack.pop()
			if @@check_comparison_result[opc].call(res)
				nextpc = ins.get_prop(:addr)
			end
		when :i_jmp
			nextpc = ins.get_prop(:addr)
		when :i_call
			# Push the return address
			@opstack.push(@pc + 1)

			# Jump to the procedure address.
			# The first instruction in the procedure should be enter,
			# which will create the procedure's stack frame.
			nextpc = ins.get_prop(:addr)
		when :i_syscall
			num = ins.get_prop(:syscall)
			sys = Syscall::ALL[num]
			raise "Unknown syscall #{num}" if sys.nil?
			# Gather args
			args = []
			(1 .. sys.nparms).each do |i|
				args.unshift(@opstack.pop())
			end
			result = sys.execute.call(args, self)
			@opstack.push(result)
		when :i_pop
			@opstack.pop()
		when :i_popn
			(1 .. ins.get_prop(:nclear)).each do |i|
				@opstack.pop()
			end
		when :i_enter
			frame = Frame.new(ins.get_prop(:nargs), ins.get_prop(:nlocals))
			@framestack.push(frame)
			frame.enter(@opstack)
		when :i_ret
			frame = @framestack.pop()
			raise "Returning from nonexistent procedure at pc=#{@pc}" if frame.nil?
			nextpc = frame.leave(@opstack)
			@halted = @framestack.empty?
		when :i_ldarg
			_with_index(ins) do |frame, index|
				@opstack.push(frame.get_arg(@opstack, index))
			end
		when :i_ldlocal
			_with_index(ins) do |frame, index|
				@opstack.push(frame.get_local(@opstack, index))
			end
		when :i_stlocal
			_with_index(ins) do |frame, index|
				frame.set_local(@opstack, index, @opstack.pop())
			end
		when :i_dup
			top = @opstack[-1]
			@opstack.push(top)
		else
			raise "Unknown opcode: #{op}"
		end

		@pc = nextpc
	end

	def _with_index(ins)
		frame = @framestack.last()
		raise "No stack frame!" if frame.nil?
		index = ins.get_prop(:index)
		yield frame, index
	end

	# Returns true if the virtual machine has halted
	def halted?
		return @halted
	end
end

# vim: tabstop=4
