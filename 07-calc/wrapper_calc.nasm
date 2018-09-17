;************************************************
; 
; Rechnerarchitektur (TI2) - WS16
; calc Wrapper
;
; Wrapper for Assignment 7:
;   gets passed two argument strings,
;   converts them to float,
;   calls 'calc_add'- and 'calc_sub'-function,
;   prints result or error messages
;
; Stefan Schmid
; 2018/09/12

%define END_PTR rsp
%define OP1     rsp+0x08
%define OP2     rsp+0x18
%define RESULT  rsp+0x28

%define STRTOF  r14
%define PRINTF  r15

section .data
    result_msg:         
        db      "%f",9,"%c",9,"%f",9,"=",9,"%f",10,0
    err_invalid_msg:    
        db      27,"[31;1m","Invalid Argument:",27,"[0m %s",10,0  
    err_not_enough_msg:
        db      27,"[31;1m","Not enough Arguments",27,"[0m",10,0

section .text

extern strtof, printf, calc_add, calc_sub
global main

main:
    mov     r14, strtof
    mov     r15, printf

    sub     rsp, 0x38
    cmp     rdi, 3
    jb      err_not_enough
    mov     r12, rsi
    mov     r13, 1      ;counter for arguments
;   convert first argument
    mov     rdi, [r12+8]
    mov     rsi, END_PTR
    call    STRTOF
    mov     rdi, [END_PTR]
    cmp     byte [rdi], 0
    jne     err_invalid
    movsd   [OP1], xmm0
;   convert second argument
    inc     r13
    mov     rdi, [r12+16]
    mov     rsi, END_PTR
    call    STRTOF
    mov     rdi, [END_PTR]
    cmp     byte [rdi], 0
    jne     err_invalid
    movsd   [OP2], xmm0

    movsd   xmm0, [OP1]
    movsd   xmm1, [OP2]
    lea     rdi, [RESULT]
    call    calc_add
    cvtss2sd xmm0, xmm0
    cvtss2sd xmm1, xmm1
    movsd   xmm2, [RESULT]
    cvtss2sd xmm2, xmm2
    mov     rdi, result_msg
    mov     rsi, '+'
    mov     rax, 2
    call    PRINTF
    movsd   xmm0, [OP1]
    movsd   xmm1, [OP2]
    lea     rdi, [RESULT]
    call    calc_sub
    cvtss2sd xmm0, xmm0
    cvtss2sd xmm1, xmm1
    movsd   xmm2, [RESULT]
    cvtss2sd xmm2, xmm2
    mov     rdi, result_msg
    mov     rsi, '-'
    mov     rax, 2
    call    PRINTF
    xor     rdi, rdi            ;program was successful
    jmp     exit
    
err_not_enough:
    mov     rdi, err_not_enough_msg
    jmp     print_error

err_invalid:
    mov     rsi, [r12+r13*8]    ;address of string that could not be converted
    mov     rdi, err_invalid_msg

print_error:
    xor     rax, rax
    call    PRINTF
    mov     rdi, 1              ;program was not successful

exit:
    add     rsp, 0x38
    mov     rax, 60
    syscall
