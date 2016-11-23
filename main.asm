SECTION .data

	BIGINTEGERLEN EQU 16
	TESTX TIMES 2 DQ 0xF894BFAC5677895F, 0x1123456789ABCDEF
	TESTY TIMES 2 DQ 0x1000000000000001, 0xFEDCBA9876543210

SECTION .bss

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
	mov rdi, X
	call readBigInteger

	call writeBigInteger

	mov rdi, TESTX
	mov rsi, TESTY
	call addition


	call exit

exit:
	mov rax, 60
	mov rdi, 0
	syscall

