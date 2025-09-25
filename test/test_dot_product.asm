global _start
extern dot_product

section .data
x:      dq 1.0, 2.0, 3.0        ; input vector
w:      dq 0.5, -1.0, 2.0       ; weights
b:      dq 0.25                 ; bias
msg:    db "Result = ",0
newline db 10
buf:    times 32 db 0            ; buffer for number

section .text
_start:
    lea rdi, [rel x]     ; input
    lea rsi, [rel w]     ; weights
    mov rcx, 3           ; length
    lea rdx, [rel b]     ; bias
    call dot_product     ; result → xmm0


    ; Write "Result = "
    mov rax, 1
    mov rdi, 1
    lea rsi, [rel msg]
    mov rdx, 9
    syscall
    
    ; Convert result (double) to integer for quick print
    cvttsd2si rax, xmm0  ; convert double→int

    ; Convert int in RAX to ASCII string (simple)
    mov rbx, 10
    lea rsi, [rel buf+31]
    mov byte [rsi], 0Ah     ; newline
.conv_loop:
    xor rdx, rdx
    div rbx
    add dl, '0'
    dec rsi
    mov [rsi], dl
    test rax, rax
    jnz .conv_loop

    ; Print number
    mov rax, 1
    mov rdi, 1
    lea rdx, [rel buf+32]
    sub rdx, rsi
    mov rsi, rsi
    syscall

    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall
