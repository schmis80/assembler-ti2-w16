;************************************************
; 
; Rechnerarchitektur (TI2) - WS16
; formula Wrapper
;
; Wrapper for Assignment 5:
;   gets passed eight argument strings,
;   converts them to double,
;   calls 'formula'-function,
;   prints result or error message
;
; Stefan Schmid
; 2018/08/21

section .bss
    end_ptr:    resq    1

section .data
    result_msg:         
        db      "%lf",10,0
    err_invalid_msg:    
        db      27,"[31;1m","Invalid Argument:",27,"[0m %s",10,0  
    err_not_enough_msg:
        db      27,"[31;1m","Not enough Arguments",27,"[0m",10,0

section .text

extern strtod, printf, formula
global main

main:
    sub     rsp, 8
    cmp     rdi, 9
    jb      err_not_enough
    mov     r12, rsi
    mov     r13, 1      ;counter vor arguments
    enter   8*16,0
conversion:
    mov     rdi, [r12+r13*8]
    mov     rsi, end_ptr
    mov     rax, strtod
    call    rax
    mov     rdi, end_ptr
    mov     rdi, [rdi]
    cmp     byte [rdi], 0
    jne     err_invalid
    lea     rsi, [r13*8]
    movsd   [rsp+rsi*2-16], xmm0
    inc     r13
    cmp     r13, 8
    jbe     conversion
    movsd   xmm0, [rsp]
    movsd   xmm1, [rsp+16]
    movsd   xmm2, [rsp+32]
    movsd   xmm3, [rsp+48]
    movsd   xmm4, [rsp+64]
    movsd   xmm5, [rsp+80]
    movsd   xmm6, [rsp+96]
    movsd   xmm7, [rsp+112]
    leave
    call    formula
    mov     rdi, result_msg
    mov     rax, 2
    mov     rcx, printf
    call    rcx
    xor     rdi, rdi            ;program was successful
    jmp     exit
    
err_not_enough:
    mov     rdi, err_not_enough_msg
    jmp     print_error

err_invalid:
    mov     rsi, [r12+r13*8]    ;char that made conversion fail
    mov     rdi, err_invalid_msg

print_error:
    xor     rax, rax
    mov     rcx, printf
    call    rcx
    mov     rdi, 1              ;program was not successful

exit:
    mov     rax, 60
    syscall
