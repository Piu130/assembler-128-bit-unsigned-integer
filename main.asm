
SECTION .data

	BIGINTEGERLEN EQU 16
	TESTX TIMES 2 DQ 0xF894BFAC5677895F, 0x1123456789ABCDEF
	TESTY TIMES 2 DQ 0x1000000000000001, 0xFEDCBA9876543210

	ENTER: db "Enter %c",10,0
	CALCOUTPUT: db "%c %c %c = ",10,0

SECTION .bss

	X resb BIGINTEGERLEN 
	Y resb BIGINTEGERLEN
	Z resb BIGINTEGERLEN
	R resb BIGINTEGERLEN
	S resb BIGINTEGERLEN
	T resb BIGINTEGERLEN

SECTION .text

EXTERN addition, subtraction, multiplication, readBigInteger, writeBigInteger, copyBigInteger
EXTERN printf

GLOBAL main

main:
	nop

	mov rdi, ENTER
	mov rsi, 'X'
	xor rax, rax
	call printf

	mov rdi, X
	call readBigInteger

	mov rdi, ENTER
	mov rsi, 'Y'
	xor rax, rax
	call printf

	mov rdi, Y
	call readBigInteger

	mov rdi, ENTER
	mov rsi, 'Z'
	xor rax, rax
	call readBigInteger

	mov rdi, X
	mov rsi, R
	call copyBigInteger

	mov rdi, Y
	mov rsi, S
	call copyBigInteger

	mov rdi, Z
	mov rsi, T
	call copyBigInteger

	mov rdi, X
	mov rsi, Y
	call addition
	mov rdi, CALCOUTPUT
	mov rsi, 'X'
	mov rdx, '+'
	mov rcx, 'Y'
	call printf
	mov rdi, X
	call writeBigInteger




	;mov rdi, TESTX
	;mov rsi, TESTY
	;call addition


	call exit

exit:
	mov rax, 60
	mov rdi, 0
	syscall

