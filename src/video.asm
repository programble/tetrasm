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

  ; Duplicate yx for putc.
  push word [ebp + 14] ; x, y

  ; Load string pointer for iteration.
  mov esi, [ebp + 8] ; string

  .loop:
    cmp byte [esi], 0
    je .ret

    ; Apply attributes.
    movzx ax, byte [esi]
    or ax, [ebp + 12] ; attributes

    ; Call putc, but leave coordinates on the stack.
    push ax
    call putc
    add esp, 2

    ; Increment pointer and coordinates.
    inc esi
    inc word [esp]
    jmp .loop

  .ret:
    add esp, 2 ; x, y for putc
    pop esi
    mov esp, ebp
    pop ebp
    ret

; clear(word attributes)
; Clear the screen by filling it with spaces with attributes.
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
  .loop:
    mov [edi], edx
    add edi, 4

    cmp edi, VRAM + COLS * ROWS * 2
    jne .loop

  pop edi
  mov esp, ebp
  pop ebp
  ret
