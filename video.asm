%include "video.mac"

%define VRAM 0xB8000

section .text

; Put character in dl with attributes in dh at x=cl, y=ch.
global putc
putc:
  ; Calculate VRAM index in eax.
  xor eax, eax
  mov al, ch
  imul eax, COLS
  add al, cl

  mov [eax * 2 + VRAM], dx
  ret

; Put null-terminated string in [esi] at x=cl, y=ch with attributes in dh.
global puts
puts:
  push esi
  push ecx
  push edx

  .cond:
    cmp byte [esi], 0
    jne .loop
    pop esi
    pop ecx
    pop edx
    ret

  .loop:
    mov dl, [esi]
    call putc
    inc esi
    inc cl
    jmp .cond

; Clear the screen with attributes in dh.
global clear
clear:
  push edx

  ; Set edx to two spaces with attributes of dh.
  mov dl, ' '
  xor eax, eax
  mov ax, dx
  shl edx, 16
  or edx, eax

  xor eax, eax
  .cond:
    cmp eax, COLS * ROWS
    jl .loop
    pop edx
    ret

  .loop:
    mov [eax * 4 + VRAM], edx
    inc eax
    jmp .cond
