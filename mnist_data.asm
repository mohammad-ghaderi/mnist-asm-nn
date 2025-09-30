global img
global label
global img_double

section .bss
img   resb 784   ; 28x28 image
img_double resq 784     ; 28x28 image converted to doubles
label resb 1     ; single label
