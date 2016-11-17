SECTION .data

SECTION .bss

SECTION .text

EXTERN addition, subtraction, multiplication, readBigInteger, writeBigInteger, copyBigInteger

GLOBAL _start

_start:
	nop
	call addition
	call exit

exit:
	mov rax, 60
	mov rdi, 0
	syscall

