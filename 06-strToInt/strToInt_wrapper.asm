;************************************************
; 
; Rechnerarchitektur (TI2) - WS16
; strToInt Wrapper
;
; Wrapper for Assignment 4:
;   gets number n passed as argument string,
;   converts n to unsigned integer,
;   calls 'strToInt'-function,
;   prints result or error message
;
; Stefan Schmid
; 08/21/2018

section .bss
    end_ptr:    resq    1

section .data
    result_msg:         
        db      "Integer: %d_%u",10,"Length: %u",10,0
    err_invalid_msg:    
        db      27,"[31;1m","Invalid Argument:",27,"[0m %s",10,0  
    err_not_enough_msg:
        db      27,"[31;1m","Not enough Arguments",27,"[0m",10,0

section .text

extern strToInt, printf
global main

main:
    cmp     rdi, 3
    jb      err_not_enough
    mov     r12, rsi
    add     r12, 16
    mov     rdi, [r12]       ;get second passed argument
    mov     rsi, end_ptr
    mov     rdx, 10             ;base to convert to
    call    strToInt
    cmp     byte [rdi], 0       ;test if conversion was successfull
    jne     err_invalid
    sub     r12, 8
    mov     rdi, [r12]
    mov     rsi, end_ptr
    mov     rdx, rax
    push    rax
    call    strToInt
    cmp     byte [rdi], 0
    jne     err_invalid
    sub     rdi, r12
    mov     rdx, rdi
    mov     rdi, result_msg
    mov     rsi, rax
    pop     rdx 
    xor     rax, rax
    call    printf
    xor     rdi, rdi            ;program was successful
    jmp     exit
    
err_not_enough:
    mov     rdi, err_not_enough_msg
    jmp     print_error

err_invalid:
    mov     rsi, [r12]          ;char that made conversion fail
    mov     rdi, err_invalid_msg

print_error:
    xor     rax, rax
    call    printf
    mov     rdi, 1              ;program was not successful

exit:
    mov     rax, 60
    syscall
