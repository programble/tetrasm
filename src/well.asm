%include "video.mac"
%include "well.mac"

section .data

well:
  ; First two rows have invisible walls.
%rep 2
  times 4 dw ' '
  times well.INSIDE.WIDTH dw 0
  times 4 dw ' '
%endrep

  ; Middle rows have a thin border on either side.
%rep well.INSIDE.HEIGHT
  dw 0, 0, 0, BG.GRAY
  times well.INSIDE.WIDTH dw 0
  dw BG.GRAY, 0, 0, 0
%endrep

  ; Bottom row completes the border.
  dw 0, 0, 0
  times well.INSIDE.WIDTH + 2 dw BG.GRAY
  dw 0, 0, 0

section .text

extern tetrominoes
extern fill, draw

; well.collide?(word offset, byte x, byte y)
; Return 0 if tetromino at offset would collide at x, y.
global well.collide?
well.collide?:
  push ebp
  mov ebp, esp
  push esi
  push edi

  ; Find x, y in well.
  movzx eax, byte [ebp + 11] ; y
  mov edx, well.WIDTH
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
    add edi, well.WIDTH * 2

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

; well.lock(word offset, byte x, byte y)
; Lock tetromino offset at x, y.
global well.lock
well.lock:
  push ebp
  mov ebp, esp
  push esi
  push edi

  ; Find x, y in well.
  movzx eax, byte [ebp + 11] ; y
  mov edx, well.WIDTH
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
    add edi, well.WIDTH * 2

    loop .yloop

  pop edi
  pop esi
  mov esp, ebp
  pop ebp
  ret

; well.draw()
; Draw the well.
global well.draw
well.draw:
  ; Blank background at top of well.
  push dword well.Y << 24 | well.X << 16 | 2 << 8 | well.WIDTH
  push word ' ' | BG.BLACK
  call fill

  ; Background fill inside well.
  push dword well.INSIDE.Y << 24 | well.INSIDE.X << 16 | \
             well.INSIDE.HEIGHT << 8 | well.INSIDE.WIDTH
  push word ':' | FG.BRIGHT | FG.BLACK
  call fill

  ; The well itself.
  push dword well.Y << 24 | well.X << 16 | well.HEIGHT << 8 | well.WIDTH
  push well
  call draw

  add esp, 20

  ret
