global outer_product_add, matrix_vector_multiply_transpose

section .text

; outer_product_add
; Computes: C += A^T × B (outer product accumulated)
; rdi = pointer to vector A (size r9)
; rsi = pointer to vector B (size rcx) 
; rdx = pointer to matrix C (r9 × rcx) - accumulated result
; r9 = size of vector A
; rcx = size of vector B
outer_product_add:
    push rbp
    mov rbp, rsp
    xor r8, r8              ; i index for vector A
.outer_loop:
    xor r10, r10            ; j index for vector B
    movsd xmm1, [rdi + r8*8] ; A[i]
    
.inner_loop:
    movsd xmm0, [rsi + r10*8] ; B[j]
    mulsd xmm0, xmm1          ; A[i] * B[j]
    
    ; Calculate matrix index: i * rcx + j
    mov rax, r8
    imul rax, rcx
    add rax, r10
    
    ; C[i,j] += A[i] * B[j]
    addsd xmm0, [rdx + rax*8]
    movsd [rdx + rax*8], xmm0
    
    inc r10
    cmp r10, rcx
    jl .inner_loop
    
    inc r8
    cmp r8, r9
    jl .outer_loop
    
    pop rbp
    ret

; matrix_vector_multiply_transpose
; Computes: y = W^T × x
; rdi = pointer to input vector x (size r9)
; rsi = pointer to matrix W (r9 × rcx) in row-major order
; rdx = pointer to output vector y (size rcx)
; r9 = number of rows in W (size of x)
; rcx = number of columns in W (size of y)
matrix_vector_multiply_transpose:
    push rbp
    mov rbp, rsp
    xor r8, r8              ; j index for output vector
.output_loop:
    pxor xmm0, xmm0         ; accumulator for y[j]
    xor r10, r10            ; i index for input vector
    
.input_loop:
    ; W is stored as W[i][j] at index i*rcx + j
    ; For transpose: we want W^T[j][i] = W[i][j]
    mov rax, r10            ; i
    imul rax, rcx           ; i * num_columns
    add rax, r8             ; i * num_columns + j
    
    movsd xmm1, [rsi + rax*8] ; W[i][j]
    movsd xmm2, [rdi + r10*8] ; x[i]
    mulsd xmm1, xmm2          ; W[i][j] * x[i]
    addsd xmm0, xmm1          ; accumulate
    
    inc r10
    cmp r10, r9
    jl .input_loop
    
    ; Store result y[j]
    movsd [rdx + r8*8], xmm0
    
    inc r8
    cmp r8, rcx
    jl .output_loop
    
    pop rbp
    ret