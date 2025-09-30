global accumulate_gradients, relu_backward, softmax_cross_entropy_backward
extern img, label, h1, h2, o, z1, z2
extern W1, W2, W3
extern dW1, dbias1, dW2, dbias2, dW3, dbias3
extern grad_h1, grad_h2, grad_o
extern outer_product_add, matrix_vector_multiply_transpose

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
    ; dW3 += h2^T * grad_o
    lea rdi, [rel h2]         ; input to layer 3
    lea rsi, [rel grad_o]     ; gradient from output
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

    ; grad_h2 = W3^T * grad_o
    lea rdi, [rel grad_o]     ; gradient from output
    lea rsi, [rel W3]         ; weights
    lea rdx, [rel grad_h2]    ; gradient for h2
    mov rcx, 64               ; output size
    mov r9, 10                ; input size
    call matrix_vector_multiply_transpose

    ; Layer 2 gradients with ReLU
    ; grad_z2 = grad_h2 * relu_derivative(z2)
    lea rdi, [rel z2]         ; pre-activation
    lea rsi, [rel grad_h2]    ; gradient from above
    mov rcx, 64               ; size
    call relu_backward         ; result in grad_h2 (now it's grad_z2)
    ; we store grade_z2 in grade_h2 for memory efficiency, because we don't need grade_h2 anymore

    ; dW2 += h1^T * grad_z2
    lea rdi, [rel h1]         ; input to layer 2
    lea rsi, [rel grad_h2]    ; gradient (now grad_z2)
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

    ; grad_h1 = W2^T * grad_z2
    lea rdi, [rel grad_h2]    ; gradient (grad_z2)
    lea rsi, [rel W2]         ; weights
    lea rdx, [rel grad_h1]    ; gradient for h1
    mov rcx, 128              ; output size
    mov r9, 64                ; input size
    call matrix_vector_multiply_transpose

    ; Layer 1 gradients with ReLU
    ; grad_z1 = grad_h1 * relu_derivative(z1)
    lea rdi, [rel z1]         ; pre-activation
    lea rsi, [rel grad_h1]    ; gradient from above
    mov rcx, 128              ; size
    call relu_backward         ; result in grad_h1 (now it's grad_z1)
    ; we store grade_z1 in grade_h1 for memory efficiency, because we don't need grade_h1 anymore

    ; dW1 += input^T * grad_z1 
    lea rdi, [rel img]        ; input image -------------------------------------here is a problem img is unsigned byte not double------------------------------------
    lea rsi, [rel grad_h1]    ; gradient (now grad_z1)
    lea rdx, [rel dW1]        ; gradient for W1
    mov rcx, 128              ; output size
    mov r9, 784               ; input size
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
    ; computes gradient through ReLU: grad_z = grad_h * relu_derivative(z)
    push rbp
    mov rbp, rsp
    xor rax, rax
.relu_backward_loop:
    movsd xmm0, [rdi + rax*8]  ; z[i]
    xorpd xmm1, xmm1
    comisd xmm0, xmm1
    jbe .zero_grad
    ; z > 0: grad_z = grad_h (pass through)
    movsd xmm0, [rsi + rax*8]  ; gradient from above
    jmp .store_grad
.zero_grad:
    ; z <= 0: grad_z = 0
    xorpd xmm0, xmm0
.store_grad:
    movsd [rsi + rax*8], xmm0  ; store back to gradient array
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
    ; For true class: grad = p_i - 1
    subsd xmm0, [rel one]
    jmp .store_grad
.not_true_class:
    ; For other classes: grad = p_i
.store_grad:
    movsd [rdx + r8*8], xmm0
    inc r8
    cmp r8, rcx
    jl .softmax_grad_loop
    
    pop rbp
    ret