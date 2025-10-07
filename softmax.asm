global softmax
extern exp_double

section .text

; softmax(input, output, length)
; rdi = input (double[])
; rsi = output (double[])
; rcx = length
softmax:
    push rbx
    push r12
    mov r12, rcx          ; save length
    
    ;Find maximum value
    movsd xmm7, [rdi]     ; max = input[0]
    xor rbx, rbx
.find_max_loop:
    movsd xmm0, [rdi + rbx*8]
    maxsd xmm7, xmm0      ; xmm7 = max(xmm7, xmm0)
    inc rbx
    cmp rbx, rcx
    jl .find_max_loop
    
    ; Compute exp(input[i] - max) and sum
    pxor xmm6, xmm6       ; sum = 0.0
    xor rbx, rbx
.loop_exp:
    movsd xmm0, [rdi + rbx*8]
    subsd xmm0, xmm7      ; xmm0 = input[i] - max
    call exp_double       ; xmm0 = exp(input[i] - max)
    movsd [rsi + rbx*8], xmm0
    addsd xmm6, xmm0      ; accumulate sum
    inc rbx
    cmp rbx, r12
    jl .loop_exp
    
    ; Normalize
    xor rbx, rbx
.normalize_loop:
    movsd xmm0, [rsi + rbx*8]
    divsd xmm0, xmm6      ; xmm0 /= sum
    movsd [rsi + rbx*8], xmm0
    inc rbx
    cmp rbx, r12
    jl .normalize_loop
    
    pop r12
    pop rbx
    ret