BUILD = debug
VERSION := $(shell git describe --tags --always || echo '?')

# Build

NASM = nasm
LD = ld

NASM_FLAGS = -f elf32 -i src/ -d VERSION=$(VERSION)
LD_FLAGS = -m elf_i386 -nostdlib -T linker.ld

ifneq (,$(findstring debug,$(BUILD)))
  override NASM_FLAGS += -g -d DEBUG
endif
ifneq (,$(findstring test,$(BUILD)))
  override NASM_FLAGS += -d TEST
endif

KERNEL = tetrasm.elf

SOURCES = $(wildcard src/*.asm)
OBJECTS = $(SOURCES:%.asm=%.o)

kernel: $(KERNEL)

$(KERNEL): linker.ld $(OBJECTS)
	$(LD) $(LD_FLAGS) $^ -o $@

%.o: %.asm
	$(NASM) $(NASM_FLAGS) $^ -o $@

# COM build

COM_NASM_FLAGS = -d COM -f bin -i src/ -d VERSION=$(VERSION)

ifneq (,$(findstring test,$(BUILD)))
  override COM_NASM_FLAGS += -d TEST
endif

COM = tetrasm.com

com: $(COM)

$(COM): src/com.asm
	$(NASM) $(COM_NASM_FLAGS) $^ -o $@

# ISO

GENISOIMAGE = genisoimage
ISO_FLAGS = -R -b boot/grub/stage2_eltorito -no-emul-boot -boot-load-size 4 -boot-info-table
STAGE2 = stage2_eltorito

ISO = tetrasm.iso

iso: $(ISO)

$(ISO): iso/boot/tetrasm.elf iso/boot/grub/stage2_eltorito iso/boot/grub/menu.lst
	$(GENISOIMAGE) $(ISO_FLAGS) -o $@ iso

iso/boot/tetrasm.elf: $(KERNEL)
	@mkdir -p iso/boot
	cp $< $@

iso/boot/grub/stage2_eltorito: $(STAGE2)
	@mkdir -p iso/boot/grub
	cp $< $@

iso/boot/grub/menu.lst: menu.lst
	@mkdir -p iso/boot/grub
	cp $< $@

clean:
	rm -rf $(ISO) iso $(COM) $(KERNEL) $(OBJECTS)

# Emulation

QEMU = qemu-system-i386
QEMU_FLAGS =

ifneq (,$(findstring debug,$(BUILD)))
  override QEMU_FLAGS += -s -S
endif

qemu: $(KERNEL)
	$(QEMU) $(QEMU_FLAGS) -kernel $<

qemu-iso: $(ISO)
	$(QEMU) $(QEMU_FLAGS) -cdrom $<

DOSBOX = dosbox
DOSBOX_FLAGS =

dosbox: $(COM)
	$(DOSBOX) $<

# Debugger

GDB = gdb
GDB_FLAGS = -ex 'set disassembly-flavor intel' -ex 'display/i $$pc' -ex 'target remote localhost:1234'

gdb: $(KERNEL)
	$(GDB) $(GDB_FLAGS) $<

-include config.mk

.PHONY: kernel com iso clean qemu qemu-iso gdb
