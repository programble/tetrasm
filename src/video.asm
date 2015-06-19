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
  mov ax, [ebp + 12] ; attributes

  ; Load each character, then write each character with attributes.
  .loop:
    lodsb
    cmp al, 0
    je .ret

    stosw

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
  movzx eax, word [ebp + 8] ; char, attrs
  mov edx, eax
  shl eax, 16
  or eax, edx

  mov edi, VRAM
  mov ecx, COLS * ROWS / 2
  rep stosd

  pop edi
  mov esp, ebp
  pop ebp
  ret

; fill(byte char, byte attrs, byte width, byte height, byte x, byte y)
; Fill a rectangle width, height at x, y with char, attrs.
global fill
fill:
  push ebp
  mov ebp, esp
  push edi

  vram_index 12
  lea edi, [VRAM + eax * 2]
  mov ax, word [ebp + 8] ; char, attrs

  movzx ecx, byte [ebp + 11] ; height
  .yloop:
    ; Save iteration state and pointer to beginning of row.
    push ecx
    push edi

    ; Draw one row.
    movzx ecx, byte [ebp + 10] ; width
    rep stosw

    pop edi
    pop ecx

    ; Move a row down.
    add edi, COLS * 2
    loop .yloop

  pop edi
  mov esp, ebp
  pop ebp
  ret

; draw(dword sprite, byte width, byte height, byte x, byte y)
; Draw words pointed to by sprite as width, height at x, y. Skips null words.
global draw
draw:
  push ebp
  mov ebp, esp
  push esi
  push edi

  vram_index 14
  lea edi, [VRAM + eax * 2]
  mov esi, [ebp + 8] ; sprite

  movzx ecx, byte [ebp + 13] ; height
  .yloop:
    ; Save iteration state and pointer to beginning of row.
    push ecx
    push edi

    ; Draw one row, skipping nulls.
    movzx ecx, byte [ebp + 12] ; width
    .xloop:
      cmp word [esi], 0
      jne .movsw

      add esi, 2
      add edi, 2
      jmp .continue

      .movsw:
        movsw

      .continue:
        loop .xloop

    pop edi
    pop ecx

    ; Move a row down.
    add edi, COLS * 2
    loop .yloop

  pop edi
  pop esi
  mov esp, ebp
  pop ebp
  ret
