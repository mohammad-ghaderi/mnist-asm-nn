global _start
extern load_mnist_image, load_mnist_label
extern layer_forward, softmax, neg_log
extern img, label, img_float
extern W1, b1, W2, b2, W3, b3
extern z1, h1, z2, h2, o
extern dW1, dbias1, dW2, dbias2, dW3, dbias3
extern grad_z1, grad_h1, grad_z2, grad_h2, grad_o
extern accumulate_gradients, update_weights, clear_gradients
extern print_loss, print_epoch, print_accuracy
extern argmax


BATCH_SIZE equ 32           
EPOCHS equ 10
TOTAL_SAMPLES equ (60000 / BATCH_SIZE) * BATCH_SIZE
BATCHES_PER_EPOCH equ TOTAL_SAMPLES / BATCH_SIZE  ; 937 batches
TOTAL_SAMPLES_TEST equ 10000

section .bss
losses resd BATCH_SIZE      ; store per-sample losses

section .text
_start:
    mov r15, EPOCHS         ; number of epochs

.epoch_loop:
    push r15
    mov r14, EPOCHS + 1
    sub r14, r15
    call print_epoch
    xor r14, r14            ; batch index = 0
    
.batch_loop:
    push r14
    xor rbx, rbx              ; sample index = 0

    ; Calculate global sample index: (batch_index * BATCH_SIZE)
    mov rax, r14
    imul rax, BATCH_SIZE
    mov r13, rax            ; r13 = base index for this batch
    
.sample_loop:
    ; load image and label
    push rbx
    push r13

    ; Calculate actual sample index: base_index + sample_index
    mov rax, r13
    add rax, rbx
    mov rsi, rax            ; global sample index
    push 0                  ; 0 for train data 1 for test data
    call load_mnist_image
    add rsp, 8              ; just to pop the pushed 0 from stack

    pop r13
    pop rbx
    push rbx
    push r13

    mov rax, r13
    add rax, rbx
    mov rsi, rax            ; global sample index  
    push 0
    call load_mnist_label
    add rsp, 8              ; just to pop the pushed 0 from stack

    ; Forward pass
    lea rdi, [rel img_float]
    lea rsi, [rel W1]
    lea rdx, [rel b1]
    lea r8,  [rel h1]
    mov rcx, 128
    mov r9, 784
    push 1                     ; use_relu = true
    call layer_forward
    add rsp, 8   ; just for poping the value 1 

    lea rdi, [rel h1]
    lea rsi, [rel W2]
    lea rdx, [rel b2]
    lea r8,  [rel h2]
    mov rcx, 64
    mov r9, 128
    push 1                     ; use_relu = true
    call layer_forward
    add rsp, 8   ; just for poping the value 1 

    lea rdi, [rel h2]
    lea rsi, [rel W3]
    lea rdx, [rel b3]
    lea r8,  [rel o]
    mov rcx, 10
    mov r9, 64
    push 0                     ; use_relu = false
    call layer_forward
    add rsp, 8   ; just for poping the value 0

    ; Softmax
    lea rdi, [rel o]
    lea rsi, [rel o]
    mov rcx, 10
    call softmax

    ; Loss = -log(p[label])
    movzx rdi, byte [rel label]
    movss xmm0, [o + rdi*4]
    cvtss2sd xmm0, xmm0    ; float -> double
    call neg_log
    cvtsd2ss xmm0, xmm0    ; double -> float
    
    pop r13
    pop rbx

    movss [losses + rbx*4], xmm0

    call accumulate_gradients  ; gradients for this sample

    ; Next sample
    inc rbx
    cmp rbx, BATCH_SIZE
    jl .sample_loop

    ; end of batch

    ; Average loss for batch
    pxor xmm1, xmm1
    xor rbx, rbx
.sum_loop:
    addss xmm1, [losses + rbx*4]
    inc rbx
    cmp rbx, BATCH_SIZE
    jl .sum_loop

    mov rax, BATCH_SIZE
    cvtsi2ss xmm0, rax
    divss xmm1, xmm0           ; avg loss in xmm1
    cvtss2sd xmm0, xmm1           ; convert to double
    call print_loss

    ; update weights with averaged gradients
    call update_weights
    call clear_gradients      ; clear for next batch

    ; Next batch
    pop r14
    inc r14
    cmp r14, BATCHES_PER_EPOCH
    jl .batch_loop

    ; next epoch
    pop r15
    dec r15
    jnz .epoch_loop

    ; =========================
    ;; TEST

    ; test the model on the test data
    xor rbx, rbx ; sample index for test
    xor r12, r12 ; correct counter

.test_sample_loop:    
    mov rsi, rbx
    push r12
    push rbx

    push 1
    call load_mnist_image
    add rsp, 8              ; just to pop the pushed 1 from stack

    pop rbx
    push rbx
    mov rsi, rbx

    push 1
    call load_mnist_label
    add rsp, 8              ; just to pop the pushed 1 from stack

    ; Forward pass for TEST data
    lea rdi, [rel img_float]
    lea rsi, [rel W1]
    lea rdx, [rel b1]
    lea r8,  [rel h1]
    mov rcx, 128
    mov r9, 784
    push 1                     ; use_relu = true
    call layer_forward
    add rsp, 8   ; just for poping the value 1 

    lea rdi, [rel h1]
    lea rsi, [rel W2]
    lea rdx, [rel b2]
    lea r8,  [rel h2]
    mov rcx, 64
    mov r9, 128
    push 1                     ; use_relu = true
    call layer_forward
    add rsp, 8   ; just for poping the value 1 

    lea rdi, [rel h2]
    lea rsi, [rel W3]
    lea rdx, [rel b3]
    lea r8,  [rel o]
    mov rcx, 10
    mov r9, 64
    push 0                     ; use_relu = false
    call layer_forward
    add rsp, 8   ; just for poping the value 0

    ; Softmax
    lea rdi, [rel o]
    lea rsi, [rel o]
    mov rcx, 10
    call softmax

    ; get predicted label (argmax of o)
    lea rdi, [rel o]
    mov rcx, 10
    call argmax           ; predicted label would be stored in rax

    ; compare with true label
    pop rbx
    pop r12
    movzx rdx, byte [rel label]  ; rdx = true label
    cmp rax, rdx
    jne .no_increment
    inc r12                      ; correct++
.no_increment:
    
    inc rbx
    cmp rbx, TOTAL_SAMPLES_TEST
    jne .test_sample_loop


    ; compute accuracy
    cvtsi2sd xmm0, r12
    mov rax, TOTAL_SAMPLES_TEST
    cvtsi2sd xmm1, rax
    divsd xmm0, xmm1


    call print_accuracy ; print the accuracy saved in xmm0

    ; exit
    mov rax, 60
    xor rdi, rdi
    syscall
