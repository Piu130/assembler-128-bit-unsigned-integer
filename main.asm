SECTION .data

SECTION .bss

	BIGINTEGERLEN EQU 16
	X resb BIGINTEGERLEN 
	Y resb BIGINTEGERLEN
	Z resb BIGINTEGERLEN
	R resb BIGINTEGERLEN
	S resb BIGINTEGERLEN
	T resb BIGINTEGERLEN

SECTION .text

EXTERN addition, subtraction, multiplication, readBigInteger, writeBigInteger, copyBigInteger

GLOBAL _start

_start:
	nop
	
	call exit

exit:
	mov rax, 60
	mov rdi, 0
	syscall

