;************************************************
; 
; Rechnerarchitektur (TI2) - WS16
; Collatz Wrapper
;
; Wrapper for Assignment 2:
;   gets number n passed as argument string,
;   converts n to unsigned integer,
;   calls 'collatz'-function,
;   prints result or error message
;
; Stefan Schmid
; 08/17/2018



section .data
    result_msg:         
        db      "collatz(%u) = %llu",10,0
    err_invalid_msg:    
        db      27,"[31;1m","Invalid character: %c",27,"[0m",10,0  
    err_not_enough_msg:
        db      27,"[31;1m","Not enough Arguments",27,"[0m",10,0

section .text

extern strtoul, printf, collatz
global main

main:
    cmp     rdi, 2
    jb      err_not_enough
    mov     rdi, [rsi+8]        ;get passed argument
    mov     rdx, 10             ;base to convert to
    call    strtoul
    cmp     byte [rdi], 0       ;test if conversion was successfull
    jne     err_invalid
    push    rsi
    mov     rdi, rsi
    call    collatz
    mov     rdx, rax
    pop     rsi
    mov     rdi, result_msg
    xor     rax, rax
    call    printf
    xor     rdi, rdi            ;program was successful
    jmp     exit
    
err_not_enough:
    mov     rdi, err_not_enough_msg
    jmp     print_error

err_invalid:
    mov     rsi, [rdi]          ;char that made conversion fail
    mov     rdi, err_invalid_msg

print_error:
    xor     rax, rax
    call    printf
    mov     rdi, 1              ;program was not successful

exit:
    mov     rax, 60
    syscall
