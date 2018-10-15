;************************************************
; 
; Rechnerarchitektur (TI2) - WS16
;
; Wrapper for Assignment 8:
;   gets passed two argument strings,
;   converts first to int64_t, checks if second
;   one is one either "+", "-", "*", or "/"
;   calls the higher-order-functions
;   fold (right to left), fold (left to right),
;   and zipWith. And prints their results
;
; Stefan Schmid
; 2018/09/13

%define RED     27,"[31m"
%define DEFAULT 27,"[39m"

%define BOLD	27,"[1m"
%define RESET	27,"[0m"

%macro MY_CALL 1
    push    r15
    mov     r15, %1
    call    r15
    pop     r15
%endmacro

%macro cmp_at 2
    push    r15
    mov     r15, %1
    mov     r15, [r15]
    cmp     byte [r15], %2
    pop     r15
%endmacro

%macro multipush 1-*
    %rep %0
        push    %1
    %rotate 1
    %endrep
%endmacro

%macro multipop 1-*
    %rep %0
    %rotate -1
        pop    %1
    %endrep
%endmacro


section .bss
    end_ptr:    resq    1

section .data
    not_enough_arguments_msg:
        db  BOLD,RED,"Not enough arguments!",10,RESET,\
            "Usage: ./hofs <len> <op>",10,0
    invalid_argument_msg:
        db  BOLD,RED,'Invalid argument: "%s"!',10,RESET,0
    only_digits_msg:        
        db  "Only Digits are allowed!",10,0
    allowed_operations_msg:
        db  'Please insert only "+","-","\*", or "/" as operation.',10,0
    rtl_msg:
        db  "fold-rtl:",10,0
    ltr_msg:
        db  10,"fold-ltr:",10,0
    entry_op_msg:
        db  "%lld%c%c",0
    rtl_p:
        db  ")",0
    ltr_p:
        db  "(",0
    fold_res:
        db  "=%3lld",10,0
    zip_msg:
        db  10,"zipWith:",10,0
    zip_op_msg:
        db  "%3lld %c %3lld = %3lld",10,0
    
    

section .text

extern fold, zipWith, time, srand, rand, printf, strtoull
global main

addition:
    mov     rax, rdi
    add     rax, rsi
    ret

subtraction:
    mov     rax, rdi
    sub     rax, rsi
    ret

multiply:
    mov     rax, rdi
    mul     rsi
    ret

division:
    mov     rax, rdi
    xor     rdx, rdx
    div     rsi
    ret

rtl_print:
;   uint64_t a[len], uint64_t len, int64_t res, char op
;   prints the array like this:
;       1+(2+(3+4))=10
;
    multipush r12, r13, r14, r15, rbx

    mov     r12, rdi
    mov     r13, rsi
    mov     r14, rdx
    mov     rbx, rcx
    xor     r15, r15

    mov     rdi, rtl_msg
    xor     rax, rax
    MY_CALL printf
.loop:
    cmp     r15, r13
    je      .end_loop

    lea     r8, [r13-1]
    xor     rdx, rdx
    xor     rcx, rcx
    cmp     r15, r8
    je      .print

    lea     r8, [r13-2]
    mov     rdx, rbx
    mov     rcx, '('
    cmp     r15, r8
    jb      .print

    xor     rcx, rcx
    
.print:
    mov     rdi, entry_op_msg
    mov     rsi, [r12+8*r15]
    xor     rax, rax
    MY_CALL    printf
    inc     r15
    jmp     .loop

.end_loop:
    sub     r13, 2
    xor     r15, r15
.p_loop:
    cmp     r15, r13
    jae     .end_p_loop
    mov     rdi, rtl_p
    xor     rax, rax
    MY_CALL    printf
    inc     r15
    jmp     .p_loop

.end_p_loop:
    mov     rdi, fold_res
    mov     rsi, r14
    xor     rax, rax
    MY_CALL    printf

    multipop r12, r13, r14, r15, rbx
    ret

ltr_print:
;   uint64_t a[len], uint64_t len, int64_t res, char op
;   prints the array like this:
;       1+(2+(3+4))=10
;
    multipush r12, r13, r14, r15, rbx

    mov     r12, rdi
    mov     r13, rsi
    mov     r14, rdx
    mov     rbx, rcx

    mov     rdi, ltr_msg
    xor     rax, rax
    MY_CALL    printf
    sub     r13, 2
    xor     r15, r15
.p_loop:
    cmp     r15, r13
    jae     .end_p_loop
    mov     rdi, ltr_p
    xor     rax, rax
    MY_CALL    printf
    inc     r15
    jmp     .p_loop

.end_p_loop:
    add     r13, 2
    xor     r15, r15
.loop:
    cmp     r15, r13
    je      .end_loop

    lea     r8, [r13-1]
    xor     rdx, rdx
    xor     rcx, rcx
    cmp     r15, r8
    je      .print

    mov     rdx, ')'
    mov     rcx, rbx
    cmp     r15, 0
    ja      .print

    mov     rdx, rbx
    xor     rcx, rcx
    
.print:
    mov     rdi, entry_op_msg
    mov     rsi, [r12+8*r15]
    xor     rax, rax
    MY_CALL    printf
    inc     r15
    jmp     .loop

.end_loop:
    mov     rdi, fold_res
    mov     rsi, r14
    xor     rax, rax
    MY_CALL printf

    multipop r12, r13, r14, r15, rbx
    ret

zip_print:
;   uint64_t a[len], uint64_t len, char op
;   prints our three arrays like this:
;       1 + 3 = 4
;       2 + 4 = 6
;      
    multipush r12, r13, r14, r15

    mov     r12, rdi
    mov     r13, rsi
    mov     r14, rdx
    xor     r15, r15

    mov     rdi, zip_msg
    xor     rax, rax
    MY_CALL    printf

.loop:
    cmp     r15, r13
    je      .end_loop
    mov     rdi, zip_op_msg
    mov     rsi, [r12+8*r15]
    mov     rdx, r14
    lea     r9, [r12+8*r15]
    mov     rcx, [r9+8*r13]
    lea     r9, [r9+8*r13]
    mov     r8, [r9+8*r13]
    xor     rax, rax
    MY_CALL    printf
    inc     r15
    jmp     .loop

.end_loop:
    multipop r12, r13, r14, r15
    ret

;   1. Param length of arrays
;   2. Param operation
main:
    cmp     rdi, 3
    jae     enough_arguments

;   print error message, if not enough arguments are given
    mov     rdi, not_enough_arguments_msg
    xor     rax, rax
    MY_CALL    printf
    mov     rdi, 1
    jmp     exit

enough_arguments:
    mov     r12, rsi
    mov     rdi, [r12+8]
    mov     rsi, end_ptr
    mov     rdx, 10
    MY_CALL strtoull
    cmp_at  end_ptr, 0
    je      conversion_successful

;   print error message, if invalid argument was given
    mov     rdi, invalid_argument_msg
    mov     rsi, [r12+8]
    xor     rax, rax
    MY_CALL    printf
    mov     rdi, only_digits_msg
    xor     rax, rax
    MY_CALL    printf
    mov     rdi, 1
    jmp     exit

conversion_successful:
    mov     r13, rax
    mov     rdi, [r12+16]
    cmp     byte [rdi+1], 0
    jne     invalid_operation
    mov     r14, addition
    cmp     byte [rdi], '+'
    je      valid_operation
    mov     r14, subtraction
    cmp     byte [rdi], '-'
    je      valid_operation
    mov     r14, division
    cmp     byte [rdi], '/'
    je      valid_operation
    mov     r14, multiply
    cmp     byte [rdi], '*'
    je      valid_operation

invalid_operation:
    mov     rdi, invalid_argument_msg
    mov     rsi, [r12+16]
    xor     rax, rax
    MY_CALL    printf
    mov     rdi, allowed_operations_msg
    xor     rax, rax
    MY_CALL    printf
    mov     rdi, 1
    jmp     exit

valid_operation:
    mov     rdi, 0
    MY_CALL    time
    mov     rdi, rax
    MY_CALL    srand

    lea     rbx, [2*r13+r13]
    lea     rdi, [8*rbx]
;   enter stackframe with 3*8*lenght bytes
    push    rbp
    mov     rbp, rsp
    sub     rsp, rdi
    xor     r15, r15
fill_loop:
    cmp     r15, rbx
    je      end_loop
    MY_CALL    rand
    xor     rdx, rdx
    mov     rcx, 100
    div     rcx
    mov     [rsp+8*r15], rdx
    inc     r15
    jmp     fill_loop

end_loop:
;   call fold_right_to_left
    mov     rdi, r14
    mov     rsi, r13
    mov     rdx, rsp
    mov     rcx, 1
    call    fold
    mov     rdi, rsp
    mov     rsi, r13
    mov     rdx, rax
    mov     r8, [r12+16] 
    xor     rcx, rcx
    mov     cl, [r8]  
    call    rtl_print
;   call fold_left_to_right
    mov     rdi, r14
    mov     rsi, r13
    mov     rdx, rsp
    xor     rcx, rcx
    call    fold
    mov     rdi, rsp
    mov     rsi, r13
    mov     rdx, rax
    mov     r8, [r12+16] 
    xor     rcx, rcx
    mov     cl, [r8]  
    call    ltr_print
    mov     rdi, r14
    mov     rsi, r13
    mov     rdx, rsp
    lea     rcx, [rsp+8*r13]
    lea     r8, [rcx+8*r13]
    call    zipWith
    mov     rdi, rsp
    mov     rsi, r13
    mov     r8, [r12+16] 
    xor     rdx, rdx
    mov     dl, [r8]  
    call    zip_print
    xor     rdi, rdi
;   leave stackframe
    mov     rsp, rbp
    pop     rbp
exit:   
    mov     rax, 60
    syscall    
