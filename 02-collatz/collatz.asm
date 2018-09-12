;************************************************
; 
; Rechnerarchitektur (TI2) - WS16
; Assignment 2: collatz
;
; gets uint64_t n, 
; returns lenght of the collatz conjecture of n
;
; Stefan Schmid
; 2018/08/17

section .text

global collatz

collatz:               
    xor rax, rax
loop:
    cmp     rdi, 1
    jbe     return
    inc     rax
    test    rdi, 0x1
    jnz     odd
even:
    shr     rdi, 1
    jmp loop
odd:
    lea     rdi, [rdi*2+rdi]
    inc     rdi
    jmp loop

return:
    ret
