STACK_SIZE equ 0x4000

section .bss

stack resb STACK_SIZE

section .text

extern main

global boot
boot:
  mov esp, stack + STACK_SIZE
  mov ebp, esp
  jmp main
