global outer_product_add, matrix_vector_multiply

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
    push r12                ; callee-saved used below
    push r13
    push r14

    xor r8, r8              ; i index for vector A
.outer_loop:    
    cmp r8, r9
    jae .outer_end

    vbroadcastss zmm0, dword [rdi + r8*4]   ; zmm0 = A[i]

    mov r12, r8
    imul r12, rcx
    shl r12, 2
    add r12, rdx          ; r12 = &C[i,0]

    xor r10, r10            ; j index for vector B

    cmp     rcx, 16
    jb      .tail_loop
    
.inner_loop:
    vmovups zmm1, [rsi + r10*4]        ; load B[j..j+15]
    vmovups zmm2, [r12  + r10*4]       ; load C[i, j..J+15]

    ; zmm2 += zmm0 * zmm1  (C += A[i] * B[j..j+15])
    vfmadd231ps zmm2, zmm0, zmm1
    vmovups [r12 + r10*4], zmm2        ; updated C row

    add r10, 16
    mov r11, rcx
    sub r11, r10
    cmp r11, 16
    jae .inner_loop

.tail_loop:
    movss   xmm0, dword [rdi + r8*4]   ; A[i]

.tail_inner_loop:
    cmp     r10, rcx
    jge     .next_outer_i

    movss   xmm1, dword [rsi + r10*4]  ; B[j]
    mulss   xmm1, xmm0                 ; A[i] * B[j]

    ; load C[i,j], add and store
    movss   xmm2, dword [r12 + r10*4]
    addss   xmm2, xmm1
    movss   dword [r12 + r10*4], xmm2

    inc     r10
    jmp     .tail_inner_loop

.next_outer_i:
    inc     r8
    jmp     .outer_loop

.outer_end:
    pop     r14
    pop     r13
    pop     r12
    pop     rbp
    ret

; matrix_vector_multiply
; Computes: y = x × W  (where x is row vector, W is matrix)
; rdi = pointer to input vector x (size rcx) 
; rsi = pointer to matrix W (rcx × r9) in row-major order
; rdx = pointer to output vector y (size r9)
; rcx = number of columns in x (size of x)
; r9 = number of columns in W (size of y)
matrix_vector_multiply:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    
    xor r8, r8              ; j index for output vector
.outer_loop:
    pxor xmm0, xmm0         ; accumulator for y[j]
    xor r10, r10            ; i index for input vector
.inner_loop:
    mov rax, r10            ; i
    imul rax, r9            ; i * num_columns
    add rax, r8             ; i * num_columns + j
    movsd xmm1, [rsi + rax*8] ; W[i][j]
    movsd xmm2, [rdi + r10*8] ; x[i]
    mulsd xmm1, xmm2          ; x[i] * W[i][j]
    addsd xmm0, xmm1          ; accumulate
    inc r10
    cmp r10, rcx
    jl .inner_loop
    movsd [rdx + r8*8], xmm0
    inc r8
    cmp r8, r9
    jl .outer_loop
    
    pop r13
    pop r12
    pop rbp
    ret