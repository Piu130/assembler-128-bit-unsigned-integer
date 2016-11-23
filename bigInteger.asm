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
	mov rax, qword[rsi]
	add qword[rdi], rax	; adds the first 8 bytes
	mov rax, qword[rsi+8]
	adc qword[rdi+8], rax	; adds the last 8 bytes with carry from before
				; with 'jc label' here we could check if there is an overflow
	ret

; RDI = address of minuend
; RSI = address of subtrahend
; return RDI
subtraction:
	mov rax, qword[rsi]
	sub qword[rdi], rax	; subtracts the first 8 bytes
	mov rax, qword[rsi+8]
	sbb qword[rdi+8], rax	; subtracts the last 8 bytes with borrow from before
				; with 'jc label' here we could check if there is an 'underflow'
	ret

; RDI = address of first multiplier
; RSI = address of second multiplier
; return RDI 
multiplication:

	ret

; RDI = address of string
; %1 = 0 for read, 1 for write
%macro  _readWriteBigInteger 1
        push rsi
        push rdi
        push rax
        push rdx

        mov rax, %1
        mov rsi, rdi
        mov rdi, 1
        mov rdx, 2*BIGINTEGERLEN
        syscall

	; @TODO convert string to hex here
	mov rcx, 2*BIGINTEGERLEN
	.loop
		mov rax, [rdi+rcx]
		sub rax, '0'		; sub '0' to convert 0-9
		cmp rax, 9
		jle .done
		sub rax, 7		; sub '0' from above and 7 to convert A-F
		.done
		mov [rdi+rcx], rax
		loop .loop

        pop rdx
        pop rax
        pop rdi
        pop rsi
%endmacro

; RDI = address to read number
readBigInteger:
	_readWriteBigInteger 0
	ret

; RDI = address of number to write
writeBigInteger:
	_readWriteBigInteger 1
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

