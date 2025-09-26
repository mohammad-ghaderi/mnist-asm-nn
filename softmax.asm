global softmax
extern exp_double   ; you need to implement this separately

section .text

; softmax(input, output, length)
; rdi = input (double[])
; rsi = output (double[])
; rcx = length
softmax:
    push rbx
    xor rbx, rbx
    pxor xmm7, xmm7       ; sum = 0.0

.loop_exp:
    movsd xmm0, [rdi + rbx*8]   ; load input[i]
    call exp_double            ; xmm0 = exp(input[i])
    movsd [rsi + rbx*8], xmm0  ; store temp result
    addsd xmm7, xmm0           ; accumulate sum
    inc rbx
    cmp rbx, rcx
    jl .loop_exp

    ; normalize: output[i] /= sum
    mov rdx, rbx               ; rdx = length
    xor rbx, rbx
.normalize_loop:
    movsd xmm0, [rsi + rbx*8]
    divsd xmm0, xmm7
    movsd [rsi + rbx*8], xmm0
    inc rbx
    cmp rbx, rdx
    jl .normalize_loop

    pop rbx
    ret
