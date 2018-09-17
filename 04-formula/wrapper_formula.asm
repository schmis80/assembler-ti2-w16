;************************************************
; 
; Rechnerarchitektur (TI2) - WS16
; formula Wrapper
;
; Wrapper for Assignment 4:
;   gets passed eight argument strings,
;   converts them to int32_t,
;   calls 'formula'-function,
;   prints result or error message
;
; Stefan Schmid
; 2018/08/21

%define RED     27,"[31;1m" 
%define RESET   27,"[0m"

section .bss
end_ptr:    resq    1


section .data

result_msg:       
    db      "%d",10,0
err_invalid_msg:    
    db      RED,"Invalid argument: ",RESET,"%s",10,\
            "Only digits are allowed!",10,0
err_not_enough_msg:
    db      RED,"Not enough Arguments",10,RESET,\
            "Usage: ./gauss <number>",10,0

section .text

extern strtol, printf, formula
global main

main:
    cmp     rdi, 9
    jb      err_not_enough
    mov     r12, rsi
    mov     r13, 1      ;counter vor arguments
    enter   8*4, 0
conversion:
    mov     rdi, [r12+r13*8]
    mov     rsi, end_ptr
    mov     rdx, 10
    mov     rax, strtol
    call    rax
    mov     rdi, end_ptr
    mov     rdi, [rdi]
    cmp     byte [rdi], 0
    jne     err_invalid
    mov     dword [rsp+r13*4-4], eax   ;save parameter in array
    inc     r13
    cmp     r13, 8  ;check if all arguments have been converted
    jbe     conversion 
    mov     edi,  [rsp]
    mov     esi,  [rsp+4]
    mov     edx,  [rsp+8]
    mov     ecx,  [rsp+12]
    mov     r8d,  [rsp+16]
    mov     r9d,  [rsp+20]
    mov     r10d, [rsp+24]
    mov     r11d, [rsp+28]
    enter   16, 0           ;open stack frame for 7th and 8th parameter
    mov     [rsp], r10
    mov     [rsp+8], r11
    xor     r10, r10
    xor     r11, r11
    call    formula
    leave
    leave
    mov     rdi, result_msg
    mov     rsi, rax
    xor     rax, rax
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
