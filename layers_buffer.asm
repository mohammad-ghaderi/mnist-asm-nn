global z1, h1, z2, h2, o

section .bss
z1 resq 128      ; pre-activation hidden layer 1
h1 resq 128      ; activation hidden layer 1 (ReLU)
z2 resq 64       ; pre-activation hidden layer 2
h2 resq 64       ; activation hidden layer 2 (ReLU)
o  resq 10       ; output logits