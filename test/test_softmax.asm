global _start
extern softmax

section .data
; Example input vector of length 3
input dq 1.0, 2.0, 3.0

section .bss
output resq 3      ; space for 3 outputs

section .text
_start:
    ; Call softmax(input, output, length=3)
    lea rdi, [rel input]    ; rdi = pointer to input
    lea rsi, [rel output]      ; rsi = pointer to output buffer
    mov rcx, 3              ; rcx = length
    call softmax  

    ; in the output buffer the result would be stored and can check by gdb :) 

    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall
