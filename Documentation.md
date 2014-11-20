# MiniVM - Documentation

This document describes how MiniVM works.

## Data Types

There are two datatypes in MiniVM: integers and strings.
Each value in a MiniVM program belongs to one of these types.

## The Operand Stack

MiniVM is a stack-based virtual machine.  The *operand stack*
is the stack of values available to MiniVM instructions.

We will visualize the operand stack as growing up as new
values are pushed onto the stack.
Here is an empty operand stack

	|            | 0
	+------------+

Here is an operand stack after the values -1, "Hello", 42, and 11
have been pushed on the stack (in that order):

	| 11         | 3
	| 42         | 2
	| "Hello"    | 1
	| -1         | 0
	+------------+

Let's consider what would happen if the `sub` instruction were executed
with this operand stack. The `sub` instruction pops off two integer
operands, computes the difference, and pushes the difference.
The right operand is popped first, then the left operand:

1. pop -> 11
2. pop -> 42
3. compute difference (42 - 11 = 31)
4. push difference (31)

So, after the `sub` instruction executes, the operand stack looks
like this:

	| 31         | 2
	| "Hello"    | 1
	| -1         | 0
	+------------+

## Procedures

MiniVM supports procedures.  To call a procedure, the MiniVM program
pushes arguments onto the operand stack, and then executes the
`call` instruction with the address of the procedure.
When the procedure returns, the result of the procedure will be
left on the operand stack, in place of the arguments.

In the following example, the `main` procedure calls a procedure called
`add_and_negate`, which takes two integer parameters and returns their
sum negated (multiplied by -1):

	main:
		enter 0, 0
		ldc_i 2             ; push first argument
		ldc_i 3             ; push second argument
		call add_and_negate ; call procedure
		syscall $println    ; print the result of the procedure
		ret
	
	add_and_negate:
		enter 2, 0
		ldarg 0
		ldarg 1
		add
		ldc_i -1
		mul         
		ret

Here is the stack just before the `call` instruction is executed:

	| 3          | 2
	| 2          | 1
	| -1         | 0
	+------------+

Here is the stack just after the `call` instruction is executed
(following the return from the called procedure):

	| -5         | 1
	| -1         | 0
	+------------+

## Stack Frames

Each procedure has a *stack frame* which
keeps track of the locations of the procedure's arguments, return address,
and local variables on the operand stack.

The `enter` instruction creates a stack frame.  It should always
be the first instruction executed by a procedure.
It takes two integer values, *nargs* and *nlocals*.
*nargs* specifies how many arguments the procedure expects to receive.
*nlocals* specifies how many local variables the procedure will use.

Let's look in more detail at what happens when the
`add_and_negate` procedure in the program above is called.
Here is the code again:

	add_and_negate:
		enter 2, 0
		ldarg 0
		ldarg 1
		add
		ldc_i -1
		mul         
		ret

A `call` instruction does two things:

1. It pushes the return address, which is the address of the instruction
   following the `call` instruction, onto the operand stack
2. It transfers control to the first instruction in the called
   procedure

So, at the point that the first instruction (`enter 2, 0`) in the
`add_and_negate` procedure is reached, the operand stack looks like
this:

	| <retaddr>  | 3
	| 3          | 2
	| 2          | 1
	| -1         | 0
	+------------+

`<retaddr>` is the return address of the instruction following
the `call` instruction (`syscall $println`): it is the code address to which control
will return when the procedure returns.

The `enter 2, 0` instruction at the beginning of the `add_and_negate`
procedure creates a stack frame with 2 arguments and 0 local variables.
(`add_and_negate` does its computation entirely on the operand stack,
so no local variables are needed.) So, after
this instruction, the operand stack looks like this:

	| <retaddr>  | 3   \  [top of stack frame]
	| 3          | 2   |  The stack frame
	| 2          | 1   /  [base of stack frame]
	| -1         | 0
	+------------+

So, the stack frame consists of the operands at locations 1..3 on the
operand stack.  There are two arguments (at locations 1 and 2) and no local variables.
The purpose of the stack frame is to allow the procedure
to refer easily to its arguments and local variables, since they are all
at fixed positions relative to the location of the stack frame.

Once a stack frame has been created, the procedure can push
more values on top of the operand stack.  When a procedure
is finished, it should leave a single return value on the
operand stack, just past the top of the stack frame.  So, just before the
`add_and_negate` procedure returns, its operand stack will look
like this:

	| -5         | 4      <== return value of procedure
	| <retaddr>  | 3   \  [top of stack frame]
	| 3          | 2   |  The stack frame
	| 2          | 1   /  [base of stack frame]
	| -1         | 0
	+------------+

The `ret` instruction returns from a procedure, removing the current
stack frame and returning to the previous stack frame.
The procedure return value and the entire contents of the stack
frame are cleared from the stack, and the procedure's return
value is pushed onto the stack.  So, following the `ret`
instruction, the operand stack looks like this:

	| -5         | 1     <== return value is copied here
	| -1         | 0
	+------------+

Note that every procedure must return a value.
