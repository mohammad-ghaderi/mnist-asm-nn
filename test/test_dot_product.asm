global _start
extern dot_product
default rel
section .data
    x_vals:  dd 1.0,2.0,3.0,4.0,5.0,6.0,7.0,8.0,9.0,10.0, \
                  11.0,12.0,13.0,14.0,15.0,16.0,17.0,18.0,19.0,20.0, \
                  21.0,22.0,23.0,24.0,25.0,26.0,27.0,28.0,29.0,30.0, \
                  31.0,32.0,33.0,34.0,35.0,36.0,37.0,38.0,39.0,40.0
    w_vals:  dd 0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5, \
                  0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5, \
                  0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5, \
                  0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5
    bias:    dd 1.0
    ress:  dd 2.3                 ; will store the dot product ress

section .text
_start:
    lea   rdi, [rel x_vals]        ; rdi = &x_vals
    lea   rsi, [rel w_vals]        ; rsi = &w_vals
    mov   rcx, 40                  ; length = 40
    lea   rdx, [rel bias]          ; rdx = &bias

    call  dot_product              ; ress in xmm0

    movss [rel ress], xmm0


    mov   rax, 60                  ; syscall: exit
    xor   rdi, rdi     
    syscall
