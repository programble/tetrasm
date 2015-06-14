%include "video.mac"

%define VRAM 0xB8000

section .text

; putc(word char, word yx)
global putc
putc:
  push ebp
  mov ebp, esp

  ; Calculate VRAM index.
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

; puts(dword string, word attributes, word yx)
global puts
puts:
  push ebp
  mov ebp, esp
  push esi

  ; Duplicate yx for putc.
  push word [ebp + 14] ; yx

  ; Load string pointer for iteration.
  mov esi, [ebp + 8] ; string

  .cond:
    cmp byte [esi], 0
    je .ret

  .loop:
    ; Apply attributes
    movzx ax, byte [esi]
    or ax, [ebp + 12] ; attributes

    push ax
    call putc
    add esp, 2

    ; Increment pointer and coordinates
    inc esi
    inc word [esp]
    jmp .cond

  .ret:
    pop esi
    mov esp, ebp
    pop ebp
    ret

; clear(word attributes)
global clear
clear:
  push ebp
  mov ebp, esp
  push edi

  ; Set up two spaces with attributes
  movzx edx, word [ebp + 8] ; attributes
  mov dl, ' '
  mov eax, edx
  shl edx, 16
  or edx, eax

  mov edi, VRAM
  .cond:
    cmp edi, VRAM + COLS * ROWS * 2
    jg .ret
  .loop:
    mov [edi], edx
    add edi, 4
    jmp .cond

  .ret:
    pop edi
    mov esp, ebp
    pop ebp
    ret
