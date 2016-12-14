
SECTION .data

	BIGINTEGERLEN EQU 16

	ENTER: db "Enter %c:",10,0
	CALCOUTPUT: db "%c %c %c =",10,0
	VARIS: db "%c is: ",10,0

SECTION .bss

	X resb BIGINTEGERLEN 
	Y resb BIGINTEGERLEN
	Z resb BIGINTEGERLEN
	R resb BIGINTEGERLEN
	S resb BIGINTEGERLEN
	T resb BIGINTEGERLEN

SECTION .text

EXTERN addition, subtraction, multiplication, readUDlong, writeUDlong, copyUDlong
EXTERN printf

GLOBAL main

main:
	nop

	mov rdi, ENTER
	mov rsi, 'X'
	xor rax, rax
	call printf

	mov rdi, X
	call readUDlong

	mov rdi, ENTER
	mov rsi, 'Y'
	xor rax, rax
	call printf

	mov rdi, Y
	call readUDlong

	mov rdi, ENTER
	mov rsi, 'Z'
	xor rax, rax
	call printf

	mov rdi, Z
	call readUDlong

	mov rdi, X
	mov rsi, R
	call copyUDlong

	mov rdi, Y
	mov rsi, S
	call copyUDlong

	mov rdi, Z
	mov rsi, T
	call copyUDlong

	mov rdi, X
	mov rsi, Y
	call addition
	mov rdi, CALCOUTPUT
	mov rsi, 'X'
	mov rdx, '+'
	mov rcx, 'Y'
	xor rax, rax
	call printf
	mov rdi, X
	call writeUDlong

	mov rdi, VARIS
	mov rsi, 'Y'
	xor rax, rax
	call printf
	mov rdi, Y
	call writeUDlong

	mov rdi, X
	mov rsi, Y
	call subtraction
	mov rdi, CALCOUTPUT
	mov rsi, 'X'
	mov rdx, '-'
	mov rcx, 'Y'
	xor rax, rax
	call printf
	mov rdi, X
	call writeUDlong

        mov rdi, VARIS
        mov rsi, 'Y'
        xor rax, rax
        call printf
        mov rdi, Y
        call writeUDlong

        mov rdi, R
        mov rsi, S
        call subtraction
        mov rdi, CALCOUTPUT
        mov rsi, 'R'
        mov rdx, '-'
        mov rcx, 'S'
        xor rax, rax
        call printf
        mov rdi, R
        call writeUDlong

        mov rdi, VARIS
        mov rsi, 'S'
        xor rax, rax
        call printf
        mov rdi, S
        call writeUDlong

        mov rdi, T
        mov rsi, Z
        call multiplication
        mov rdi, CALCOUTPUT
        mov rsi, 'T'
        mov rdx, '*'
        mov rcx, 'Z'
        xor rax, rax
        call printf
        mov rdi, T
        call writeUDlong

        mov rdi, VARIS
        mov rsi, 'Z'
        xor rax, rax
        call printf
        mov rdi, Z
        call writeUDlong

	call exit

exit:
	mov rax, 60
	mov rdi, 0
	syscall

