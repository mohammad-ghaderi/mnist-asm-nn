section .data
    test1 dq 2.3456
    test2 dq 0.1234
    test3 dq 15.9876
    test4 dq -3.1415
    test5 dq 0.0
    test6 dq 123.4567

section .text
    extern print_loss
    global _start

_start:
    ; Test various loss values
    movsd xmm0, [test1]
    call print_loss
    
    movsd xmm0, [test2]
    call print_loss
    
    movsd xmm0, [test3]
    call print_loss
    
    movsd xmm0, [test4]
    call print_loss
    
    movsd xmm0, [test5]
    call print_loss
    
    movsd xmm0, [test6]
    call print_loss
    
    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall