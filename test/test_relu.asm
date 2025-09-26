global _start
extern relu

section .data
    vals dq 3.5, 0.0, -2.75      ; test inputs and check the xmm0 using gdb debug

section .text
_start:
    ; ---- test val[0] ----
    movsd xmm0, [rel vals]
    call relu

    ; ---- test val[1] ----
    movsd xmm0, [rel vals+8]
    call relu

    ; ---- test val[2] ----
    movsd xmm0, [rel vals+16]
    call relu

    ; exit
    mov rax, 60
    xor rdi, rdi
    syscall