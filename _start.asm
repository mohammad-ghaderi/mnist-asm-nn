global _start
extern load_mnist_image, load_mnist_label
extern print_message, print_int, print_newline
extern img, label

section .data
msg db "First pixel = ",0
msg_len equ $ - msg

section .text
_start:
    ; load image and label
    lea rdi, [rel img]        ; buffer for image
    call load_mnist_image

    lea rdi, [rel label]      ; buffer for label
    call load_mnist_label

    ; print message
    lea rdi, [rel msg]
    mov rsi, msg_len
    call print_message

    ; print first pixel
    movzx rdi, byte [rel img]
    call print_int

    ; print new line
    call print_newline

    ; exit
    mov rax, 60   ; syscall: exit
    xor rdi, rdi
    syscall
