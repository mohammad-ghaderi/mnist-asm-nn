global print_message
global print_int
global print_newline

section .text
nl db 10   ; ASCII code 10 = newline

; rdi = pointer, rsi = length
print_message:
    mov rax, 1
    mov rdx, rsi
    mov rsi, rdi
    mov rdi, 1
    syscall
    ret

; rdi = integer 0-255
print_int:
    push rdi
    mov rax, rdi
    mov rcx, 10
    xor rdx, rdx
    div rcx           ; rax = quotient, rdx = remainder
    add dl, '0'
    mov [rel buf], dl
    lea rdi, [rel buf]
    mov rsi, 1
    call print_message
    pop rdi
    ret

print_newline:
    mov rax, 1        ; syscall: write
    mov rdi, 1        ; stdout
    lea rsi, [rel nl] ; pointer to newline character
    mov rdx, 1        ; length = 1 byte
    syscall
    ret

section .bss
buf resb 1
