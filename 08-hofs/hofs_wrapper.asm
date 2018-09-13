%define RED		27,"[31m"
%define DEFAULT 27,"[39m"

%define BOLD	27,"[1m"
%define RESET	27,"[0m"

section .bss
    end_ptr:    resq    1

section .data
    not_enough_arguments_msg:
        db  BOLD,RED,"Not enough arguments!",10,RESET,\
            "Usage: ./hofs <len> <op>",10,0
    invalid_argument_msg:
        db  BOLD,RED,"Invalid argument: ",'"',"%s",'"',"!",10,RESET,0
    only_digits_msg:        
        db  "Only Digits are allowed!",10,0
    allowed_operations_msg:
        db  "Please insert only ",\
            42, "+" , 42, ", ",\
            42, "-" , 42, ", ",\
            42, "\*", 42, ", ",\
            " as operation.",10,0
    right_to_left_msg:
        db  "fold right to left",10,0
    entry_op_msg:
        db  "%dll%c%c",0
    result_msg:
        db  "Result: %lld",10,0
    
    

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

;print_right_to_left:
;    push    r12
;    push    r13
;    push    r14
;    push    r15
;;	printf("fold-rtl:\n");
;;	for(size_t i=0; i<len; i++) {
;;		if(i == len-1) {
;;			printf("%"PRId64, a[i]);
;;		} else {
;;			printf("%"PRId64"%c", a[i], argv[2][0]);
;;		}
;;		if(i < len -2) {
;;			printf("(");
;;		}
;;	}
;;	for(size_t i=2; i<len; i++) {
;;		printf(")");
;;	}
;;
;    mov     r12, rdi
;    mov     r13, rsi
;    mov     r14, rdx
;    mov     rdi, right_to_left_msg
;    xor     rax, rax
;    call    printf
;    mov     r15, r13
;print_loop:
;    cmp     r13, 0
;    je      close_parentheses
;    dec     r13
;    mov     rsi, 0
;    cmp     r13, 0
;    je      print
;    dec     r13
;    mov     rsi, r14
;    mov     rdx, 0
;    cmp     r13, 0
;    je      print
;    mov     rdx, '('
;print:
;    mov     rdi, entry_op_msg
;    xor     rax, rax
;    call    printf
;    inc     r13
;    jmp     print_loop
;close_parentheses:
    
    
    
    

;   1. Param length of arrays
;   2. Param operation
main:
    cmp     rdi, 3
    jae     enough_arguments

;   print error message, if not enough arguments are given
    mov     rdi, not_enough_arguments_msg
    xor     rax, rax
    call    printf
    mov     rdi, 1
    jmp     exit

enough_arguments:
    mov     r12, rsi
    mov     rdi, [r12+8]
    mov     rsi, end_ptr
    mov     rdx, 10
    call    strtoull
    cmp     byte [rdi], 0
    je      conversion_successful

;   print error message, if invalid argument was given
    mov     rdi, invalid_argument_msg
    mov     rsi, [r12+8]
    xor     rax, rax
    call    printf
    mov     rdi, only_digits_msg
    xor     rax, rax
    call    printf
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
    call    printf
    mov     rdi, allowed_operations_msg
    xor     rax, rax
    call    printf
    mov     rdi, 1
    jmp     exit

valid_operation:
    mov     rdi, 0
    call    time
    mov     rdi, rax
    call    srand

    lea     rdi, [2*r13+r13]
    lea     rdi, [8*rdi]
;   enter stackframe with 3*8*lenght bytes
    push    rbp
    mov     rbp, rsp
    sub     rsp, rdi
    xor     r15, r15
fill_loop:
    cmp     r15, r13
    je      end_loop
    call    rand
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
;   mov     rdi, rsp
;   mov     rsi, r13
;   lea     rdx, [r12+16]
;   mov     rdx, [rdx]
;   mov     rcx, 1
;   call    print_right_to_left
    mov     rdi, result_msg
    mov     rsi, rax    
    xor     rax, rax
    call    printf
    mov     rdi, r14
    mov     rsi, r13
    mov     rdx, rsp
    xor     rcx, rcx
    call    fold
    mov     rdi, result_msg
    mov     rsi, rax
    xor     rax, rax
    call    printf
    xor     rdi, rdi
    mov     rsp, rbp
    pop     rbp
exit:   
    mov     rax, 60
    syscall    

;	int64_t res = fold(func, len, a, 1);
;	// Ausgabe fold
;        printf("=%"PRId64"\n\nfold-ltr:\n", res);
;        res = fold(func, len, a, 0);
;	for(size_t i=2; i<len; i++) {
;		printf("(");
;	}
;	for(size_t i=0; i<len; i++) {
;		printf("%"PRId64, a[i]);
;		if(i < len-1) {
;			if(i > 0) {
;				printf(")");
;			}
;			printf("%c", argv[2][0]);
;		}
;	}
;	printf("=%"PRId64"\n\nzipWith:\n", res);
;
;	zipWith(func, len, a, b, c);
;	// Ausgabe zipWith
;	for(size_t i=0; i<len; i++) {
;		printf("%"PRId64"%c%"PRId64"=%"PRId64"\n", a[i], argv[2][0], b[i], c[i]);
;	}
;
;	return EXIT_SUCCESS;
;}
