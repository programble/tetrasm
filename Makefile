BUILD = debug,test

NASM = nasm
LD = ld

AFLAGS = -f elf32 -i src/
LFLAGS = -melf_i386 -nostdlib -T linker.ld

ifneq (,$(findstring debug,$(BUILD)))
  override AFLAGS += -g -d DEBUG
endif
ifneq (,$(findstring test,$(BUILD)))
  override AFLAGS += -d TEST
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

ifneq (,$(findstring debug,$(BUILD)))
  override QFLAGS += -s -S
endif

qemu: $(KERNEL)
	$(QEMU) $(QFLAGS) -kernel $<

GDB = gdb
GFLAGS = -ex 'set disassembly-flavor intel' -ex 'display/i $$pc' -ex 'target remote localhost:1234'

gdb: $(KERNEL)
	$(GDB) $(GFLAGS) $<

.PHONY: clean qemu gdb
