SECTION .data

	UDLONGLEN EQU 16
	HEXDIGITS: db "0123456789ABCDEF"
	HEXDIGITSLEN equ $-HEXDIGITS

SECTION .bss

	BUFFLEN equ 33		; we need 33 because 1 char needs 1 byte and 1 hex needs 4 bits
				; +1 becaues of LF
	BUFF resb BUFFLEN	; temp buffer to read hex value

SECTION .text

GLOBAL addition, subtraction, multiplication, readUDlong, writeUDlong, copyUDlong

; Adds number from RSI to RDI. Stores result in RDI.
; RDI = address of first summand
; RSI = address of second summand
addition:
	push rax

	mov rax, qword[rsi]
	add qword[rdi], rax	; adds the first 8 bytes
	mov rax, qword[rsi+8]
	adc qword[rdi+8], rax	; adds the last 8 bytes with carry from before
				; with 'jc label' here we could check if there is an overflow
	pop rax
	ret

; Subtracts number from RSI to RDI. Stores result in RDI.
; RDI = address of minuend
; RSI = address of subtrahend
subtraction:
	push rax

	mov rax, qword[rsi]
	sub qword[rdi], rax	; subtracts the first 8 bytes
	mov rax, qword[rsi+8]
	sbb qword[rdi+8], rax	; subtracts the last 8 bytes with borrow from before
				; with 'jc label' here we could check if there is an 'underflow'
	pop rax
	ret

; Multiply RDI with RSI. Stores result in RDI.
; RDI = address of first multiplier
; RSI = address of second multiplier
multiplication:
	push r8
	push r9
	push rdx
	push rax

	mov r8, qword[rdi]	; frist block, first multiplier 
	mov r9, qword[rdi+8]	; second block, first multiplier

	xor rdx, rdx		; clear RDX for mul
	mov rax, r8
	mul qword[rsi]		; multiply first 2 blocks
	mov qword[rdi], rax	; move first result to first block
	mov qword[rdi+8], rdx	; move overflow to second block

	xor rdx, rdx		; clear RDX for mul
	mov rax, r8
	mul qword[rsi+8]	; multiply first block with second block
	add qword[rdi+8], rax	; add first multiplication block

	mov r10, rdx		; to calculate OF

	xor rdx, rdx		; clear RDX for mul
	mov rax, r9
	mul qword[rsi]		; multiply second block with first block
	add qword[rdi+8], rax	; add first multiplication block

	jc .setOverFlowFlag	; set OF if carry is set from addition
	or r10, rdx		; to calculate OF
	cmp r10, 0		; check if no overflow
	jne .setOverFlowFlag	; set OF if overflow from mul

	jmp $+2			; no overflow, jump next 2 lines
	.setOverFlowFlag:
	sev			; set overflow flag

	pop rax
	pop rdx
	pop r9
	pop r8
	ret

; Reads/writes hexstring into BUFF. Maxlength is BUFFLEN.
; %1 = 0 for read
; %1 = 1 for write
; Sets RBP as input length
%macro  _readWriteUDlong 1
        push rsi
        push rdi
        push rax
        push rdx

        mov rax, %1
        mov rsi, BUFF
        mov rdi, 1
        mov rdx, BUFFLEN
        syscall

	mov rbp, rax

        pop rdx
        pop rax
        pop rdi
        pop rsi
%endmacro

; Converts string in register AL to its hex equavilent.
; AL = number to convert
%macro _stringToHex 0
	cmp al, '0'				; if less than '0' end of string or invalid char
	jl %%invalidChar			; jump to done

	sub al, '0'				; sub '0' to convert 0-9
	cmp al, 9				; cmp 0-9
	jle %%done				; jump to done

	sub al, 7				; else sub 7 to convert A-F
	cmp al, 0Ah				; cmp A
	jl %%invalidChar			; filter ASCII 3Ah-40h

	cmp al, 0Fh				; cmp F
	jle %%done				; jump to done

	sub al, 32				; else sub 32 to convert a-f
	cmp al, 0Ah				; cmp A
	jl %%invalidChar			; filter ASCII 5B-60

	cmp al, 0Fh				; if less or equal than F
	jle %%done				; jump to done

	%%invalidChar:				; label for invalid character
	mov al, 0				; set 0 if invalid

	%%done:
%endmacro

; Reads number from STDIN to address in RDI.
; RDI = address to read number to
readUDlong:
	_readWriteUDlong 0			; reads STDIN to BUFF

	push rcx
	push rdx
	push rax
	push rbx

	mov rcx, rbp				; input loop
	dec rcx					; string starts by 0
	dec rcx					; to remove LF
	xor rdx, rdx				; store loop

	.stringLoop:				; loop over the string 
		xor rax, rax			; clear RAX
		mov al, byte[BUFF+rcx-1]	; copy letter
		_stringToHex			; convert char to hex
		mov rbx, rax			; store hex value in BL
		shl bl, 4			; shift 4 for little endian

		mov al, byte[BUFF+rcx]		; copy second letter
		_stringToHex			; convert char to hex
		or bl, al			; or BL (xxxx0000) with AL (0000xxxx)
		mov [rdi+rdx], bl		; store BL to its position

		inc rdx				; inc store position
		dec rcx				; dec for first char
		dec rcx				; dec for second char
		cmp rcx, 0			; compare RCX to 0
		jns .stringLoop			; jump as long as it is not negative

	pop rbx
	pop rax
	pop rdx
	pop rcx
	ret

; Writes number at address of RSI to STDOUT.
; RDI = address of number to write
writeUDlong:
	push rcx
	push rdx
	push rax
	push rbx

	mov rcx, UDLONGLEN			; store loop
	xor rdx, rdx				; output loop
	.hexToString:				; loop to convert hex to string
		xor rax, rax			; clear rax
		mov al, byte[rdi+rcx-1]		; mov current number to AL
		mov rbx, rax			; copy it for second nybble

		and al, 0Fh			; mask out all but low nybble
		mov al, byte[HEXDIGITS+rax]	; get character equivalent
		mov byte[BUFF+rdx*2+1], al	; writes the number to its position

		shr bl, 4			; shift high 4 bits of char into low 4 bits
		mov bl, byte[HEXDIGITS+rbx]	; get character equivalent
		mov byte[BUFF+rdx*2], bl	; write the number to its position
		inc rdx				; inc RDX for the next write iteration
		loop .hexToString		; loop over the string

	mov byte[BUFF+BUFFLEN-1], 10		; add LF to the end

	_readWriteUDlong 1			; write the number to STDOUT

	pop rbx
	pop rax
	pop rdx
	pop rcx
	ret

; Copy number from RDI to RSI.
; RDI = address of original number
; RSI = address of copy number
copyUDlong:
	push rax

	mov rax, qword[rdi]			; copy the first qword
	mov qword[rsi], rax			; to qword[RSI]
	mov rax, qword[rdi+8]			; copy the second qword
	mov qword[rsi+8], rax			; to qword[RSI+8]

	pop rax
	ret

