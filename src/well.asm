%include "video.mac"
%include "well.mac"

section .data

well:
  ; First two rows have invisible walls.
%rep 2
  times 4 dw ' '
  times INSIDE_WIDTH dw 0
  times 4 dw ' '
%endrep

  ; Middle rows have a thin border on either side.
%rep INSIDE_HEIGHT
  dw 0, 0, 0, BG_GRAY
  times INSIDE_WIDTH dw 0
  dw BG_GRAY, 0, 0, 0
%endrep

  ; Bottom row completes the border.
  dw 0, 0, 0
  times INSIDE_WIDTH + 2 dw BG_GRAY
  dw 0, 0, 0

section .text

extern tetrominoes
extern fill, draw

; well_collide(word offset, byte x, byte y)
; Return 0 if tetromino at offset would collide at x, y.
global well_collide
well_collide:
  push ebp
  mov ebp, esp
  push esi
  push edi

  ; Find x, y in well.
  movzx eax, byte [ebp + 11] ; y
  mov edx, WELL_WIDTH
  mul edx
  movzx edx, byte [ebp + 10] ; x
  add eax, edx
  lea edi, [well + eax * 2]

  ; Load tetromino sprite.
  movzx edx, word [ebp + 8] ; offset
  lea esi, [tetrominoes + edx]

  mov ecx, 4
  .yloop:
    push ecx
    push edi

    mov ecx, 8
    .xloop:
      cmp word [edi], 0
      setne al
      cmp word [esi], 0
      setne ah
      and al, ah
      jnz .collision

      add esi, 2
      add edi, 2

      loop .xloop

    pop edi
    pop ecx

    ; Move a whole row down.
    add edi, WELL_WIDTH * 2

    loop .yloop

  ; No collision found.
  or al, 1
  jmp .ret

  .collision:
    ; Discard yloop ecx, edi.
    add esp, 8

    xor eax, eax

  .ret:
    pop edi
    pop esi
    mov esp, ebp
    pop ebp
    ret

; well_lock(word offset, byte x, byte y)
; Lock tetromino offset at x, y.
global well_lock
well_lock:
  push ebp
  mov ebp, esp
  push esi
  push edi

  ; Find x, y in well.
  movzx eax, byte [ebp + 11] ; y
  mov edx, WELL_WIDTH
  mul edx
  movzx edx, byte [ebp + 10] ; x
  add eax, edx
  lea edi, [well + eax * 2]

  ; Load tetromino sprite.
  movzx edx, word [ebp + 8] ; offset
  lea esi, [tetrominoes + edx]

  mov ecx, 4
  .yloop:
    push ecx
    push edi

    ; Copy a row into the well, skipping null words.
    mov ecx, 8
    .xloop:
      lodsw
      test ax, ax
      jz .null

      stosw
      loop .xloop
      jmp .break

      .null:
        add edi, 2
        loop .xloop

      .break:

    pop edi
    pop ecx

    ; Move a whole row down.
    add edi, WELL_WIDTH * 2

    loop .yloop

  pop edi
  pop esi
  mov esp, ebp
  pop ebp
  ret

; well_draw()
; Draw the well.
global well_draw
well_draw:
  ; Blank background at top of well.
  push dword WELL_Y << 24 | WELL_X << 16 | 2 << 8 | WELL_WIDTH
  push word ' ' | BG_BLACK
  call fill

  ; Background fill inside well.
  push dword INSIDE_Y << 24 | INSIDE_X << 16 | INSIDE_HEIGHT << 8 | INSIDE_WIDTH
  push word ':' | FG_BRIGHT | FG_BLACK
  call fill

  ; The well itself.
  push dword WELL_Y << 24 | WELL_X << 16 | WELL_HEIGHT << 8 | WELL_WIDTH
  push well
  call draw

  add esp, 20

  ret
