global img
global label
global img_float

section .bss
img   resb 784   ; 28x28 image
img_float resd 784     ; 28x28 image converted to float32
label resb 1     ; single label
