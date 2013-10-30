# MiniVM - Copyright (c) 2012,2013 David H. Hovemeyer
# Free software - see LICENSE.txt for license terms

# MiniVM opcodes

# An Opcode is a template for an instruction.
# It defines the encoding and meaning of the instruction
# within a binary executable file.
class Opcode
	attr_reader :num, :sym, :fields, :fieldnames

	def initialize(sym, *more)
		@sym = sym
		fields, fieldnames = more
		@fields = fields.nil? ? '' : fields
		@fieldnames = fieldnames.nil? ? [] : fieldnames
	end

	def _set_num(num)
		@num = num
	end

	# Array of all opcodes, indexed by opcode number
	ALL = [
		Opcode.new(:i_nop),
		Opcode.new(:i_ldc_i, 'N', [:iconst]),
		Opcode.new(:i_ldc_str, 'N', [:strconst]),
		Opcode.new(:i_add),
		Opcode.new(:i_sub),
		Opcode.new(:i_mul),
		Opcode.new(:i_div),
		Opcode.new(:i_cmp),
		Opcode.new(:i_je, 'N', [:addr]),
		Opcode.new(:i_jne, 'N', [:addr]),
		Opcode.new(:i_jlt, 'N', [:addr]),
		Opcode.new(:i_jgt, 'N', [:addr]),
		Opcode.new(:i_jlte, 'N', [:addr]),
		Opcode.new(:i_jgte, 'N', [:addr]),
		Opcode.new(:i_jmp, 'N', [:addr]),
		Opcode.new(:i_call, 'N', [:addr]),
		Opcode.new(:i_syscall, 'N', [:syscall]),
		Opcode.new(:i_pop),
		Opcode.new(:i_popn, 'N', [:nclear]),
		Opcode.new(:i_enter, 'NN', [:nargs, :nlocals]),
		Opcode.new(:i_ret),
		Opcode.new(:i_ldarg, 'N', [:index]),
		Opcode.new(:i_ldlocal, 'N', [:index]),
		Opcode.new(:i_stlocal, 'N', [:index]),
		Opcode.new(:i_exp),
		Opcode.new(:i_dup),
	]

	# Set opcode numbers
	ALL.each_index {|i| ALL[i]._set_num(i) }

	# Index of opcodes by symbol
	BY_SYM = Hash[ ALL.map {|op| [op.sym, op] } ]
end

# vim: tabstop=4
