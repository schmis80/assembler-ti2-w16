;************************************************
; 
; Rechnerarchitektur (TI2) - WS16
; Assignment 4: formula
;
; Params: uint64_t a, b, c, d, e, f, g, h
;
; Return: (a+b)*(c-d)*(e*8 + f*4 − g/2 + h/4)/3
;
; Stefan Schmid
; 08/21/2018

section .text

global formula

formula:
    add     edi, esi
    sub     edx, ecx
    mov     eax, edi
    imul    eax, edx
    sal     r8d, 3
    sal     r9d, 2
    mov     r10d, [rsp+8]   ;get 7th parameter
    sar     r10d, 1
    mov     r11d, [rsp+16]  ;get 8th parameter
    sar     r11d, 2
    add     r8d, r9d
    sub     r8d, r10d
    add     r8d, r11d
    imul    eax, r8d
    mov     r8d, 3
    xor     edx, edx
    cmp     eax, 0          ;check if result is negative
    jge     division
    not     edx             ;set edx accordingly
division:
    idiv    r8d
    ret
