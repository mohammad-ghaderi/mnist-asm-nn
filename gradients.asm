global update_weights, clear_gradients
extern W1, b1, W2, b2, W3, b3
extern dW1, dbias1, dW2, dbias2, dW3, dbias3

section .data
learning_rate dq 0.01
batch_size_inv dq 0.03125  ; 1/32

section .text

update_weights:
    ; Update weights with AVERAGED gradients using mini-batch GD
    push rbp
    mov rbp, rsp
    
    ; Average gradients and update W3 (64*10)
    mov rcx, 64*10
    xor rax, rax
.update_w3_loop:
    movss xmm0, [W3 + rax*4]    ; current weight
    movss xmm1, [dW3 + rax*4]   ; accumulated gradient
    mulss xmm1, [batch_size_inv] ; average the gradient
    mulss xmm1, [learning_rate]  ; scale by learning rate
    subss xmm0, xmm1            ; weight -= lr * (avg_gradient)
    movss [W3 + rax*4], xmm0
    inc rax
    cmp rax, rcx
    jl .update_w3_loop
    
    ; Average gradients and update b3 (10)
    mov rcx, 10
    xor rax, rax
.update_b3_loop:
    movss xmm0, [b3 + rax*4]
    movss xmm1, [dbias3 + rax*4]
    mulss xmm1, [batch_size_inv] ; average the gradient
    mulss xmm1, [learning_rate]
    subss xmm0, xmm1
    movss [b3 + rax*4], xmm0
    inc rax
    cmp rax, rcx
    jl .update_b3_loop
    
    ; Average gradients and update W2 (128*64)
    mov rcx, 128*64
    xor rax, rax
.update_w2_loop:
    movss xmm0, [W2 + rax*4]    ; current weight
    movss xmm1, [dW2 + rax*4]   ; accumulated gradient
    mulss xmm1, [batch_size_inv] ; average the gradient
    mulss xmm1, [learning_rate]  ; scale by learning rate
    subss xmm0, xmm1            ; weight -= lr * (avg_gradient)
    movss [W2 + rax*4], xmm0
    inc rax
    cmp rax, rcx
    jl .update_w2_loop
    
    ; Average gradients and update b2 (64)
    mov rcx, 64
    xor rax, rax
.update_b2_loop:
    movss xmm0, [b2 + rax*4]
    movss xmm1, [dbias2 + rax*4]
    mulss xmm1, [batch_size_inv] ; average the gradient
    mulss xmm1, [learning_rate]
    subss xmm0, xmm1
    movss [b2 + rax*4], xmm0
    inc rax
    cmp rax, rcx
    jl .update_b2_loop

    ; Average gradients and update W1 (784*128)
    mov rcx, 784*128
    xor rax, rax
.update_w1_loop:
    movss xmm0, [W1 + rax*4]    ; current weight
    movss xmm1, [dW1 + rax*4]   ; accumulated gradient
    mulss xmm1, [batch_size_inv] ; average the gradient
    mulss xmm1, [learning_rate]  ; scale by learning rate
    subss xmm0, xmm1            ; weight -= lr * (avg_gradient)
    movss [W1 + rax*4], xmm0
    inc rax
    cmp rax, rcx
    jl .update_w1_loop
    
    ; Average gradients and update b1 (128)
    mov rcx, 128
    xor rax, rax
.update_b1_loop:
    movss xmm0, [b1 + rax*4]
    movss xmm1, [dbias1 + rax*4]
    mulss xmm1, [batch_size_inv] ; average the gradient
    mulss xmm1, [learning_rate]
    subss xmm0, xmm1
    movss [b1 + rax*4], xmm0
    inc rax
    cmp rax, rcx
    jl .update_b1_loop
    
    
    pop rbp
    ret

clear_gradients:
    ; Clear all gradient accumulators
    push rbp
    mov rbp, rsp
    
    ; Clear dW1, dbias1
    mov rcx, 784*128
    xor rax, rax
.clear_dw1:
    mov dword [dW1 + rax*4], 0
    inc rax
    cmp rax, rcx
    jl .clear_dw1
    
    mov rcx, 128
    xor rax, rax
.clear_db1:
    mov dword [dbias1 + rax*4], 0
    inc rax
    cmp rax, rcx
    jl .clear_db1
    
    ; Clear dW2, dbias2
    mov rcx, 128*64
    xor rax, rax
.clear_dw2:
    mov dword [dW2 + rax*4], 0
    inc rax
    cmp rax, rcx
    jl .clear_dw2
    
    mov rcx, 64
    xor rax, rax
.clear_db2:
    mov dword [dbias2 + rax*4], 0
    inc rax
    cmp rax, rcx
    jl .clear_db2
    
    ; Clear dW3, dbias3
    mov rcx, 64*10
    xor rax, rax
.clear_dw3:
    mov dword [dW3 + rax*4], 0
    inc rax
    cmp rax, rcx
    jl .clear_dw3
    
    mov rcx, 10
    xor rax, rax
.clear_db3:
    mov dword [dbias3 + rax*4], 0
    inc rax
    cmp rax, rcx
    jl .clear_db3
    
    pop rbp
    ret