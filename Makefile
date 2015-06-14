TARGET = debug

NASM = nasm
LD = ld

AFLAGS = -f elf32
LFLAGS = -melf_i386 -nostdlib -T linker.ld

ifeq ($(TARGET),debug)
  override AFLAGS += -ggdb
endif

KERNEL = tetrasm.elf

SOURCES = $(wildcard src/*.asm)
OBJECTS = $(SOURCES:%.asm=%.o)

$(KERNEL): linker.ld $(OBJECTS)
	$(LD) $(LFLAGS) $^ -o $@

%.o: %.asm
	$(NASM) $(AFLAGS) $^ -o $@

clean:
	rm -rf $(KERNEL) $(OBJECTS)

QEMU = qemu-system-i386
QFLAGS =

ifeq ($(TARGET),debug)
  override QFLAGS += -s -S
endif

qemu: $(KERNEL)
	$(QEMU) $(QFLAGS) -kernel $<

GDB = gdb
GFLAGS = -ex 'display/i $$pc' -ex 'target remote localhost:1234'

gdb: $(KERNEL)
	$(GDB) $(GFLAGS) $<

.PHONY: clean qemu gdb
