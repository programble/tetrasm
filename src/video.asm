%include "video.mac"

%define VRAM 0xB8000

; Calculate VRAM index = y * COLS + x.
%macro vram_index 1
  movzx eax, byte [ebp + %1 + 1] ; y
  mov edx, COLS
  mul edx
  movzx edx, byte [ebp + %1] ; x
  add eax, edx
%endmacro

section .text

; putc(byte char, byte attrs, byte x, byte y)
; Put char with attrs at x, y.
global putc
putc:
  push ebp
  mov ebp, esp

  vram_index 10

  mov dx, [ebp + 8] ; char, attrs
  mov [VRAM + eax * 2], dx

  mov esp, ebp
  pop ebp
  ret

; puts(dword string, word attrs, byte x, byte y)
; Put null-terminated string at x, y with attrs.
global puts
puts:
  push ebp
  mov ebp, esp
  push esi
  push edi

  vram_index 14

  lea edi, [VRAM + eax * 2]
  mov esi, [ebp + 8] ; string

  ; Set up attributes for each character.
  mov dx, [ebp + 12] ; attributes

  .loop:
    cmp byte [esi], 0
    je .ret

    ; Write character with attributes.
    mov dl, byte [esi]
    mov [edi], dx

    inc esi
    add edi, 2
    jmp .loop

  .ret:
    pop edi
    pop esi
    mov esp, ebp
    pop ebp
    ret

; clear(byte char, byte attrs)
; Clear the screen by filling it with char and attributes.
global clear
clear:
  push ebp
  mov ebp, esp
  push edi

  ; Double up char and attrs.
  movzx edx, word [ebp + 8] ; char, attrs
  mov eax, edx
  shl edx, 16
  or edx, eax

  mov edi, VRAM
  mov ecx, COLS * ROWS / 2
  .loop:
    mov [edi], edx
    add edi, 4
    loop .loop

  pop edi
  mov esp, ebp
  pop ebp
  ret
