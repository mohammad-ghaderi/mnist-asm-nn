global neg_log
extern log

section .text
; input: xmm0
; output: xmm0 = -log(xmm0)
neg_log:
    sub rsp, 8

    push rdi       ; input pointer
    push rsi       ; output pointer
    push rcx       ; length or counter if needed
    push rdx       ; bias or temporary
    push r8        ; any other pointer used
    push r9        ; input size pointer

    call log

    ; Restore registers
    pop r9
    pop r8
    pop rdx
    pop rcx
    pop rsi
    pop rdi

    add rsp, 8
    xorpd xmm1, xmm1
    subsd xmm1, xmm0    ; xmm1 = -xmm0
    movapd xmm0, xmm1
    ret
