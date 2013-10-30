# MiniVM - Copyright (c) 2012,2013 David H. Hovemeyer
# Free software - see LICENSE.txt for license terms

# MiniVM constant pool entry

class Constant
	attr_reader :kind, :value

	def initialize(kind, value)
		@kind = kind
		@value = value
	end

	@@num_to_kind = {
		0 => :str,
	}

	def self.read(f)
		n = f.read_int()
		kind = @@num_to_kind[n]

		raise "Unknown constant type #{n}" if kind.nil?

		case kind
		when :str
			return Constant.new(:str, f.read_str())
		else
			raise "Don't know how to read a #{kind} constant"
		end
	end

	@@kind_to_num = @@num_to_kind.invert()

	def self.write(f, const)
		kind = const.kind
		num = @@kind_to_num[kind]
		raise "Unknown constant type number for #{kind} constant" if num.nil?
		f.write_int(num)

		case kind
		when :str
			f.write_str(const.value)
		else
			raise "Don't know how to write a #{kind} constant"
		end
	end
end

# vim: tabstop=4
