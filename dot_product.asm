global dot_product
; dot_product
; Computes z = Σ (W * x) + b
; x is an array of doubles (dq)
; rdi = pointer to input vector (double[])
; rsi = pointer to weights row W[j] (double[])
; rcx = length of row
; rdx = pointer to bias (double)
; returns result in xmm0 (double)
dot_product:
    xor rax, rax           ; index = 0
    pxor xmm0, xmm0        ; accumulator = 0.0
.dp_loop:
    movsd xmm1, [rdi + rax*8]     ; x[i] (double)
    movsd xmm2, [rsi + rax*8]     ; W[j][i]
    mulsd xmm1, xmm2
    addsd xmm0, xmm1
    inc rax
    cmp rax, rcx
    jl .dp_loop
    addsd xmm0, [rdx]             ; add bias
    ret