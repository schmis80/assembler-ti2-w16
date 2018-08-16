;************************************************
; 
; TI2 WS16 - Assignment 1:
;
; gets uint64_t n, 
; returns sum from 1 to n
;
; Stefan Schmid
; 08/16/2018

section .text

global gauss

gauss:               
    mov     rax, rdi             
    shr     rdi, 1              ;divide by 2 first, to avoid overflow 
    mul     rdi  
    add     rax, rdi 
    ret
