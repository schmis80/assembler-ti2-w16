;************************************************
; 
; Rechnerarchitektur (TI2) - WS16
;
; Wrapper for Assignment 10:
;   gets passed two argument strings,
;   converts first to int64_t, checks if second
;   one is one either "+", "-", "*", or "/"
;   calls the 'calc'-function
;   prints the results
;
; Stefan Schmid
; 2018/09/14

%define RED     27,"[31m"
%define DEFAULT 27,"[39m"

%define BOLD	27,"[1m"
%define RESET	27,"[0m"

%macro mov_to 2
    push    r15
    mov     r15, %1
    mov     [r15], %2
    pop     r15
%endmacro

%macro mov_from 2
    push    r15
    mov     r15, %2
    mov     %1, [r15]
    pop     r15
%endmacro

%macro mycall 1
    push    r15
    mov     r15, %1
    call    r15
    pop     r15
%endmacro

section .bss
    end_ptr:    resq    1
    given_len:  resq    1

section .data
    edge:
        dd  12.0
    rand_next:
        dq  1
    not_enough_arguments_msg:
        db  BOLD,RED,"Not enough arguments!",10,RESET,\
            "Usage: ./hofs <len> <op>",10,0
    invalid_argument_msg:
        db  BOLD,RED,"Invalid argument: ",34,"%s",34,"!",10,RESET,0
    only_digits_msg:        
        db  "Only Digits are allowed!",10,0
    allowed_operations_msg:
        db  "Please insert only ",\
            34, "+" , 34, ", ",\
            34, "-" , 34, ", ",\
            34, "\*", 34, " as operation.",10,0
    result_msg:
        db  "%2d: %9f %c %9f = %9f",10,0
    
section .text

extern calc, printf, strtoull
global main

srand:
    ret

rand_float:
    mov_from rax, rand_next
    mov     rcx, 1103515245
    mul     rcx
    add     rax, 12345
    mov_to  rand_next, rax
    mov     rcx, 65536
    xor     rdx, rdx
    div     rcx
    mov     rcx, 32768
    xor     rdx, rdx
    div     rcx
    pxor    xmm0, xmm0
    cvtsi2ss xmm0, rdx
    cvtsi2ss xmm1, rcx
    divss   xmm0, xmm1
    mov     rcx, edge
    mulss   xmm0, [rcx]
    ret

print_result:
;   uint64_t a[len], uint64_t len, char op
;   prints our three arrays like this:
;      0: 1.2 + 3.4 = 4.6
;      1: 2.3 + 4.5 = 6.8
;      
    push    r12
    push    r13
    push    r14
    push    r15

    mov     r12, rdi
    mov     r13, rsi
    mov     r14, rdx
    xor     r15, r15

.loop:
    mov     rcx, given_len
    cmp     r15, qword [rcx]
    je      .end_loop
    movd    xmm0, [r12+4*r15]
    cvtss2sd xmm0, xmm0
    lea     r9, [r12+4*r15]
    movd    xmm1, [r9+4*r13]
    cvtss2sd xmm1, xmm1
    lea     r9, [r9+4*r13]
    movd    xmm2, [r9+4*r13]
    cvtss2sd xmm2, xmm2
    mov     rdi, result_msg
    mov     rsi, r15
    mov     rdx, r14
    mov     rax, 2
    mycall  printf
    inc     r15
    jmp     .loop

.end_loop:
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    ret

;   1. Param length of arrays
;   2. Param operation
main:
    cmp     rdi, 3
    jae     enough_arguments

;   print error message, if not enough arguments are given
    mov     rdi, not_enough_arguments_msg
    xor     rax, rax
    mycall  printf
    mov     rdi, 1
    jmp     exit

enough_arguments:
    mov     r12, rsi
    mov     rdi, [r12+8]
    mov     rsi, end_ptr
    mov     rdx, 10
    mycall  strtoull
    mov     rsi, end_ptr
    mov     rsi, [rsi]
    cmp     byte [rsi], 0
    je      conversion_successful

;   print error message, if invalid argument was given
    mov     rdi, invalid_argument_msg
    mov     rsi, [r12+8]
    xor     rax, rax
    mycall  printf
    mov     rdi, only_digits_msg
    xor     rax, rax
    mycall  printf
    mov     rdi, 1
    jmp     exit

conversion_successful:
    mov     r13, rax
    mov     rdi, [r12+16]
    cmp     byte [rdi+1], 0
    jne     invalid_operation
    cmp     byte [rdi], '+'
    je      valid_operation
    cmp     byte [rdi], '-'
    je      valid_operation
    cmp     byte [rdi], '/'
    je      valid_operation
    cmp     byte [rdi], '*'
    je      valid_operation

invalid_operation:
    mov     rdi, invalid_argument_msg
    mov     rsi, [r12+16]
    xor     rax, rax
    mycall  printf
    mov     rdi, allowed_operations_msg
    xor     rax, rax
    mycall  printf
    mov     rdi, 1
    jmp     exit

valid_operation:
;   align length
    mov_to  given_len, r13    ;save given length
    mov     rax, r13
    xor     rdx, rdx
    mov     rcx, 4
    div     rcx
    sub     rcx, rdx
    add     r13, rcx

    rdtsc
    mov_to  rand_next, rax

    lea     rdi, [2*r13+r13]
    lea     rdi, [4*rdi]
;   enter stackframe with 3*4*lenght bytes
    push    rbp
    mov     rbp, rsp
    sub     rsp, rdi
    xor     r15, r15
    lea     rbx, [2*r13]
fill_loop:
    cmp     r15, rbx
    je      end_loop
    call    rand_float
    movd    [rsp+4*r15], xmm0
    inc     r15
    jmp     fill_loop

end_loop:
    mov     rdi, r13
    mov     rsi, rsp
    lea     rdx, [rsp+4*r13]
    lea     rcx, [rdx+4*r13]
    mov     r9, [r12+16]
    xor     r8, r8
    mov     r8b, byte [r9]
    call    calc
    mov     rdi, rsp
    mov     rsi, r13
    mov     r8, [r12+16] 
    xor     rdx, rdx
    mov     dl, [r8]  
    call    print_result
    xor     rdi, rdi
;   leave stackframe
    mov     rsp, rbp
    pop     rbp
exit:   
    mov     rax, 60
    syscall    

