SECTION .data

SECTION .bss

SECTION .text

GLOBAL _start

_start:
	nop

	call exit

exit:
	mov rax, 60
	mov rdi, 0
	syscall

