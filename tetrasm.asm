section .multiboot
MB_MAGIC equ 0x1BADB002
MB_FLAGS equ 0x0
MB_CHECKSUM equ -(MB_MAGIC + MB_FLAGS)
header:
  dd MB_MAGIC
  dd MB_FLAGS
  dd MB_CHECKSUM

section .bss
STACK_SIZE equ 0x4000
stack resb STACK_SIZE

section .data
hello db 'Hello, World!', 0

section .text
global boot
boot:
  mov esp, stack + STACK_SIZE
  mov ebp, esp

%include "video.mac"
extern clear
extern putc
extern puts
extern itoa

main:
  push BG_GREEN
  call clear
  add esp, 2

  push word 1 << 8 | 1
  push word 'H' | FG_BRIGHT | FG_GRAY | BG_BLACK
  call putc
  add esp, 4

  push word 3 << 8 | 3
  push word FG_BRIGHT | FG_BLUE | BG_BLUE
  push hello
  call puts
  add esp, 8

  push word 10 << 8 | 2
  push dword 42
  call itoa
  add esp, 6

  push word 4 << 8 | 1
  push word FG_BLACK | BG_GREEN
  push eax
  call puts
  add esp, 8

hang:
  hlt
  jmp hang
