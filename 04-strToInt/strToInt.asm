;************************************************
; 
; Rechnerarchitektur (TI2) - WS16
; Assignment 4: strToInt
;
; Params: const char* str
;         char** end
;         uint8_t base
;
; Return: converted int64_t value of str
;
; Stefan Schmid
; 08/18/2018

section .text

global strToInt

char_to_num:
    cmp     r8b, '0'
    jb      invalid_char
    cmp     r8b, '9'
    jbe     is_number

    cmp     r8b, 'A'
    jb      invalid_char
    cmp     r8b, 'Z'
    jbe     is_letter

    cmp     r8b, 'a'
    jb      invalid_char
    cmp     r8b, 'z'
    ja      invalid_char
    sub     r8b, 0x20   ;convert to lowercase letter
is_letter:
    sub     r8b, 0x07   ;convert to number
is_number:
    sub     r8b, 0x30   ;convert to actual value
    ret
invalid_char:
    mov     r8b, -1
    ret

strToInt:
    mov     r10, 1
    cmp     byte [rdi], '-'
    jne     correctly_signed
    neg     r10
    inc     rdi
correctly_signed:
    and     rdx, 0xFF   ;make sure only lowest byte is filled
    cmp     dl, 36      ;valid base?
    ja      invalid_base
    mov     r9, rdx
    xor     rax, rax    ;accumulator for result
    xor     r8, r8      ;will be used in char conversion
    xor     rcx, rcx    ;byte counter
conversion:
    cmp     byte [rdi+rcx], 0
    je      end_conversion
    mov     r8b, [rdi+rcx]
    call    char_to_num
    cmp     r8b, -1
    je      end_conversion
    mul     r9
    add     rax, r8
    inc     rcx
    jmp     conversion
end_conversion:
    mul     r10 
    lea     rdi, [rdi+rcx]
    mov     [rsi], rdi
    ret

invalid_base:
    mov     rax, -1
    ret


