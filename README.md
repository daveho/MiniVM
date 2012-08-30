MiniVM - A Really Simple Virtual Machine
========================================

This is a really simple stack-based virtual machine written in Ruby.

It exists mainly because I wanted to learn more about Ruby.

I'm also thinking it might be a useful way to demonstrate programming
language concepts, such as how to translate an expression into
a sequence of instructions to evaluate the instruction.

Usage
=====

To assemble a MiniVM assembly language program into an executable:

	./Assembler.rb asmfile exefile

To execute an executable file generated by the assembler:

	./Execute.rb exefile

For example, to try the hello world program:

	./Assembler.rb t/hello.mvm hello.out
	./Execute.rb hello.out

Technical Details
=================

Details of the assembly language can be learned by looking at the
programs in the `t` directory.

TODO: discuss internals.

Limitations
===========

There are probably lots of bugs.

Procedure calls don't work yet.

Local variables in procedures are supported in theory, but at the moment
there are no instructions which can access them.

The diagnostics when error conditions are encountered are inadequate.

More error checking is needed.

License
=======

MIT license (see LICENSE.txt).

Contact
=======

<david.hovemeyer@gmail.com>