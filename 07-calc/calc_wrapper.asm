;************************************************
; 
; Rechnerarchitektur (TI2) - WS16
; formula Wrapper
;
; Wrapper for Assignment 7:
;   gets passed two argument strings,
;   converts them to float,
;   calls 'calc_add'- and 'calc_sub'-function,
;   prints result or error messages
;
; Stefan Schmid
; 2018/09/12

section .bss
    result:     resd    1
    op1:        reso    1
    op2:        reso    1
    end_ptr:    resq    1

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
    sub     rsp, 8
    cmp     rdi, 3
    jb      err_not_enough
    mov     r12, rsi
    mov     r13, 1      ;counter for arguments
;   convert first argument
    mov     rdi, [r12+8]
    mov     rsi, end_ptr
    call    strtof
;   strtof stores the address of the char,
;   where the conversion failed, to r9.
;   if it was successful r9 is set to 0
;
    cmp     r9, 0
    jne     err_invalid
    movsd   [op1], xmm0
;   convert second argument
    inc     r13
    mov     rdi, [r12+16]
    mov     rsi, end_ptr
    call    strtof
    cmp     r9, 0
    jne     err_invalid
    movsd   [op2], xmm0

    movsd   xmm0, [op1]
    movsd   xmm1, [op2]
    mov     rdi, result
    call    calc_add
    mov     r12, result
    cvtss2sd xmm0, xmm0
    cvtss2sd xmm1, xmm1
    movsd   xmm2, [r12]
    cvtss2sd xmm2, xmm2
    mov     rdi, result_msg
    mov     rsi, '+'
    mov     rax, 2
    call    printf
    movsd   xmm0, [op1]
    movsd   xmm1, [op2]
    mov     rdi, result
    call    calc_sub
    mov     r12, result
    cvtss2sd xmm0, xmm0
    cvtss2sd xmm1, xmm1
    movsd   xmm2, [r12]
    cvtss2sd xmm2, xmm2
    mov     rdi, result_msg
    mov     rsi, '-'
    mov     rax, 2
    call    printf
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
    call    printf
    mov     rdi, 1              ;program was not successful

exit:
    mov     rax, 60
    syscall
