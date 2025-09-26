global relu
; xmm0 = input
; output = max(0, xmm0)
relu:
    xorpd xmm1, xmm1       ; xmm1 = 0
    maxsd xmm0, xmm1
    ret
