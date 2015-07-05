%define stack.SIZE 0x100

section .bss

stack resb stack.SIZE

section .text

extern main

; Set up stack pointers, initialize the FPU and jump to main.
global boot
boot:
  mov esp, stack + stack.SIZE
  mov ebp, esp
  fninit
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
