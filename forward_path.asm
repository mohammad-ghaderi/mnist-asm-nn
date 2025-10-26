global layer_forward
extern dot_product
extern relu

section .text
; layer_forward(x, W, b, out, num_neurons, input_size, use_relu)
; rdi = pointer to input vector
; rsi = pointer to weights matrix (flattened row-major)
; rdx = pointer to bias vector
; r8  = pointer to output buffer
; rcx = num_neurons
; r9  = input_size
; [rsp+8] = use_relu flag (1 = use ReLU, 0 = no activation)

layer_forward:
    push r15                  ; save r15 to use for relu flag
    mov r15, [rsp+16]         ; get use_relu flag from stack (offset +8 because we pushed r15)
    
    xor r10, r10              ; neuron index
.layer_loop:
    ; compute offset = r10 * r9 * 4
    mov rax, r10
    imul rax, r9
    shl rax, 2
    lea r11, [rsi + rax]      ; W_row = W + offset

    ; bias pointer = b + r10*4
    mov rax, r10
    shl rax, 2
    lea r12, [rdx + rax]

    ; output pointer = out + r10*4
    lea r13, [r8 + rax]

    push rsi
    push rdx
    push rcx
    push r15                  ; save relu flag

    ; call dot_product
    mov rdi, rdi     ; x
    mov rsi, r11     ; W_row
    mov rcx, r9      ; input_size
    mov rdx, r12     ; bias

    call dot_product

    pop r15                   ; relu flag
    test r15, r15             ; check if use_relu != 0
    jz .skip_relu             ; if 0, skip relu
    
    call relu                 ; if 1, apply relu
    
.skip_relu:
    movsd [r13], xmm0

    pop rcx
    pop rdx
    pop rsi

    inc r10
    cmp r10, rcx
    jl .layer_loop
    pop r15         
    ret