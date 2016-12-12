all: main

bigInteger.o: bigInteger.asm
	nasm -f elf64 -g -F dwarf bigInteger.asm

main: main.o bigInteger.o
	gcc -o main main.o bigInteger.o

main.o: main.asm
	nasm -f elf64 -g -F dwarf main.asm

