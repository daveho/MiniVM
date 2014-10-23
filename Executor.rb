# MiniVM - Copyright (c) 2012-2014 David H. Hovemeyer
# Free software - see LICENSE.txt for license terms

require 'BinaryFile'
require 'ExeFile'
require 'VirtualMachine'

class Executor
	attr_accessor :interactive
	attr_reader :output

	def initialize(exe)
		@exe = exe
		@vm = VirtualMachine.new(exe)
		@interactive = false
		@output = []
	end

	def execute
		# Interpret the instructions in the executable
		if @interactive
			def @vm.padfixed(str, width)
				str = str.to_s
				str = str.gsub("\n", '\n')
				if str.length >= 30
					str = "#{str.slice(0, 27)}..."
				end
				return "#{str}#{' ' * (30-str.length)}"
			end

			def @vm.print_state(executor)
				system("clear")
		
				# Print assembly instructions (w/ current highlighted)
				addr = 0
				exe.instructions.each do |ins|
					print (addr == pc) ? "==> " : "    ";
					print "%03d " % addr
					puts ins.get_prop(:source)
					addr += 1
				end

				# If the instruction printed output, add it to accumulated output
				executor.output.push(printed) if !printed.nil?

				# See if there is a top frame
				topframe = framestack.last
		
				# Print stack and output
				puts ''
				pstack = ['Current stack:']
				(1 .. opstack.length).each do |i|
					index = opstack.length - i
					val = opstack[index]
					if !topframe.nil? and index >= topframe.base
						# This slot is part of the top stack frame,
						# so mark it.
						pstack.push("| #{val}")
					else
						pstack.push("  #{val}")
					end
				end
				pout = ['Output:']
				pout.concat(executor.output)
				done = false
				while !done
					if pstack.empty? and pout.empty?
						done = true
					else
						left = pstack.shift or ''
						right = pout.shift or ''
						printf("%s  %s\n", padfixed(left, 30), padfixed(right, 40))
					end
				end
			end
		end
		
		while !@vm.halted?
			if @interactive
				@vm.print_state(self)
				STDIN.gets
			end
			@vm.stepi()
		end
	end
end
	
# vim: tabstop=4
