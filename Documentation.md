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

Here is an operand stack after the values "Hello", 42, and 11
have been pushed on the stack:

	| 11         | 2
	| 42         | 1
	| "Hello"    | 0
	+------------+

Let's consider what would happen if the `sub` instruction were executed
with this operand stack. The `sub` instruction pops off two integer
operands, computes the difference, and pushes the difference.
The right operand is popped first, then the left operand:

1. pop -> 11
2. pop -> 42
3. compute difference (42 - 11 = 31)
4. push difference (31)

So, after the `add` instruction executes, the operand stack looks
like this:

	| 31         | 1
	| "Hello"    | 0
	+------------+

## Stack Frames
