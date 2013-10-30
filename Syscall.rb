# MiniVM - Copyright (c) 2012, David H. Hovemeyer
# Free software - see LICENSE.txt for license terms

# MiniVM syscalls

class Syscall
	attr_reader :name, :syscall_num, :nparms, :execute

	def initialize(name, syscall_num, nparms, execute)
		@name = name
		@syscall_num = syscall_num
		@nparms = nparms
		@execute = execute
	end

	ALL = [
		Syscall.new('$print', 0, 1, lambda {|args, vm| print args[0]; vm.printed = args[0]; 0 }),
		Syscall.new('$println', 1, 1, lambda {|args, vm| puts args[0]; vm.printed = args[0]; 0 }),
	]

	BY_NAME = Hash[ ALL.map {|syscall| [syscall.name, syscall] } ]
end

# vim: tabstop=4
