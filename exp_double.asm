global exp_double
extern exp    ; C math library function

section .text
; input: xmm0
; output: xmm0
exp_double:
    sub rsp, 8

    push rbx
    push rsi      ; save output pointer
    push rdi      ; save input pointer
    push rcx      ; save length

    call exp

    pop rcx
    pop rdi
    pop rsi
    pop rbx
    
    add rsp, 8
    ret
