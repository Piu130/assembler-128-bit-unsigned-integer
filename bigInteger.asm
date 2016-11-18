SECTION .data

	BIGINTEGERLEN EQU 16
	HEXDIGITS: db "FEDCBA9876543210"
	HEXDIGITSLEN equ $-HEXDIGITS

SECTION .bss

SECTION .text

GLOBAL addition, subtraction, multiplication, readBigInteger, writeBigInteger, copyBigInteger

; RDI = address of first summand
; RSI = address of second summand
; return RDI
addition:
	; [WIP]
	push r8			; use for carry
	push r9			; current number of first bigint
	push r10		; current number of second bigint
	push rcx		; numberposition counter

	xor r8, r8
	mov rcx, BIGINTEGERLEN

	.stringLoop
		mov r9, [rdi+rcx]
		sub r9, '0'

		mov r10, [rsi+rcx]
		sub r10, '0'

		add r9, r10		; just a test implementation for first numbers
		add r9, r8
		; check result convert to hex number, add to rdi, check for overflow

		loop .stringLoop
	ret

; RDI = address of minuend
; RSI = address of subtrahend
; return RDI
subtraction:

	ret

; RDI = address of first multiplier
; RSI = address of second multiplier
; return RDI 
multiplication:

	ret

; RDI = address of string
%macro  _readWrite 1
        push rsi
        push rdi
        push rax
        push rdx

        mov rax, %1
        mov rsi, rdi
        mov rdi, 1
        mov rdx, BIGINTEGERLEN
        syscall

        pop rdx
        pop rax
        pop rdi
        pop rsi
%endmacro

; RDI = address to read number
readBigInteger:
	_readWrite 0
	ret

; RDI = address of number to write
writeBigInteger:
	_readWrite 1
	ret

; RDI = address of original number
; RSI = address to copy number
copyBigInteger:
	push rdi
	push rsi
	push rdi
	mov rdi, rsi
	pop rsi

	mov rcx, BIGINTEGERLEN
	rep movsb

	pop rsi
	pop rdi
	ret

