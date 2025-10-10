global _start
extern argmax

section .data
array dq 1.0, 5.2, 3.7, 9.8, 2.1 

section .text
_start:
    lea rdi, [rel array]   ; rdi = &array
    mov rcx, 5             ; rcx = length
    call argmax            ; rax = index of max (3)

    ; checking from debug (gdb)

    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall
