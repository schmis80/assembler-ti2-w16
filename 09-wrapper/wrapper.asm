;************************************************
; 
; Rechnerarchitektur (TI2) - WS16
;
; Wrapper for Assignment 9:
;   gets passed an argument string,
;   converts it to an integer n,
;   creates an array with n random elements,
;   prints the unsorted array,
;   calls the sort function
;   prints the sorted array
;
; Stefan Schmid
; 2018/09/14

%define RED     27,"[31m"
%define DEFAULT 27,"[39m"

%define BOLD    27,"[1m"
%define RESET   27,"[0m"

section .data
not_enough_arguments_msg:
    db  RED , BOLD, "Not enough arguments!", 10, RESET,\
        "Usage: ./sort <len>", 10, 0
head_msg:
	db  "Array: %2lu",0
elem_msg:
	db  ", %2lu%c",0

section .text

extern strtoul, time, srand, rand, printf, sort

global main

main:
	push    r12
	push    r13
	push    r14
	push    r15

    cmp     rdi, 2
    je      enough_arguments
    mov     rdi, not_enough_arguments_msg
    xor     rax, rax
    call    printf
    mov     rax, 1
    jmp     exit

enough_arguments:
	mov     rdi, [rsi+8]    ;get argument
	mov     rdx, 10
	call    strtoul         ;convert argument to integer
	mov     r13, rax        ;len
	lea     r12, [r13*8]
	
array:
    mov     rdi, 0
    call    time
    mov     rdi, rax
    call    srand

	push    rbp             ;enter stackframe
	mov     rbp, rsp
	sub     rsp, r12        ;reserve space for n 64 bit integers
    xor     r12, r12
    mov     r14, 100
.loop:
	cmp     r12, r13
	je      .end_loop
	call    rand
    xor     rdx, rdx
    div     r14
	mov     [rsp+r12*8], rdx	
	inc     r12
	jmp     .loop
.end_loop:
	mov     rdi, r13
    mov     r14, rsp
	call    printArray      ;print unsorted array

	mov     rsi, rsp
	mov     rdi, r13
	call    sort
	call    printArray      ;print sorted array
	
	mov     rsp, rbp        ;leave stackframe
	pop     rbp
	
    xor     rax, rax
exit:
	pop r15
	pop r14
	pop r13
	pop r12
	ret
	

printArray:
	mov     rdi, head_msg
	mov     rsi, [r14]
	xor     rax, rax
	call    printf			;print head of array
	mov     r12, 1
.loop:						;print inner elements of array
	cmp     r12, r13
	je      .end_loop
    mov     rdx, 10         ;for last element add newline to string
    lea     r8, [r13-1]
    cmp     r12, r8
    je      .print
    xor     rdx, rdx        ;end the string directly after the integer
.print:
	mov     rdi, elem_msg
	mov     rsi, [r14+r12*8]
	mov     rax, 0
	call    printf	
    inc     r12
	jmp     .loop
.end_loop:
	ret
	
	
	
	
	
