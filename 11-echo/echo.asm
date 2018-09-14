;************************************************
; 
; Rechnerarchitektur (TI2) - WS16
; Assignment 11: echo (syscalls)
;
; reads at most MAX_SIZE bytes from stdin,
; then writes them to stdout
;
; Stefan Schmid
; 2018/09/14

%define READ        0
%define WRITE       1
%define STDIN       0
%define STDOUT      1
%define MAX_SIZE    255

section .text
global _start
_start:
    enter   MAX_SIZE+1, 0
;   read at most MAX_SIZE bytes from stdin
    mov     rax, READ 
    mov     rdi, STDIN
    mov     rsi, rsp
    mov     rdx, MAX_SIZE
    syscall
    mov     byte [rsp+rax], 0
    
;   write the amount of read bytes to stdout
    mov     rdx, rax
    inc     rdx
    mov     rax, WRITE
    mov     rdi, STDOUT
    mov     rsi, rsp
    syscall

    leave
    mov     rax, 60
    xor     rdi, rdi
    syscall
