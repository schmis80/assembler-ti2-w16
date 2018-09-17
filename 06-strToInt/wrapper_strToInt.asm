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
; 2018/08/21

section .data
    result_msg:         
        db      "Integer: %d_%s",10,"Length: %u",10,0
    err_invalid_msg:    
        db      27,"[31;1m","Invalid Argument:",27,"[0m %s",10,0  
    err_not_enough_msg:
        db      27,"[31;1m","Not enough Arguments",27,"[0m",10,0

section .text

extern strToInt, printf
global main

main:
    sub     rsp, 8          ;reserve space for end_ptr
    cmp     rdi, 3
    jb      err_not_enough
    mov     r12, rsi
    mov     rdi, [r12+16]   ;get second passed argument
    mov     rsi, rsp
    mov     rdx, 10         ;base to convert to
    call    strToInt
    mov     rdi, [rsp]
    cmp     byte [rdi], 0   ;test if conversion was successfull
    jne     err_invalid
    mov     rdi, [r12+8]
    mov     rsi, rsp
    mov     rdx, rax
    call    strToInt
    mov     rdi, [rsp]
    cmp     byte [rdi], 0
    jne     err_invalid
    sub     rdi, [r12+8]
    mov     rcx, rdi
    mov     rdi, result_msg
    mov     rsi, rax
    mov     rdx, [r12+16]
    xor     rax, rax
    mov     r8, printf
    call    r8
    xor     rdi, rdi        ;program was successful
    jmp     exit
    
err_not_enough:
    mov     rdi, err_not_enough_msg
    jmp     print_error

err_invalid:
    mov     rsi, [r12]      ;char that made conversion fail
    mov     rdi, err_invalid_msg

print_error:
    xor     rax, rax
    mov     rcx, printf
    call    rcx
    mov     rdi, 1              ;program was not successful

exit:
    add     rsp, 8          ;restore stackpointer
    mov     rax, 60
    syscall
