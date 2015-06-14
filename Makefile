NASM = nasm
LD = ld

AFLAGS = -f elf32 -ggdb
LFLAGS = -melf_i386 -nostdlib -T linker.ld

SOURCES = $(wildcard *.asm)
OBJECTS = $(SOURCES:%.asm=%.o)

tetrasm.elf: linker.ld $(OBJECTS)
	$(LD) $(LFLAGS) $^ -o $@

%.o: %.asm
	$(NASM) $(AFLAGS) $^ -o $@

clean:
	rm -rf tetrasm.elf tetrasm.o

QEMU = qemu-system-i386
QFLAGS =

qemu: tetrasm.elf
	$(QEMU) $(QFLAGS) -kernel $<

.PHONY: clean qemu
