all: testUDlong

uDlong.o: uDlong.asm
	nasm -f elf64 -g -F dwarf uDlong.asm

testUDlong: testUDlong.o uDlong.o
	gcc -o testUDlong testUDlong.o uDlong.o

testUDlong.o: testUDlong.asm
	nasm -f elf64 -g -F dwarf testUDlong.asm

