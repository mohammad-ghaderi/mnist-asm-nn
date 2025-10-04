#!/bin/bash
set -e
mkdir -p obj

# Assemble
nasm -f elf64 -g -F dwarf _start.asm -o obj/_start.o
nasm -f elf64 -g -F dwarf loader.asm -o obj/loader.o
nasm -f elf64 -g -F dwarf mnist_data.asm -o obj/mnist_data.o
nasm -f elf64 -g -F dwarf layers_buffer.asm -o obj/layers_buffer.o
nasm -f elf64 -g -F dwarf layers_data.asm -o obj/layers_data.o
nasm -f elf64 -g -F dwarf dot_product.asm -o obj/dot_product.o
nasm -f elf64 -g -F dwarf exp_double.asm -o obj/exp_double.o
nasm -f elf64 -g -F dwarf neg_log.asm -o obj/neg_log.o
nasm -f elf64 -g -F dwarf softmax.asm -o obj/softmax.o
nasm -f elf64 -g -F dwarf reLU_activation.asm -o obj/reLU_activation.o
nasm -f elf64 -g -F dwarf forward_path.asm -o obj/forward_path.o
nasm -f elf64 -g -F dwarf backprop.asm -o obj/backprop.o
nasm -f elf64 -g -F dwarf matrix_ops.asm -o obj/matrix_ops.o
nasm -f elf64 -g -F dwarf gradients.asm -o obj/gradient.o
nasm -f elf64 -g -F dwarf print.asm -o obj/print.o

# Link
ld -o mnist obj/exp_double.o obj/softmax.o obj/dot_product.o obj/neg_log.o\
    obj/loader.o obj/mnist_data.o obj/layers_buffer.o obj/layers_data.o \
    obj/reLU_activation.o obj/forward_path.o obj/gradient.o obj/print.o \
    obj/matrix_ops.o obj/backprop.o obj/_start.o \
   -dynamic-linker /lib64/ld-linux-x86-64.so.2 -lc -lm


echo "Build complete: ./mnist"
