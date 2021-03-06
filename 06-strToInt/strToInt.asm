;************************************************
; 
; Rechnerarchitektur (TI2) - WS16
; Assignment 6: strToInt
;
; Params: const char* str
;         char** end
;         uint8_t base
;
; Return: converted int64_t value of str
;
; Stefan Schmid
; 2018/08/18

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
    sub     r8b, 0x20   ;convert to uppercase letter
is_letter:
    sub     r8b, 0x07   ;convert to number
is_number:
    sub     r8b, 0x30   ;convert to actual value
    cmp     r8b, r9b    ;check if value is valid for the given base
    jae     invalid_char
    ret
invalid_char:
    mov     r8b, -1
    ret

strToInt:
    xor     rcx, rcx    ;byte counter
    mov     r10, 1
    cmp     byte [rdi], '-'
    jne     correctly_signed
    neg     r10
    inc     rcx
correctly_signed:
    and     rdx, 0xFF   ;make sure only lowest byte is filled
    cmp     dl, 36      ;valid base?
    ja      invalid_base 
    mov     r9, rdx
    xor     rax, rax    ;accumulator for result
    xor     r8, r8      ;will be used in char conversion
conversion:
    cmp     byte [rdi+rcx], 0   ;check for end of string
    je      end_conversion
    mov     r8b, [rdi+rcx]      ;get next char
    call    char_to_num
    cmp     r8b, -1             ;check for invalid char
    je      end_conversion
    mul     r9                  ;multiply by base
    add     rax, r8             ;add current digit
    inc     rcx
    jmp     conversion
end_conversion:
    mul     r10 
    lea     rdi, [rdi+rcx]
    mov     [rsi], rdi      ;let end point to char where conversion stopped
    ret

invalid_base:
    mov     [rsi], rdi
    ret
