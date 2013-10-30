# MiniVM - Copyright (c) 2012,2013 David H. Hovemeyer
# Free software - see LICENSE.txt for license terms

# MiniVM executable file

require 'Instruction'
require 'Constant'

# An ExeFile object represents a complete decoded MiniVM executable.
class ExeFile
	attr_reader :instructions, :constants

	MAGIC = 0xf00ba555

	def initialize
		@instructions = []
		@constants = []
	end

	def self.read(f)
		exe = ExeFile.new()

		# Check magic number
		raise "Bad magic number" if f.read_int_unsigned() != MAGIC

		# Determine number of instructions, constants, and source lines
		nins = f.read_int()
		nconst = f.read_int()

		# Read all instructions and constants
		(1..nins).each {|i| exe.instructions.push(Instruction.read(f)) }
		(1..nconst).each {|i| exe.constants.push(Constant.read(f)) }
		exe.instructions.each do |ins|
			line = f.read_str()
			ins.set_prop(:source, line)
		end

		return exe
	end

	def self.write(f, exe)
		f.write_int(MAGIC)
		f.write_int(exe.instructions.length)
		f.write_int(exe.constants.length)
		exe.instructions.each {|ins| Instruction.write(f, ins) }
		exe.constants.each {|const| Constant.write(f, const) }
		exe.instructions.each {|ins| f.write_str(ins.get_prop(:source)) }
	end
end

# vim: tabstop=4
