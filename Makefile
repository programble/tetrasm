NASM = nasm
LD = ld

AFLAGS = -f elf32 -ggdb
LFLAGS = -melf_i386 -nostdlib -T linker.ld

SOURCES = $(wildcard src/*.asm)
OBJECTS = $(SOURCES:%.asm=%.o)

tetrasm.elf: linker.ld $(OBJECTS)
	$(LD) $(LFLAGS) $^ -o $@

%.o: %.asm
	$(NASM) $(AFLAGS) $^ -o $@

clean:
	rm -rf tetrasm.elf $(OBJECTS)

QEMU = qemu-system-i386
QFLAGS =

qemu: tetrasm.elf
	$(QEMU) $(QFLAGS) -kernel $<

.PHONY: clean qemu
