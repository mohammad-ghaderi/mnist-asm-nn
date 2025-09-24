#!/bin/bash
set -e
mkdir -p obj

# Assemble
nasm -f elf64 -g -F dwarf _start.asm -o obj/_start.o
nasm -f elf64 -g -F dwarf loader.asm -o obj/loader.o
nasm -f elf64 -g -F dwarf mnist_data.asm -o obj/mnist_data.o
nasm -f elf64 -g -F dwarf print.asm -o obj/print.o

# Link
ld -o mnist obj/_start.o obj/loader.o obj/mnist_data.o obj/print.o

echo "Build complete: ./mnist"
