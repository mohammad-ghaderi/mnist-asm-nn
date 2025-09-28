global _start
extern load_mnist_image, load_mnist_label
extern layer_forward, softmax, neg_log
extern img, label
extern W1, b1, W2, b2, W3, b3
extern z1, h1, z2, h2, o

BATCH_SIZE equ 64

section .bss
losses resq BATCH_SIZE      ; store per-sample losses

section .text
_start:
    xor rbx, rbx              ; sample index = 0
    
.batch_loop:
    ; load image and label
    mov rsi, rbx              ; index
    lea rdi, [rel img]        ; buffer for image
    call load_mnist_image

    mov rsi, rbx              ; index
    lea rdi, [rel label]      ; buffer for label
    call load_mnist_label

    ; Forward pass
    lea rdi, [rel img]
    lea rsi, [rel W1]
    lea rdx, [rel b1]
    lea r8,  [rel h1]
    mov rcx, 128
    mov r9, 784
    mov r14, 1
    call layer_forward

    lea rdi, [rel h1]
    lea rsi, [rel W2]
    lea rdx, [rel b2]
    lea r8,  [rel h2]
    mov rcx, 64
    mov r9, 128
    mov r14, 0
    call layer_forward

    lea rdi, [rel h2]
    lea rsi, [rel W3]
    lea rdx, [rel b3]
    lea r8,  [rel o]
    mov rcx, 10
    mov r9, 64
    mov r14, 0
    call layer_forward

    ; Next sample
    inc rbx
    cmp rbx, BATCH_SIZE
    jl .batch_loop

    ; exit
    mov rax, 60
    xor rdi, rdi
    syscall
