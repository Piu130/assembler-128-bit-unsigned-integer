SECTION .data

	BIGINTEGERLEN EQU 16
	HEXDIGITS: db "0123456789ABCDEF"
	HEXDIGITSLEN equ $-HEXDIGITS

	HEXSTR:	db "00000000000000000000000000000000",10
	HEXLEN equ $-HEXSTR

SECTION .bss

	BUFFLEN equ 32		; we need 32 because 1 char needs 1 byte and 1 hex needs 4 bits
	BUFF resb BUFFLEN	; temp buffer to read hex value

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

; %1 = 0 for read, 1 for write
%macro  _readWriteBigInteger 1
        push rsi
        push rdi
        push rax
        push rdx

        mov rax, %1
        mov rsi, BUFF
        mov rdi, 1
        mov rdx, BUFFLEN
        syscall

        pop rdx
        pop rax
        pop rdi
        pop rsi
%endmacro

; RDI = address to read number
readBigInteger:
	_readWriteBigInteger 0

	push rcx
	push rax

	mov r8, BUFF
	mov rcx, BUFFLEN
	.stringToHex
		mov rax, [BUFF+rcx]
		cmp rax, 0
		je .done		; check for 0 here (end of string)
		sub rax, '0'
		cmp rax, 9
		jle .done
		sub rax, 7
		.done
		mov [rdi+rcx], rax
		loop .stringToHex

	pop rax
	pop rcx
	ret

; RDI = address of number to write
writeBigInteger:
	push rcx
	push rax
	push rbx
	push rdi

	mov rcx, 16
	.loopLetters
		xor rax, rax			; clear rax
		mov al, byte[rdi+rcx-1]		; mov current number to al
		mov rbx, rax			; copy it for second nybble

		and al, 0Fh			; mask out all but low nybble
		mov al, byte[HEXDIGITS+rax]	; get character equivalent
		mov byte[BUFF+rcx*2-1], al	; writes the number to its position

		shr bl, 4			; shift high 4 bits of char into low 4 bits
		mov bl, byte[HEXDIGITS+rbx]	; get character equivalent
		mov byte[BUFF+rcx*2-2], bl	; writes the number to its position

		loop .loopLetters

	_readWriteBigInteger 1

	pop rdi
	pop rbx
	pop rax
	pop rcx
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

