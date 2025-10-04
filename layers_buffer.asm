global z1, h1, z2, h2, o
global dW1, dbias1, dW2, dbias2, dW3, dbias3
global grad_h1, grad_h2, grad_o

section .bss
z1 resq 128      ; pre-activation hidden layer 1
h1 resq 128      ; activation hidden layer 1 (ReLU)
z2 resq 64       ; pre-activation hidden layer 2
h2 resq 64       ; activation hidden layer 2 (ReLU)
o  resq 10       ; output logits

dW1 resq 784*128 ; gradients for W1
dbias1 resq 128     ; gradients for b1
dW2 resq 128*64  ; gradients for W2
dbias2 resq 64      ; gradients for b2
dW3 resq 64*10   ; gradients for W3
dbias3 resq 10      ; gradients for b3

grad_h1 resq 128 ; gradient for h1, i use this also as grad_z1
grad_h2 resq 64  ; gradient for h2, i use this also as grad_z2
grad_o  resq 10  ; gradient for output
