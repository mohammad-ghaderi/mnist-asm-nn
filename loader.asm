global load_mnist_image
global load_mnist_label

extern img
extern label

section .text

; rsi = image index (0-based)
load_mnist_image:
    push rbp
    push r12
    push r13
    mov rbp, rsp

    mov r12, rsi

    mov rax, 2        ; open images file
    mov rdi, img_file ; address of filename
    mov rsi, 0        ; O_RDONLY
    syscall       
    mov rbx, rax      ; fd
    ; skip header
    mov rax, 8        ; lseek
    mov rdi, rbx
    mov rsi, r12      ; image index
    imul rsi, 784     ; image offset
    add rsi, 16       ; skip 16-byte header
    mov rdx, 0
    syscall

    ; read 784 bytes
    mov rax, 0  
    mov rdi, rbx
    lea rsi, [rel img]
    mov rdx, 784
    syscall

    ; close
    mov rax, 3       
    mov rdi, rbx
    syscall

    ; Convert to doubles
    lea rdi, [rel img]        ; source (bytes)
    lea rsi, [rel img_double] ; destination (doubles)
    mov rcx, 784
    call convert_img_to_double

    pop r13
    pop r12
    pop rbp
    ret

; rsi = label index (0-based)
load_mnist_label:
    ; open labels file
    mov rax, 2
    mov rdi, label_file
    mov rsi, 0
    syscall
    mov rbx, rax
    ; skip header (8 bytes)
    mov rax, 8
    mov rdi, rbx
    mov rsi, rsi      ; label index
    add rsi, 8        ; skip 8-byte header
    mov rdx, 0
    syscall

    ; read 1 byte
    mov rax, 0
    mov rdi, rbx
    lea rsi, [rel label]
    mov rdx, 1
    syscall

    ; close
    mov rax, 3
    mov rdi, rbx
    syscall
    ret

convert_img_to_double:
    ; Converts unsigned byte image to doubles
    ; rdi = source byte array
    ; rsi = destination double array  
    ; rcx = number of elements (784)
    push rbp
    mov rbp, rsp
    xor rax, rax
    
.convert_loop:
    movzx r8, byte [rdi + rax]    ; load unsigned byte
    cvtsi2sd xmm0, r8             ; convert to double
    movsd [rsi + rax*8], xmm0     ; store as double
    inc rax
    cmp rax, rcx
    jl .convert_loop
    
    pop rbp
    ret
    

section .data
img_file db "dataset/train-images.idx3-ubyte",0
label_file db "dataset/train-labels.idx1-ubyte",0
