global _start
extern layer_forward

section .data
input dq 1.0, 2.0          ; input vector (length = 2)

; w[2][2]
weights dq 0.5, 0.5, 1.0, -1.0

bias dq 0.0, 0.0           ; two biases

msg db "Outputs: ", 0
newline db 10

section .bss
out_buff resq 2

section .text
_start:
    ; args: (input, weights, bias, out, 2 neurons, 2 inputs)
    lea rdi, [rel input]
    lea rsi, [rel weights]
    lea rdx, [rel bias]
    lea r8,  [rel out_buff]
    mov rcx, 2
    mov r9, 2
    call layer_forward

    ; out_buff has stored the answer you can check using gdb

    ; exit
    mov rax, 60
    xor rdi, rdi
    syscall
