global load_mnist_image
global load_mnist_label

extern img
extern img_double
extern label

section .text

; rsi = image index (0-based)
load_mnist_image:
    push r15                  ; save r15 to use for train-test flag
    mov r15, [rsp+16]         ; get train-test flag from stack (offset +8 because we pushed r15)

    push rbp
    push r12
    push r13
    mov rbp, rsp

    mov r12, rsi

    mov rax, 2        ; open images file
    cmp r15, 1
    je .load_test_data
    ; load train data
    mov rdi, img_file ; address of train filename
    jmp .rest_load_data
.load_test_data:
    mov rdi, img_test_file  ; address of test filename
.rest_load_data:

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
    pop r15
    ret

; rsi = label index (0-based)
load_mnist_label:
    push r15                  ; save r15 to use for train-test flag
    mov r15, [rsp+16]         ; get train-test flag from stack (offset +8 because we pushed r15)

    push rbp
    mov rbp, rsp
    
    ; Save the index
    mov r12, rsi
    
    ; open labels file
    mov rax, 2
    cmp r15, 1
    je .load_test_label
    ; load train label
    mov rdi, label_file ; address of train label filename
    jmp .rest_load_label
.load_test_label:
    mov rdi, label_test_file  ; address of test label filename
.rest_load_label:

    mov rdi, label_file
    mov rsi, 0
    syscall
    mov rbx, rax
    
    ; Calculate file position: index + 8 (header)
    mov rax, 8        ; lseek
    mov rdi, rbx
    mov rsi, r12      ; use saved index
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
    
    pop rbp
    pop r15
    ret

convert_img_to_double:
    ; Converts unsigned byte image to doubles
    ; rdi = source byte array
    ; rsi = destination double array  
    ; rcx = number of elements (784)
    push rbp
    mov rbp, rsp
    xor rax, rax

    ; Load 255.0 constant for division
    mov r9, __float64__(255.0)
    movq xmm1, r9
    
    
.convert_loop:
    movzx r8, byte [rdi + rax]    ; load unsigned byte
    cvtsi2sd xmm0, r8             ; convert to double
    divsd xmm0, xmm1              ; divide by 255.0 to normalize
    movsd [rsi + rax*8], xmm0     ; store as double
    inc rax
    cmp rax, rcx
    jl .convert_loop
    
    pop rbp
    ret
    

section .data
img_file db "dataset/train-images.idx3-ubyte",0
label_file db "dataset/train-labels.idx1-ubyte",0
img_test_file db "dataset/t10k-images.idx3-ubyte",0
label_test_file db "dataset/t10k-labels.idx1-ubyte",0