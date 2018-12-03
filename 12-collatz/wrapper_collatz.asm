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
; 2018/08/17

%define RED     27,"[31;1m" 
%define RESET   27,"[0m"

section .bss

end_ptr:    resq    1


section .data

result_msg:         
    db      "collatz(%u) = %llu",10,0
err_invalid_msg:    
    db      RED,"Invalid argument: ",RESET,"%s",10,\
            "Only digits are allowed!",10,0
err_not_enough_msg:
    db      RED,"Not enough Arguments",10,RESET,\
            "Usage: ./collatz <number>",10,0

section .text

extern strtoul, printf, collatz
global main

main:
    mov     r12, rsi
    cmp     rdi, 2
    jb      err_not_enough
    mov     rdi, [r12+8]        ;get passed argument
    mov     rsi, end_ptr
    mov     rdx, 10             ;base to convert to
    call    strtoul wrt ..plt
    mov     rdi, [end_ptr]
    cmp     byte [rdi], 0       ;test if conversion was successfull
    jne     err_invalid
    push    rax
    mov     rdi, rax
    call    collatz
    mov     rdi, result_msg
    pop     rsi
    mov     rdx, rax
    xor     rax, rax
    call    printf
    xor     rdi, rdi            ;program was successful
    jmp     exit
    
err_not_enough:
    mov     rdi, err_not_enough_msg
    jmp     print_error

err_invalid:
    mov     rdi, err_invalid_msg
    mov     rsi, [r12+8]        ;invalid argument

print_error:
    xor     rax, rax
    call    printf
    mov     rdi, 1              ;program was not successful

exit:
    mov     rax, 60
    syscall
