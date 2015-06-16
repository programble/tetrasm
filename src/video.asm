%include "video.mac"

%define VRAM 0xB8000

section .text

; putc(word char, byte x, byte y)
; Put char at x, y. To apply attributes, OR char with constants in video.mac.
global putc
putc:
  push ebp
  mov ebp, esp

  ; Calculate VRAM index = y * COLS + x.
  movzx eax, byte [ebp + 11] ; y
  mov edx, COLS
  mul edx
  movzx edx, byte [ebp + 10] ; x
  add eax, edx

  mov dx, [ebp + 8] ; char
  mov [VRAM + eax * 2], dx

  mov esp, ebp
  pop ebp
  ret

; puts(dword string, word attributes, byte x, byte y)
; Put null-terminated string at x, y with attributes.
global puts
puts:
  push ebp
  mov ebp, esp
  push esi
  push edi

  ; Calculate initial VRAM index = y * COLS + x
  movzx eax, byte [ebp + 15] ; y
  mov edx, COLS
  mul edx
  movzx edx, byte [ebp + 14] ; x
  add eax, edx

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
  .loop:
    mov [edi], edx
    add edi, 4

    cmp edi, VRAM + COLS * ROWS * 2
    jne .loop

  pop edi
  mov esp, ebp
  pop ebp
  ret
