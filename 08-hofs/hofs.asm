;************************************************
; 
; Rechnerarchitektur (TI2) - WS16
; Assignment 8: fold / zipWith
;
; fold
; -----------------------------------------------
;
; Stefan Schmid
; 2018/09/13

section .text
global fold, zipWith

fold:
;   Params:
;   int64_t   (*func)(int64_t, int64_t)
;   uint64_t  len
;   int64_t   a[len]
;   uint8_t   dir)
;

;   r12-r15 belong to calling function
    push    r12
    push    r13
    push    r14
    push    r15

    mov     r15, rdx                  ;array
    mov     r12, rsi                  ;len
    mov     r13, rdi                  ;func
    cmp     rcx, 0                    ;dir
    je      left_to_right
   
right_to_left:
    dec     r12
    mov     rax, [r15+8*r12]      ;res = array[len-1]

.loop:
;   for (i=len-1; i>=0; i--){
;       res = func(res,array[i])
;   }
;
    dec     r12       
    cmp     r12, 0
    jl      endfold           
    mov     rsi, rax          
    mov     rdi, [r15+8*r12]  
    call    r13              
    jmp     .loop          

left_to_right:
    mov     r14, 1
    mov     rax, [r15]

.loop:
;   while(i < len){
;     res = func(res, array[i])
;     i++ 
;   }
;
    cmp     r14, r12
    jae     endfold           
    mov     rdi, rax          
    mov     rsi, [r15+8*r14]  
    call    r13               
    inc     r14               
    jmp     .loop             

endfold:
    pop     r14
    pop     r13
    pop     r12
    pop     r15
    ret                       

zipWith:
;   Params:
;   int64_t (*func)(int64_t,int64_t)
;   uint64_t len
;   int64_t a[len]
;   int64_t b[len]
;   int64_t c[len]
;
;   Description:
;   Uses func to calculate a value from the
;   corresponding entries of arrays a and b and 
;   stores the result in array c
;

;   rbx, r12-r15 belong to calling function
    push    rbx
    push    r12
    push    r13
    push    r14
    push    r15

    mov     rbx, rdi    ;func
    mov     r12, rsi    ;len
    mov     r13, rdx    ;a
    mov     r14, rcx    ;b
    mov     r15, r8     ;c

.loop:
;   for(i=len-1; i>=0; i--){
;       c[i] = func(a[i],b[i]);
;   }
;
    dec     r12
    cmp     r12, 0
    jl      zipend            
    mov     rdi, [r13+8*r12]  
    mov     rsi, [r14+8*r12]  
    call    rbx              
    mov     [r15+8*r12], rax  
    jmp     .loop             

zipend:
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx

    mov     rax, 0
    ret
