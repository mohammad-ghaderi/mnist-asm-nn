global accumulate_gradients, relu_backward, softmax_cross_entropy_backward
extern img_double, label, h1, h2, o, z1, z2
extern W1, W2, W3
extern dW1, dbias1, dW2, dbias2, dW3, dbias3
extern grad_h1, grad_h2, grad_o
extern outer_product_add, matrix_vector_multiply

section .data
one dq 1.0
batch_size_inv dq 0.015625  ; 1/64

section .text

accumulate_gradients:
    push rbp
    mov rbp, rsp
    
    ; BACKPROPAGATION 

    ; Output layer gradient (softmax + cross entropy)
    lea rdi, [rel o]          ; probabilities
    lea rsi, [rel label]      ; true label
    lea rdx, [rel grad_o]     ; gradient output
    mov rcx, 10
    call softmax_cross_entropy_backward

    ; Layer 3 gradients (W3, b3)
    ; dW3 += grad_o^T * h2
    lea rdi, [rel grad_o]     ; gradient from output
    lea rsi, [rel h2]         ; input to layer 3
    lea rdx, [rel dW3]        ; gradient for W3
    mov rcx, 10               ; output size
    mov r9, 64                ; input size
    call outer_product_add

    ; dbias3 += grad_o
    mov rcx, 10
    xor rax, rax
.accumulate_db3_loop:
    movsd xmm0, [grad_o + rax*8]
    addsd xmm0, [dbias3 + rax*8]
    movsd [dbias3 + rax*8], xmm0
    inc rax
    cmp rax, rcx
    jl .accumulate_db3_loop

    ; grad_h2 = grad_o * W3
    lea rdi, [rel grad_o]     ; gradient from output
    lea rsi, [rel W3]         ; weights
    lea rdx, [rel grad_h2]    ; gradient for h2
    mov rcx, 10               ; grad_o size
    mov r9, 64                ; W3 columns
    call matrix_vector_multiply

    ; Layer 2 gradients with ReLU
    lea rdi, [rel h2]         ; pre-activation
    lea rsi, [rel grad_h2]    ; gradient from above
    mov rcx, 64               ; size
    call relu_backward         ; result in grad_h2 (now it's grad_z2)

    ; dW2 += grad_z2^T * h1
    lea rdi, [rel grad_h2]    ; gradient (grad_z2) (size 64)
    lea rsi, [rel h1]         ; input to layer 2 (size 128)
    lea rdx, [rel dW2]        ; gradient for W2
    mov rcx, 64               ; output size
    mov r9, 128               ; input size
    call outer_product_add

    ; dbias2 += grad_z2
    mov rcx, 64
    xor rax, rax
.accumulate_db2_loop:
    movsd xmm0, [grad_h2 + rax*8]  ; grad_z2
    addsd xmm0, [dbias2 + rax*8]
    movsd [dbias2 + rax*8], xmm0
    inc rax
    cmp rax, rcx
    jl .accumulate_db2_loop

    ; grad_h1 = grad_z2 * W2
    lea rdi, [rel grad_h2]    ; gradient (grad_z2)
    lea rsi, [rel W2]         ; weights
    lea rdx, [rel grad_h1]    ; gradient for h1
    mov rcx, 64               ; grad_z2 size
    mov r9, 128               ; W2 columns
    call matrix_vector_multiply

    ; Layer 1 gradients with ReLU
    lea rdi, [rel h1]         ; pre-activation
    lea rsi, [rel grad_h1]    ; gradient from above
    mov rcx, 128              ; size
    call relu_backward         ; result in grad_h1 (now it's grad_z1)

    ; dW1 += grad_z1^T * img
    lea rdi, [rel grad_h1]    ; gradient (grad_z1)
    lea rsi, [rel img_double] ; input image (size 784)
    lea rdx, [rel dW1]        ; gradient for W1
    mov r9, 128               ; size of grad_z1
    mov rcx, 784              ; size of img
    call outer_product_add

    ; dbias1 += grad_z1
    mov rcx, 128
    xor rax, rax
.accumulate_db1_loop:
    movsd xmm0, [grad_h1 + rax*8]  ; grad_z1
    addsd xmm0, [dbias1 + rax*8]
    movsd [dbias1 + rax*8], xmm0
    inc rax
    cmp rax, rcx
    jl .accumulate_db1_loop

    pop rbp
    ret

relu_backward:
    ; rdi = pre-activation z, rsi = gradient from above, rcx = size
    push rbp
    mov rbp, rsp
    xor rax, rax
.relu_backward_loop:
    movsd xmm0, [rdi + rax*8]  ; z[i]
    xorpd xmm1, xmm1
    comisd xmm0, xmm1
    jbe .zero_grad
    movsd xmm0, [rsi + rax*8]  ; gradient from above
    jmp .store_grad
.zero_grad:
    xorpd xmm0, xmm0
.store_grad:
    movsd [rsi + rax*8], xmm0
    inc rax
    cmp rax, rcx
    jl .relu_backward_loop
    pop rbp
    ret

softmax_cross_entropy_backward:
    ; rdi = output probabilities, rsi = true label, rdx = gradient output
    ; rcx = num_classes
    push rbp
    mov rbp, rsp
    
    movzx rax, byte [rsi]      ; true label
    xor r8, r8
.softmax_grad_loop:
    movsd xmm0, [rdi + r8*8]   ; p_i
    cmp r8, rax
    jne .not_true_class
    subsd xmm0, [rel one]
    jmp .store_grad
.not_true_class:
.store_grad:
    movsd [rdx + r8*8], xmm0
    inc r8
    cmp r8, rcx
    jl .softmax_grad_loop
    pop rbp
    ret