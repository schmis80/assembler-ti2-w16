;************************************************
; 
; Rechnerarchitektur (TI2) - WS16
; Gauss Wrapper
;
; Wrapper for Assignment 1:
;   gets number n passed as argument string,
;   converts n to unsigned integer,
;   calls 'gauss'-function,
;   prints result or error message
;
; Stefan Schmid
; 2018/08/16

%define RED     27,"[31;1m" 
%define RESET   27,"[0m"

section .bss
end_ptr:    resq    1

section .data
    result_msg:         
        db      "gauss(%llu) = %llu",10,0
    err_invalid_msg:    
        db      RED,"Invalid argument: ",RESET,"%s",10,\
                "Only digits are allowed!",10,0
    err_not_enough_msg:
        db      RED,"Not enough Arguments",10,RESET,\
                "Usage: ./gauss <number>",10,0
section .text

extern strtoul, printf, gauss
global main

main:
    push    r12
    mov     r12, rsi
    cmp     rdi, 2
    jb      err_not_enough
    mov     rdi, [r12+8]        ;get passed argument
    mov     rsi, end_ptr
    mov     rdx, 10             ;base to convert to
    call    strtoul wrt ..plt   ;result in rax and rsi, endptr in rdi 
    mov     rsi, end_ptr
    mov     rsi, [rsi]
    cmp     byte [rsi], 0       ;test if conversion was successfull
    jne     err_invalid
    push    rax
    mov     rdi, rax
    call    gauss
    mov     rdx, rax
    pop     rsi
    mov     rdi, result_msg
    xor     rax, rax
    call    printf wrt ..plt
    xor     rax, rax            ;program was successful
    jmp     exit
    
err_not_enough:
    mov     rdi, err_not_enough_msg
    jmp     print_error

err_invalid:
    mov     rsi, [r12+8]
    mov     rdi, err_invalid_msg

print_error:
    xor     rax, rax
    call    printf wrt ..plt
    mov     rax, 1              ;program was not successful

exit:
    pop     r12
    ret
