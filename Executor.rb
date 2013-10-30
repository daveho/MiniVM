# MiniVM - Copyright (c) 2012,2013 David H. Hovemeyer
# Free software - see LICENSE.txt for license terms

require 'BinaryFile'
require 'ExeFile'
require 'VirtualMachine'

class Executor
	attr_accessor :interactive

	def initialize(exe)
		@exe = exe
		@vm = VirtualMachine.new(exe)
		@interactive = false
	end

	def execute
		# Interpret the instructions in the executable
		if @interactive
			def @vm.print_state
				system("clear")
		
				# Print assembly instructions (w/ current highlighted)
				addr = 0
				exe.instructions.each do |ins|
					print (addr == pc) ? "==> " : "    ";
					print "%03d " % addr
					puts ins.get_prop(:source)
					addr += 1
				end
				puts ""
		
				# Print stack
				(1 .. opstack.length).each do |i|
					val = opstack[opstack.length - i]
					puts val
				end
			end
		end
		
		while !@vm.halted?
			if @interactive
				@vm.print_state() 
				STDIN.gets
			end
			@vm.stepi()
		end
	end
end
	
# vim: tabstop=4
