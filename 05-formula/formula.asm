;************************************************
; 
; Rechnerarchitektur (TI2) - WS16
; Assignment 4: formula
;
; Params: double a, b, c, d, e, f, g, h
;
; Return: (a+b)*(c-d)*(e*8 + f*4 − g/2 + h/4)/3
;
; Stefan Schmid
; 2018/08/21

section .data
    two:    dq  2.
    three:  dq  3.
    four:   dq  4.
    eight:  dq  8.

section .text

global formula

formula:
    addsd   xmm0, xmm1
    subsd   xmm2, xmm3
    mulsd   xmm0, xmm2
    mov     rax, eight
    mulsd   xmm4, [rax]
    mov     rax, four
    mulsd   xmm5, [rax]
    mov     rax, two
    divsd   xmm6, [rax]
    mov     rax, four
    divsd   xmm7, [rax]
    addsd   xmm4, xmm5
    subsd   xmm4, xmm6
    addsd   xmm4, xmm7
    mulsd   xmm0, xmm4
    mov     rax, three
    divsd   xmm0, [rax]
    ret
