# MiniVM - Instruction Set

This document describes the MiniVM instruction set.

Instructions are documented in the following form:

> mnemonic *arg* *arg* | behavior | what result is pushed

## Data types

*integerConstant* is just an integer constant, e.g., `42`.

*stringConstant* is a double-quoted string literal, e.g., `"Hello, world\n"`.

*address* is a code address specified by a label, e.g., `myfunc`, `loop`, etc.

## Syscalls

Yeah

## Stack Frames

Yeah

# Instructions

`nop` | does nothing | nothing

`ldc_i` *integerConstant* | push an integer constant on the stack | the constant

`ldc_i` *stringConstant* | push a string constant on the stack | the constant

`add` | pop right operand, pop left operand, compute sum left+right | sum

`sub` | pop right operand, pop left operand, compute difference left-right | difference

`mul` | pop right operand, pop left operand, compute product left\*right | product

`div` | pop right operand, pop left operand, compute quotient left/right | quotient

`exp` | pop exponent, pop base, compute base^exponent | result

`cmp` | pop right operand, pop left operand, compare | result of comparison

`je` *address* | pop comparison result, branch to *address* if comparison result is equal | nothing

`jne` *address* | pop comparison result, branch to *address* if comparison result is not equal | nothing

`jlt` *address* | pop comparison result, branch to *address* if comparison result is less than | nothing

`jgt` *address* | pop comparison result, branch to *address* if comparison result is greater than | nothing

`jlte` *address* | pop comparison result, branch to *address* if comparison result is less than or equal | nothing

`jgte` *address* | pop comparison result, branch to *address* if comparison result is greater than or equal | nothing

`jmp` *address* | unconditional jump to *address* | nothing

`call` *address* | call the subroutine at *address* | value returned by the subroutine

`syscall` *syscallName* | invoke syscall (see "Syscalls" above) | result of syscall

`pop` | pop one operand from the operand stack | nothing

`popn` *integerConstant* | pop given number of operands from the operand stack | nothing

`dup` | get the top value on operand stack, push it | another copy of top value

`enter` *integerConstant*, *integerConstant* | create stack frame (see "Stack Frames" above) | 0 for each local

`ret` | pop return value from operand stack, leave current stack frame (see "Stack Frames" above) | return value (on caller's operand stack)

`ldarg` *integerConstant* | push *n*th argument on operand stack (see "Stack Frames" above) | the argument

`ldlocal` *integerConstant* | push *n*th local on operand stack | the local

`stlocal` *integerConstant* | pop value, store it as *n*th local | nothing
