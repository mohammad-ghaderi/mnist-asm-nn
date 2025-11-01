#!/bin/bash
set -e
mkdir -p obj

echo "Building runtime-optimized MNIST..."

# Assemble with NASM optimizations
nasm -f elf64 -O1 _start.asm -o obj/_start.o
nasm -f elf64 -O1 loader.asm -o obj/loader.o
nasm -f elf64 -O1 mnist_data.asm -o obj/mnist_data.o
nasm -f elf64 -O1 layers_buffer.asm -o obj/layers_buffer.o
nasm -f elf64 -O1 layers_data.asm -o obj/layers_data.o
nasm -f elf64 -O1 dot_product.asm -o obj/dot_product.o
nasm -f elf64 -O1 exp_double.asm -o obj/exp_double.o
nasm -f elf64 -O1 neg_log.asm -o obj/neg_log.o
nasm -f elf64 -O1 softmax.asm -o obj/softmax.o
nasm -f elf64 -O1 reLU_activation.asm -o obj/reLU_activation.o
nasm -f elf64 -O1 forward_path.asm -o obj/forward_path.o
nasm -f elf64 -O1 backprop.asm -o obj/backprop.o
nasm -f elf64 -O1 matrix_ops.asm -o obj/matrix_ops.o
nasm -f elf64 -O1 gradients.asm -o obj/gradient.o
nasm -f elf64 -O1 print.asm -o obj/print.o
nasm -f elf64 -O1 argmax.asm -o obj/argmax.o

# Link with runtime optimizations
ld -o mnist_prod \
    obj/exp_double.o obj/softmax.o obj/dot_product.o obj/neg_log.o \
    obj/loader.o obj/mnist_data.o obj/layers_buffer.o obj/layers_data.o \
    obj/reLU_activation.o obj/forward_path.o obj/gradient.o obj/print.o \
    obj/argmax.o obj/matrix_ops.o obj/backprop.o obj/_start.o \
    -dynamic-linker /lib64/ld-linux-x86-64.so.2 -lc -lm \
    -O1 --strip-all --gc-sections --sort-common

echo "Runtime-optimized build complete: ./mnist_prod"