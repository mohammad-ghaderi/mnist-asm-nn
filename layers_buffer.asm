global z1, h1, z2, h2, o
global dW1, dbias1, dW2, dbias2, dW3, dbias3
global grad_h1, grad_h2, grad_o

section .bss
z1 resd 128      ; pre-activation hidden layer 1
h1 resd 128      ; activation hidden layer 1 (ReLU)
z2 resd 64       ; pre-activation hidden layer 2
h2 resd 64       ; activation hidden layer 2 (ReLU)
o  resd 10       ; output logits

dW1 resd 784*128 ; gradients for W1
dbias1 resd 128     ; gradients for b1
dW2 resd 128*64  ; gradients for W2
dbias2 resd 64      ; gradients for b2
dW3 resd 64*10   ; gradients for W3
dbias3 resd 10      ; gradients for b3

grad_h1 resd 128 ; gradient for h1, i use this also as grad_z1
grad_h2 resd 64  ; gradient for h2, i use this also as grad_z2
grad_o  resd 10  ; gradient for output
