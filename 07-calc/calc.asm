;************************************************
; 
; Rechnerarchitektur (TI2) - WS16
; Assignment 6: strToInt
;
; Params: float operand1
;         float operand2
;         float* result
;
; Return: 0 if success, else 1
;
; Stefan Schmid
; 2018/09/11

section .text
global calc_add
global calc_sub

calc_sub:
    ;swap sign of op2, because op1-op2 = op1 + (-op2)
    movd    eax, xmm1
    xor     eax, 1<<31
    jmp     from_sub

calc_add:
    movd    eax, xmm1       ;get op2
from_sub:
    call split_ieee
    mov     r9b, dl    
    mov     r10b, r8b
    mov     ecx, eax

    movd    eax, xmm0       ;get op1
    call    split_ieee

;   Adjust exponents
    cmp     r8d, r10d
    jae     cont
    xchg    r9, rdx         ;swap operands if exp1 < exp2
    xchg    r10, r8
    xchg    rcx, rax
cont:
    mov r11b, r8b
    sub r11b, r10b          ;get difference between the exponents

shift_loop:
;   adjust mantissa of op2
    cmp r11b, 0
    je end_loop
    dec r11b    
    shr ecx, 1  ;Char_op2 >> 1
    jmp shift_loop
end_loop:

;   Add / subtract mantissas
    cmp     dl, r9b
    je      addition	    ;add if signs are equal, else subtract
    cmp     eax, ecx
    jae     subtraction
    xchg    r9, rdx         ;swap operands if mant1 < mant2
    xchg    r10, r8
    xchg    rcx, rax
subtraction:
    sub     eax, ecx
    jnz     normalize
    mov     r8b, 1          ;zero has exponent 1
    jmp     cont2

normalize:
    cmp     eax, 1<<23      ;check if mantissa is too big (> 23 bit)
    jae     cont2
    shl     eax, 1          ;adjust mantissa
    dec     r8b             ;adjust exponent
    jmp     normalize

addition:
    add     eax, ecx

    cmp     eax, 1<<24      ;check if mantissa is too big 
    jb      cont2
    shr     eax, 1          ;normalize mantissa
    inc     r8b

cont2:
    and     eax, 0x7fffff   ;remove implicit 1
    shl     r8d, 23         ;add exponent
    or      eax, r8d    
    shl     edx, 31         ;add sign
    or      eax, edx
    mov     [rdi], eax      ;write result to given address
    xor     rax, rax
    ret

split_ieee:
;   get sign
    mov     edx, eax
    shr     edx, 31
;   get exponent
    mov     r8d, eax
    shr     r8d, 23
    and     r8d, 0xff
;   get mantissa
    and     eax, 0x7fffff
    add     eax, 1<<23      ;add implicit 1 to mantissa
    ret
