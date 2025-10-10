global argmax

section .text
; argmax(array, length)
; rdi = address of array (double[])
; rcx = number of elements
; returns: rax = index of maximum value
argmax:
    xor rax, rax        ; rax = best index
    xor rbx, rbx        ; rbx = loop index
    movsd xmm1, [rdi]   ; xmm1 = current max value

.loop:
    movsd xmm0, [rdi + rbx*8]
    ucomisd xmm0, xmm1
    jbe .skip_update
    movsd xmm1, xmm0
    mov rax, rbx        ; save new max index
.skip_update:
    inc rbx
    cmp rbx, rcx
    jl .loop
    ret
