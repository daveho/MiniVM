# MiniVM - Copyright (c) 2012, David H. Hovemeyer
# Free software - see LICENSE.txt for license terms

# A mixin for reading and writing binary data from/to a file.
# Can be used to extend an object supporting the standard
# file I/O methods.

module BinaryFile
	def read_byte
		return read(1).unpack("C")[0]
	end

	def read_int
		return read(4).unpack("N")[0]
	end

	def read_short
		return read(2).unpack("n")[0]
	end

	def read_str
		# FIXME: fails for multi-byte character sets
		len = read_int()
		return read(len)
	end

	def write_byte(b)
		write([b].pack("C"))
	end

	def write_int(i)
		write([i].pack("N"))
	end

	def write_str(s)
		# FIXME: fails for multi-byte character sets
		write_int(s.length)
		write(s)
	end
end

# vim: tabstop=4
