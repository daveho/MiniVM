# MiniVM - Copyright (c) 2012, David H. Hovemeyer
# Free software - see LICENSE.txt for license terms

require 'Syscall.rb'

# A VirtualMachine object executes the instructions in an ExeFile
class VirtualMachine
	class Frame
		def initialize(nargs, nlocals)
			@nargs, @nlocals = nargs, nlocals
		end

		def get_base
			return @base
		end

		def get_nargs
			return @nargs
		end

		def get_nlocals
			return @nlocals
		end

		def enter(opstack)
			# @base is the index of the first argument (if any)
			@base = opstack.length - @nargs

			raise "Frame base index is negative!" if @base < 0

			# Push 0 values for uninitialized locals
			(1 .. @nlocals).each do |i|
				opstack.push(0)
			end
		end

		def leave(opstack)
			# The procedure should have left a single value on the
			# opstack (past the args and locals)
			expected = @base + @nargs + @nlocals + 1
			if opstack.length != expected
				raise "Returning from procedure: operand stack wrong size (is #{opstack.length}, expected #{expected})"
			end
			retval = opstack.pop()

			# pop off locals and args
			(1 .. @nlocals+@nargs).each do |i|
				opstack.pop()
			end

			# push the return value on the calling frame's opstack
			opstack.push(retval)
		end
	end

	def initialize(exe)
		@exe = exe
		@opstack = []
		@framestack = []
		@pc = 0
		@halted = false
	end

	@@opcode_to_arith_method = {
		:i_add => :+,
		:i_sub => :-,
		:i_mul => :*,
		:i_div => :/,
	}

	@@check_comparison_result = {
		:i_je => lambda {|res| res == 0 },
		:i_jne => lambda {|res| res != 0 },
		:i_jlt => lambda {|res| res < 0 },
		:i_glt => lambda {|res| res > 0 },
		:i_jlte => lambda {|res| res <= 0 },
		:i_jgte => lambda {|res| res >= 0 },
	}

	# Execute one instruction
	def stepi
		ins = @exe.get_instructions()[@pc]
		raise "No instruction at pc=#{@pc}" if ins.nil?

		nextpc = @pc + 1

		opc = ins.get_op().get_sym()

		case opc
		when :i_nop
			# do nothing
		when :i_ldc_i
			@opstack.push(ins.get_prop(:iconst))
		when :i_ldc_str
			index = ins.get_prop(:strconst)
			const = @exe.get_constants()[index]
			raise "Reference to nonexistent constant #{index}" if const.nil?
			@opstack.push(const.get_value())
		when :i_add, :i_sub, :i_mul, :i_div
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
		when :i_syscall
			num = ins.get_prop(:syscall)
			sys = Syscall::ALL[num]
			raise "Unknown syscall #{num}" if sys.nil?
			# Gather args
			args = []
			(1 .. sys.get_nparms()).each do |i|
				args.unshift(@opstack.pop())
			end
			result = sys.get_execute().call(args)
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
			frame.leave(@opstack)
			@halted = @framestack.empty?
		end

		@pc = nextpc
	end

	# Returns true if the virtual machine has halted
	def halted?
		return @halted
	end
end

# vim: tabstop=4
