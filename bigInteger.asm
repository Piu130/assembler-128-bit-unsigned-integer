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

; Adds number from rsi to rdi
;
; RDI = address of first summand
; RSI = address of second summand
; return RDI
addition:
	push rax

	mov rax, qword[rsi]
	add qword[rdi], rax	; adds the first 8 bytes
	mov rax, qword[rsi+8]
	adc qword[rdi+8], rax	; adds the last 8 bytes with carry from before
				; with 'jc label' here we could check if there is an overflow
	pop rax
	ret

; RDI = address of minuend
; RSI = address of subtrahend
; return RDI
subtraction:
	push rax

	mov rax, qword[rsi]
	sub qword[rdi], rax	; subtracts the first 8 bytes
	mov rax, qword[rsi+8]
	sbb qword[rdi+8], rax	; subtracts the last 8 bytes with borrow from before
				; with 'jc label' here we could check if there is an 'underflow'
	pop rax
	ret

; RDI = address of first multiplier
; RSI = address of second multiplier
; return RDI 
multiplication:
	push r8
	push r9
	push rdx
	push rax

	mov r8, qword[rdi]	; frist block, first multiplier 
	mov r9, qword[rdi+8]	; second block, first multiplier

	xor rdx, rdx		; clear rdx for mul
	mov rax, r8
	mul qword[rsi]		; multiply first 2 blocks
	mov qword[rdi], rax	; move first result to first block
	mov qword[rdi+8], rdx	; move overflow to second block

	xor rdx, rdx		; clear rdx for mul
	mov rax, r8
	mul qword[rsi+8]	; multiply first block with second block
	add qword[rdi+8], rax	; add first multiplication block

	mov r10, rdx		; to calculate OF

	xor rdx, rdx		; clear rdx for mul
	mov rax, r9
	mul qword[rsi]		; multiply second block with first block
	add qword[rdi+8], rax	; add first multiplication block

	jc .setOverFlowFlag	; set OF if carry is set from addition
	or r10, rdx		; to calculate OF
	cmp r10, 0		; check if no overflow
	jne .setOverFlowFlag	; set OF if overflow from mul

	jmp $+2			; no overflow so jump next 2 lines
	.setOverFlowFlag:
	sev			; set overflow flag

	pop rax
	pop rdx
	pop r9
	pop r8
	ret

; reads hexstring into BUFF. Maxlength is BUFFLEN.
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

; converts string al to its hex equavilent
%macro _stringToHex 0
	cmp al, 0				; if 0 then end of string or invalid char
	je %%done				; jump to done
	sub al, '0'				; sub '0' to convert 0-9
	cmp al, 9				; if 0-9
	jle %%done				; jump to done
	sub al, 7				; else sub 7 to convert A-F
	%%done
%endmacro

; RDI = address to read number
readBigInteger:
	_readWriteBigInteger 0

	push rcx
	push rax
	push rbx

	mov rcx, BIGINTEGERLEN
	.stringLoop:
		xor rax, rax			; clear rax
		xor rbx,rbx			; clear rbx

		mov al, byte[BUFF+rcx*2-2]	; copy letter
		_stringToHex
		mov bl, al			; store hex value in bl
		shl bl, 4			; shift 4 for little endian

		mov al, byte[BUFF+rcx*2-1]	; copy second letter
		_stringToHex
		or bl, al			; or bl (xxxx0000) with al (0000xxxx)

		mov [rdi+rcx-1], bl		; store bl to its position

		loop .stringLoop

	pop rbx
	pop rax
	pop rcx
	ret

; RDI = address of number to write
writeBigInteger:
	push rcx
	push rax
	push rbx

	mov rcx, BIGINTEGERLEN
	.hexToString:
		xor rax, rax			; clear rax
		mov al, byte[rdi+rcx-1]		; mov current number to al
		mov rbx, rax			; copy it for second nybble

		and al, 0Fh			; mask out all but low nybble
		mov al, byte[HEXDIGITS+rax]	; get character equivalent
		mov byte[BUFF+rcx*2-1], al	; writes the number to its position

		shr bl, 4			; shift high 4 bits of char into low 4 bits
		mov bl, byte[HEXDIGITS+rbx]	; get character equivalent
		mov byte[BUFF+rcx*2-2], bl	; writes the number to its position

		loop .hexToString

	_readWriteBigInteger 1

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

