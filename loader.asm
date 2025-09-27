global load_mnist_image
global load_mnist_label

extern img
extern label

section .text

; rdi = pointer to image buffer
; rsi = image index (0-based)
load_mnist_image:
    mov rax, 2        ; open images file
    mov rdi, img_file ; address of filename
    mov rsi, 0        ; O_RDONLY
    syscall       
    mov rbx, rax      ; fd
    ; skip header
    mov rax, 8        ; lseek
    mov rdi, rbx
    mov rsi, rsi      ; image index
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
    ret

; rdi = pointer to label buffer
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

section .data
img_file db "dataset/train-images.idx3-ubyte",0
label_file db "dataset/train-labels.idx1-ubyte",0
