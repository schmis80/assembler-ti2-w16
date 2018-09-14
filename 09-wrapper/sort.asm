section .text
global sort
sort:
	mov r8, rdi ;i
.loop:
	cmp r8, 1  
	jbe ende    
	mov r9, 0   ;j

.inner_loop:
	lea r10, [r8-1] ;i-1

	cmp r9, r10
	jge .cont_loop
	
	mov rcx, [rsi+r9*8]		;A[j]
	mov rdx, [rsi+r9*8+8]	;A[j+1]
	
	cmp rcx, rdx
	jbe .cont_inner_loop

	mov [rsi+r9*8], rdx
	mov [rsi+r9*8+8], rcx	

.cont_inner_loop:	
	inc r9		
	jmp .inner_loop

.cont_loop:
	dec r8
	jmp .loop

ende:	
	ret

