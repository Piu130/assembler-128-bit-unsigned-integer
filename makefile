all: main

uDlong.o: uDlong.asm
	nasm -f elf64 -g -F dwarf uDlong.asm

main: main.o uDlong.o
	gcc -o main main.o uDlong.o

main.o: main.asm
	nasm -f elf64 -g -F dwarf main.asm

