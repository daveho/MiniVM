#! /usr/bin/ruby

# MiniVM - Copyright (c) 2012, David H. Hovemeyer
# Free software - see LICENSE.txt for license terms

require 'BinaryFile.rb'
require 'ExeFile.rb'
require 'VirtualMachine.rb'

raise "Usage: Execute.rb <exefile>" unless ARGV.length == 1

# Read the executable file (instructions and constant data)
f = File.open(ARGV[0])
f.extend(BinaryFile)
exe = ExeFile.read(f)
#puts "Read #{exe.get_instructions().length} instructions"

# Interpret the instructions in the executable
vm = VirtualMachine.new(exe)

while !vm.halted?
	vm.stepi()
end

# vim: tabstop=4
