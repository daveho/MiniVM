# MiniVM - Copyright (c) 2012,2013 David H. Hovemeyer
# Free software - see LICENSE.txt for license terms

# MiniVM instruction class

require 'Opcode'

# An Instruction is the decoded form of an instruction
# read from an executable file.
class Instruction
	attr_reader :op

	def initialize(op)
		@op = op
		@props = {}
	end

	def set_prop(prop, value)
		@props[prop] = value
	end

	def get_prop(prop)
		return @props[prop]
	end

	@@field_readers = {
		'C' => lambda {|f| return f.read_byte() },
		'N' => lambda {|f| return f.read_int() },
		's' => lambda {|f| return f.read_str() },
	}

	# Read a single Instruction from a binary file
	# (an input file with the BinaryFile mixin)
	def self.read(f)
		opcode_num = f.read_byte()
		raise "Failed to read opcode" if opcode_num.nil?

		op = Opcode::ALL[opcode_num]
		raise "Unknown opcode #{opcode_num}" if op.nil?

		ins = Instruction.new(op)

		fields = op.fields
		fieldnames = op.fieldnames

		fieldnames.each_index do |i|
			# Note weirdness:
			#   str[i] yields the CHARACTER CODE of the character at index i,
			#   not a string containing just that character.
			#   str[i,i+1] works, however.
			val = @@field_readers[fields[i,i+1]].call(f)
			ins.set_prop(fieldnames[i], val)
		end

		return ins
	end

	def self.write(f, ins)
		f.write_byte(ins.op.num)

		fieldnames = ins.op.fieldnames

		fieldnames.each do |fieldname|
			case fieldname
			when :iconst, :strconst, :addr, :nargs, :syscall, :nclear, :nlocals, :index
				# Right now, every field value is an integer
				val = ins.get_prop(fieldname)
				raise "No value set for #{fieldname} property in #{ins.op.get_sym()} instruction" if val.nil?
				f.write_int(val)
			else
				raise "Don't know how to write a #{fieldname} field"
			end
		end
	end
end

# vim: tabstop=4
