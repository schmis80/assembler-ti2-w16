section .text

global calc
calc:	
	mov r9, 0
loop:
	cmp rdi, 0
	je ende
	sub rdi, 4
	movups xmm0, [rsi+r9]
	movups xmm1, [rdx+r9]
	
    mov     r10, addition
	cmp     r8, '+'
	je      calculation
    mov     r10, subtraction
	cmp     r8, '-'
	je      calculation
    mov     r10, mult
	cmp     r8, '*'
	je      calculation
    mov     r10, division
calculation:
    call    r10
    movups  [rcx+r9], xmm0
    add     r9, 16
    jmp     loop
ende:
	ret

division:
	divps xmm0, xmm1
    ret

mult:
	mulps xmm0, xmm1
    ret

addition:
	addps xmm0, xmm1
    ret

subtraction:
	subps xmm0, xmm1
    ret

