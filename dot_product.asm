global dot_product_u8
global dot_product_f64
; Computes z = Σ (W * x) + b
; rdi = pointer to input vector x
; rsi = pointer to weights row W[j]
; rcx = length of row
; rdx = pointer to bias for this neuron
; returns result in xmm0
dot_product_u8:
    xor rax, rax           ; index = 0
    pxor xmm0, xmm0        ; accumulator = 0.0
.dp_u8_loop:
    movzx r11, byte [rdi + rax]  ; unsigned byte x[i]
    cvtsi2sd xmm1, r11            ; convert integer to double
    movsd xmm2, [rsi + rax*8] ; W[j][i]
    mulsd xmm1, xmm2
    addsd xmm0, xmm1
    inc rax
    cmp rax, rcx
    jl .dp_u8_loop
    addsd xmm0, [rdx]       ; add bias
    ret

; dot_product_f64
; Computes z = Σ (W * x) + b
; x is an array of doubles (dq)
; rdi = pointer to input vector (double[])
; rsi = pointer to weights row W[j] (double[])
; rcx = length of row
; rdx = pointer to bias (double)
; returns result in xmm0 (double)
dot_product_f64:
    xor rax, rax           ; index = 0
    pxor xmm0, xmm0        ; accumulator = 0.0
.dp_f64_loop:
    movsd xmm1, [rdi + rax*8]     ; x[i] (double)
    movsd xmm2, [rsi + rax*8]     ; W[j][i]
    mulsd xmm1, xmm2
    addsd xmm0, xmm1
    inc rax
    cmp rax, rcx
    jl .dp_f64_loop
    addsd xmm0, [rdx]             ; add bias
    ret