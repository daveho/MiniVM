# MiniVM - Copyright (c) 2012, David H. Hovemeyer
# Free software - see LICENSE.txt for license terms

# MiniVM syscalls

class Syscall
	def initialize(name, syscall_num, nparms, execute)
		@name = name
		@syscall_num = syscall_num
		@nparms = nparms
		@execute = execute
	end

	def get_name
		return @name
	end

	def get_syscall_num
		return @syscall_num
	end

	def get_nparms
		return @nparms
	end

	def get_execute
		return @execute
	end

	ALL = [
		Syscall.new('$print', 0, 1, lambda {|args| puts args[0]; 0 }),
	]

	BY_NAME = Hash[ ALL.map {|syscall| [syscall.get_name(), syscall] } ]
end

# vim: tabstop=4
