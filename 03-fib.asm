;************************************************
; 
; TI2 WS16 - Assignment 3:
;
; gets uint64_t n, 
; provides an iterative and a recursive function
; to calclate the n-th member of the
; fibonacci sequence 
;
; Stefan Schmid
; 08/17/2018

section .text

global asm_fib_it, asm_fib_rek

asm_fib_it:               
    xor     rcx, rcx
    mov     rdx, 1
    xor     rax, rax
loop:
    cmp     rdi, 0
    jbe     return
    mov     rcx, rdx
    mov     rdx, rax
    lea     rax, [rcx+rdx]
    dec     rdi
    jmp     loop

table_init:
;   setting the cells of our table to -1
;   equivalent to:
;
;   for (int i = 0; i < n; i++) table[i] = -1
;
    xor     r8, r8
.loop:
    cmp     r8, rdi
    je      return
    mov     qword [rsi+r8*8], -1
    inc     r8
    jmp     .loop

fib:
;   calculate n-th fibonacci number using the algorithm:
;   
;   uint64_t fib(uint64_t n){
;       if (n <= 1) 
;           return n;
;       if (F[n] == -1) 
;           F[n] = fib(n-1) + fib(n-2);
;       return F[n]
;
    cmp     rax, 1
    jbe     return
    mov     rcx, rax
    cmp     qword [rsi+8*rax], -1
    jne     value_exists
    push    rax         ;push n to stack
    dec     rax
    push    rax         ;push n-1 to stack
    call    fib
    pop     rcx         ;pop n-1 from stack
    push    rax         ;push result of fib(n-1) to stack 
    mov     rax, rcx
    dec     rax
    call    fib
    pop     rcx         ;pop result of fib(n-1) from stack
    add     rax, rcx    ;add fib(n-1) to fib(n-2)
    pop     rcx
    mov     qword [rsi+8*rcx], rax
value_exists:
    mov     rax, [rsi+8*rcx]
return:
    ret

asm_fib_rek:
    mov     rax, rdi

;   open stackframe:
    push    rbp         
    mov     rbp, rsp  
    inc     rdi         ;so we can access F[n] later  
    lea     r8, [rdi*8]
    sub     rsp, r8
    mov     rsi, rsp

    call    table_init
    call    fib

;   close stackframe
    mov     rsp, rbp
    pop     rbp
    ret

