;************************************************
; 
; Rechnerarchitektur (TI2) - WS16
; Assignment 13: Matrix Sum
;
; Stefan Schmid
; 2018/09/14

section .text
global asmRowAdd, asmColAdd

asmRowAdd:
    xor     r10, r10
    xor     r8, r8
    mov     rcx, rdx
.row_loop:
    cmp     r8, rsi
    je      .end_row_loop
    xor     r9, r9
.col_loop:
    cmp     r9, rcx
    je      .end_col_loop
    mov     rax, rcx
    mul     r8
    add     rax, r9
    add     r10, [rdi+8*rax]
    inc     r9
    jmp     .col_loop
.end_col_loop:
    inc     r8
    jmp     .row_loop
.end_row_loop:
    mov     rax, r10
    ret

asmColAdd:
    xor     r10, r10
    xor     r9, r9
    mov     rcx, rdx
.col_loop:
    cmp     r9, rcx
    je      .end_col_loop
    xor     r8, r8
.row_loop:
    cmp     r8, rsi
    je      .end_row_loop
    mov     rax, rcx
    mul     r8
    add     rax, r9
    add     r10, [rdi+8*rax]
    inc     r8
    jmp     .row_loop
.end_row_loop:
    inc     r9
    jmp     .col_loop
.end_col_loop:
    mov     rax, r10
    ret
