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
extern puts
extern clear

main:
  mov esi, hello
  mov cx, 0
  mov dh, FG_YELLOW | BG_BLUE
  call clear
  call puts

hang:
  hlt
  jmp hang
