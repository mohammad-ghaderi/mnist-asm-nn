global img
global label, labels
global img_float

section .bss
img   resb 784*60000   ; 60000 number of 28x28 images (would be used for test data too, whcih is 10000)
img_float resd 784     ; 28x28 image converted to float32
label resb 1     ; single label
labels resb 60000