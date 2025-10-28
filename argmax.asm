global argmax

section .text
; argmax(array, length)
; rdi = address of array (float[])
; rcx = number of elements
; returns: rax = index of maximum value
argmax:
    xor rax, rax        ; rax = best index
    xor rbx, rbx        ; rbx = loop index
    movss xmm1, [rdi]   ; xmm1 = current max value

.loop:
    movss xmm0, [rdi + rbx*4]
    ucomiss xmm0, xmm1
    jbe .skip_update
    movss xmm1, xmm0
    mov rax, rbx        ; save new max index
.skip_update:
    inc rbx
    cmp rbx, rcx
    jl .loop
    ret
