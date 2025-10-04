section .data
    newline db 10

section .bss
    buffer resb 32

section .text
global print_loss

print_loss:
    push rbp
    mov rbp, rsp
    
    ; Store xmm0 value
    movsd [rsp-8], xmm0
    sub rsp, 8
    
    ; Convert the double to string
    mov rdi, buffer
    movsd xmm0, [rsp]
    call double_to_string
    
    ; Print the string
    mov rsi, buffer
    call string_length      ; returns length in rax
    mov rdx, rax            ; length in rdx
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout  
    syscall
    
    ; Print newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall
    
    add rsp, 8
    pop rbp
    ret

; Convert double in xmm0 to string in rdi
double_to_string:
    push rbp
    mov rbp, rsp
    
    ; Check if negative
    pxor xmm1, xmm1
    comisd xmm0, xmm1
    jae .not_negative
    mov byte [rdi], '-'
    inc rdi
    ; Make positive
    subsd xmm1, xmm0
    movsd xmm0, xmm1
.not_negative:
    
    ; Get integer part
    cvttsd2si rax, xmm0
    push rax                 ; save integer part
    
    ; Convert integer part to string
    call int_to_string
    
    ; Add decimal point
    mov byte [rdi], '.'
    inc rdi
    
    ; Get fractional part: (original - integer) * 10000
    cvtsi2sd xmm1, qword [rsp]  ; load integer as double
    movsd xmm2, xmm0
    subsd xmm2, xmm1            ; fractional part
    mulsd xmm2, [scale]
    cvttsd2si rax, xmm2         ; fractional part as integer
    
    ; Convert fractional part (4 digits)
    mov rcx, 4
.frac_loop:
    mov rbx, 10
    xor rdx, rdx
    div rbx                 ; rax = quotient, rdx = remainder
    add dl, '0'
    mov [rdi + rcx - 1], dl
    loop .frac_loop
    
    add rdi, 4
    mov byte [rdi], 0       ; null terminate
    
    pop rax                 ; clean stack
    pop rbp
    ret

; Convert integer in rax to string at current rdi position
int_to_string:
    push rbx
    push rcx
    push rdx
    
    mov rbx, 10
    test rax, rax
    jnz .not_zero
    ; Handle zero case
    mov byte [rdi], '0'
    inc rdi
    jmp .done
    
.not_zero:
    ; Count digits by pushing to stack
    mov rcx, 0
.digit_loop:
    xor rdx, rdx
    div rbx
    add dl, '0'
    push rdx
    inc rcx
    test rax, rax
    jnz .digit_loop
    
    ; Pop digits into buffer
.pop_loop:
    pop rax
    mov [rdi], al
    inc rdi
    loop .pop_loop
    
.done:
    pop rdx
    pop rcx
    pop rbx
    ret

; Get length of null-terminated string in rsi
string_length:
    xor rax, rax
.count:
    cmp byte [rsi + rax], 0
    je .done
    inc rax
    jmp .count
.done:
    ret

section .data
scale dq 10000.0