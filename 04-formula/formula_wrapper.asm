;************************************************
; 
; Rechnerarchitektur (TI2) - WS16
; formula Wrapper
;
; Wrapper for Assignment 4:
;   gets number n passed as argument string,
;   converts n to unsigned integer,
;   calls 'formula'-function,
;   prints result or error message
;
; Stefan Schmid
; 08/21/2018

section .bss
    vals:       resd    8
    end_ptr:    resq    1

section .data
    result_msg:         
        db      "%d",10,0
    err_invalid_msg:    
        db      27,"[31;1m","Invalid Argument:",27,"[0m %s",10,0  
    err_not_enough_msg:
        db      27,"[31;1m","Not enough Arguments",27,"[0m",10,0

section .text

extern strtol, printf, formula
global main

main:
    cmp     rdi, 9
    jb      err_not_enough
    mov     r12, rsi
    mov     r13, 1      ;counter vor arguments
conversion:
    mov     rdi, [r12+r13*8]
    mov     rsi, end_ptr
    mov     rdx, 10
    call    strtol
    cmp     byte [rdi], 0
    jne     err_invalid
    mov     dword [vals+r13*4-4], eax   ;save parameter in array
    inc     r13
    cmp     r13, 8  ;check if all arguments have been converted
    jbe     conversion 
    mov     edi,  [vals]
    mov     esi,  [vals+4]
    mov     edx,  [vals+8]
    mov     ecx,  [vals+12]
    mov     r8d,  [vals+16]
    mov     r9d,  [vals+20]
    mov     r10d, [vals+24]
    mov     r11d, [vals+28]
    enter   24, 0
    mov     [rsp], r10
    mov     [rsp+8], r11
    xor     r10, r10
    xor     r11, r11
    call    formula
    leave
    mov     rdi, result_msg
    mov     rsi, rax
    xor     rax, rax
    call    printf
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
    call    printf
    mov     rdi, 1              ;program was not successful

exit:
    mov     rax, 60
    syscall
