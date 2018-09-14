;************************************************
; 
; Rechnerarchitektur (TI2) - WS16
; Assignment 2: collatz
;
; gets uint64_t n, 
; returns lenght of the collatz conjecture of n
; with 9 instructions
;
; Stefan Schmid
; 2018/09/14

section .text
global collatz

odd:     lea    rdi, [rdi+rdi*2+1]
while:   inc    r9 
         test   rdi, 1
         jne    odd 
even:    shr    rdi, 1
collatz: cmp    rdi, 1
         jg     while
         mov    rax, r9 
         ret 
