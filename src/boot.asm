STACK_SIZE equ 0x100

section .bss

stack resb STACK_SIZE

section .text

extern main

; Set up esp and ebp stack pointers and jump to main.
global boot
boot:
  mov esp, stack + STACK_SIZE
  mov ebp, esp
  jmp main

; Divide by zero to cause a triple fault and reset.
global reset
reset:
  mov ax, 1
  xor dl, dl
  div dl
  jmp reset

; Halt.
global halt
halt:
  hlt
  jmp halt
