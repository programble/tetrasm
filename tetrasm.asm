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

section .text
global boot
boot:
  mov esp, stack + STACK_SIZE
  mov ebp, esp

main:
  mov byte [0xB8000], 'H'

hang:
  hlt
  jmp hang
