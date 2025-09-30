global update_weights, clear_gradients
extern W1, b1, W2, b2, W3, b3
extern dW1, dbias1, dW2, dbias2, dW3, dbias3

section .data
learning_rate dq 0.01
batch_size_inv dq 0.015625  ; 1/64

section .text

update_weights:
    ; Update weights with AVERAGED gradients using mini-batch GD
    push rbp
    mov rbp, rsp
    
    ; Average gradients and update W3 (64*10)
    mov rcx, 64*10
    xor rax, rax
.update_w3_loop:
    movsd xmm0, [W3 + rax*8]    ; current weight
    movsd xmm1, [dW3 + rax*8]   ; accumulated gradient
    mulsd xmm1, [batch_size_inv] ; average the gradient
    mulsd xmm1, [learning_rate]  ; scale by learning rate
    subsd xmm0, xmm1            ; weight -= lr * (avg_gradient)
    movsd [W3 + rax*8], xmm0
    inc rax
    cmp rax, rcx
    jl .update_w3_loop
    
    ; Average gradients and update b3 (10)
    mov rcx, 10
    xor rax, rax
.update_b3_loop:
    movsd xmm0, [b3 + rax*8]
    movsd xmm1, [dbias3 + rax*8]
    mulsd xmm1, [batch_size_inv] ; average the gradient
    mulsd xmm1, [learning_rate]
    subsd xmm0, xmm1
    movsd [b3 + rax*8], xmm0
    inc rax
    cmp rax, rcx
    jl .update_b3_loop
    
    ; Repeat for W2, b2, W1, b1 with the same averaging...
    ; (similar pattern for other layers)
    
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
    mov qword [dW1 + rax*8], 0
    inc rax
    cmp rax, rcx
    jl .clear_dw1
    
    mov rcx, 128
    xor rax, rax
.clear_db1:
    mov qword [dbias1 + rax*8], 0
    inc rax
    cmp rax, rcx
    jl .clear_db1
    
    ; Clear dW2, dbias2
    mov rcx, 128*64
    xor rax, rax
.clear_dw2:
    mov qword [dW2 + rax*8], 0
    inc rax
    cmp rax, rcx
    jl .clear_dw2
    
    mov rcx, 64
    xor rax, rax
.clear_db2:
    mov qword [dbias2 + rax*8], 0
    inc rax
    cmp rax, rcx
    jl .clear_db2
    
    ; Clear dW3, dbias3
    mov rcx, 64*10
    xor rax, rax
.clear_dw3:
    mov qword [dW3 + rax*8], 0
    inc rax
    cmp rax, rcx
    jl .clear_dw3
    
    mov rcx, 10
    xor rax, rax
.clear_db3:
    mov qword [dbias3 + rax*8], 0
    inc rax
    cmp rax, rcx
    jl .clear_db3
    
    pop rbp
    ret