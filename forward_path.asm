global layer_forward
extern dot_product
extern relu

section .text
; layer_forward(x, W, b, out, num_neurons, input_size)
; rdi = pointer to input vector
; rsi = pointer to weights matrix (flattened row-major)
; rdx = pointer to bias vector
; r8  = pointer to output buffer
; rcx = num_neurons
; r9  = input_size

layer_forward:
    xor r10, r10              ; neuron index
.layer_loop:
    ; compute offset = r10 * r9 * 8
    mov rax, r10
    imul rax, r9
    shl rax, 3
    lea r11, [rsi + rax]      ; W_row = W + offset

    ; bias pointer = b + r10*8
    mov rax, r10
    shl rax, 3
    lea r12, [rdx + rax]

    ; output pointer = out + r10*8
    lea r13, [r8 + rax]

    push rsi
    push rdx
    push rcx

    ; call dot_product
    mov rdi, rdi     ; x
    mov rsi, r11     ; W_row
    mov rcx, r9      ; input_size
    mov rdx, r12     ; bias

    call dot_product

    ; apply relu
    call relu

    movsd [r13], xmm0

    pop rcx
    pop rdx
    pop rsi

    inc r10
    cmp r10, rcx
    jl .layer_loop
    ret
