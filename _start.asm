global _start
extern load_mnist_image, load_mnist_label
extern layer_forward, softmax, neg_log
extern img, label
extern W1, b1, W2, b2, W3, b3
extern z1, h1, z2, h2, o
extern dW1, dbias1, dW2, dbias2, dW3, dbias3
extern grad_z1, grad_h1, grad_z2, grad_h2, grad_o
extern accumulate_gradients


BATCH_SIZE equ 64
EPOCHS equ 10

section .bss
losses resq BATCH_SIZE      ; store per-sample losses

section .text
_start:
    mov r15, EPOCHS         ; number of epochs
    
.epoch_loop:
    xor rbx, rbx              ; sample index = 0
    push r15
    
.batch_loop:
    ; load image and label
    push rbx

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

    ; Softmax
    lea rdi, [rel o]
    lea rsi, [rel o]
    mov rcx, 10
    call softmax

    ; Loss = -log(p[label])
    movzx rdi, byte [rel label]
    movsd xmm0, [o + rdi*8]
    call neg_log
    pop rbx
    movsd [losses + rbx*8], xmm0

    call accumulate_gradients  ; Accumulate gradients for this sample

    ; Next sample
    inc rbx
    cmp rbx, BATCH_SIZE
    jl .batch_loop

    ; end of BATCH

    ; Average loss for batch
    pxor xmm1, xmm1
    xor rbx, rbx
.sum_loop:
    addsd xmm1, [losses + rbx*8]
    inc rbx
    cmp rbx, BATCH_SIZE
    jl .sum_loop

    mov rax, BATCH_SIZE
    cvtsi2sd xmm0, rax
    divsd xmm1, xmm0           ; avg loss in xmm1
    movapd xmm0, xmm1

    ; next epoch
    pop r15
    dec r15
    jnz .epoch_loop

    ; exit
    mov rax, 60
    xor rdi, rdi
    syscall
