global softmax
extern exp_double

section .text

; softmax(input, output, length)
; rdi = input (float32[])
; rsi = output (float32[])
; rcx = length
softmax:
    push rbx
    push r12
    mov r12, rcx          ; save length
    
    ;Find maximum value
    movss xmm7, [rdi]     ; max = input[0]
    xor rbx, rbx
.find_max_loop:
    movss xmm0, [rdi + rbx*4]
    maxss xmm7, xmm0      ; xmm7 = max(xmm7, xmm0)
    inc rbx
    cmp rbx, rcx
    jl .find_max_loop
    
    ; Compute exp(input[i] - max) and sum
    pxor xmm6, xmm6       ; sum = 0.0
    xor rbx, rbx
.loop_exp:
    movss xmm0, [rdi + rbx*4]
    subss xmm0, xmm7      ; xmm0 = input[i] - max

    cvtss2sd xmm0, xmm0    ; float -> double
    call exp_double       ; xmm0 = exp(input[i] - max)
    cvtsd2ss xmm0, xmm0    ; double -> float

    movss [rsi + rbx*4], xmm0
    addss xmm6, xmm0      ; accumulate sum
    inc rbx
    cmp rbx, r12
    jl .loop_exp
    
    ; Normalize
    xor rbx, rbx
.normalize_loop:
    movss xmm0, [rsi + rbx*4]
    divss xmm0, xmm6      ; xmm0 /= sum
    movss [rsi + rbx*4], xmm0
    inc rbx
    cmp rbx, r12
    jl .normalize_loop
    
    pop r12
    pop rbx
    ret