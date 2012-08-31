# MiniVM - Copyright (c) 2012, David H. Hovemeyer
# Free software - see LICENSE.txt for license terms

# MiniVM executable file

require 'Instruction.rb'
require 'Constant.rb'

# An ExeFile object represents a complete decoded MiniVM executable.
class ExeFile
	MAGIC = 0xf00ba550

	def initialize
		@instructions = []
		@constants = []
	end

	def get_instructions
		return @instructions
	end

	def get_constants
		return @constants
	end

	def self.read(f)
		exe = ExeFile.new()

		# Check magic number
		raise "Bad magic number" if f.read_int_unsigned() != MAGIC

		# Determine number of instructions and constants
		nins = f.read_int()
		nconst = f.read_int()

		# Read all instructions and constants
		(1..nins).each {|i| exe.get_instructions().push(Instruction.read(f)) }
		(1..nconst).each {|i| exe.get_constants().push(Constant.read(f)) }

		return exe
	end

	def self.write(f, exe)
		f.write_int(MAGIC)
		f.write_int(exe.get_instructions().length)
		f.write_int(exe.get_constants().length)
		exe.get_instructions().each {|ins| Instruction.write(f, ins) }
		exe.get_constants().each {|const| Constant.write(f, const) }
	end
end

# vim: tabstop=4
