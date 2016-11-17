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
	push r8			; use for carry
	push r9			; current number of first bigint
	push r10		; current number of second bigint
	push rcx		; numberposition counter

	xor r8, r8

	mov al, [rdi+rcx]
	sub al, '0'
	mov r9, al		; value of rdi

	mov al, [rsi+rcx]
	sub al, '0'
	mov r10, al		; value of rsi

	mov r11, r9
	stc			; sets carry flag
	adc r11, r10		; just a test implementation for first numbers
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

; RDI = address to read number
readBigInteger:
	push rsi

	mov rsi, 0
	call _readWriteBigInteger

	pop rsi
	ret

; RDI = address of number to write
writeBigInteger:
	push rsi

	mov rsi, 1
	call _readWriteBigInteger
	
	pop rsi
	ret

; RDI = address of number to read/write
; RSI = 0 for read, 1 for write
_readWriteBigInteger:
	push rsi
	push rdi
	push rax
	push rdx

	mov rax, rsi
	mov rsi, rdi
	mov rdi, 1
	mov rdx, BIGINTEGERLEN
	syscall

	pop rdx
	pop rax
	pop rdi
	pop rsi
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

