%include "video.mac"
%include "well.mac"

%define well.lines.DELAY 100

section .data

well:
  ; First two rows have invisible walls.
%rep well.PAD.TOP
  times well.PAD.LEFT dw ' '
  times well.INSIDE.WIDTH dw 0
  times well.PAD.RIGHT dw ' '
%endrep

  ; Middle rows have a thin border on either side.
%rep well.INSIDE.HEIGHT
  times well.PAD.LEFT - 1 dw 0
  dw BG.GRAY
  times well.INSIDE.WIDTH dw 0
  dw BG.GRAY
  times well.PAD.RIGHT - 1 dw 0
%endrep

  ; Bottom row completes the border.
  times well.PAD.LEFT - 1 dw 0
  times well.INSIDE.WIDTH + 2 dw BG.GRAY
  times well.PAD.RIGHT - 1 dw 0

; Array of up to four memory locations of lines to clear.
well.lines dd 0, 0, 0, 0
well.lines$ dd 0

well.lines.timer dq 0

section .text

extern tetrominoes
extern score.lines
extern delay
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

; well.lines.detect()
; Detect line clears and populate well.lines.
global well.lines.detect
well.lines.detect:
  push esi
  push edi

  ; Write cleared rows into array.
  mov edi, well.lines

  ; Return if line clears already detected.
  cmp dword [edi], 0
  jne .ret

  ; Start at first inside-well row.
  mov esi, well + (well.PAD.TOP * well.WIDTH + well.PAD.LEFT) * 2

  mov ecx, well.INSIDE.HEIGHT
  .yloop:
    push ecx
    push esi

    ; Check double words at a time.
    mov ecx, well.INSIDE.WIDTH / 2
    .xloop:
      lodsd
      test eax, eax
      jz .continue
      loop .xloop

    ; Entire row was non-zero, add its memory location to the list.
    mov eax, [esp]
    stosd

  .continue:
    pop esi
    pop ecx

    ; Move down a row.
    add esi, well.WIDTH * 2

    loop .yloop

  ; Calculate number of lines detected and increase score.
  mov eax, edi
  sub eax, well.lines
  shr eax, 2
  jz .zero
  push eax
  call score.lines
  add esp, 4

  ; Zero the rest of the lines array.
  .zero:
    xor eax, eax
  .zloop:
    cmp edi, well.lines$
    je .ret
    stosd
    jmp .zloop

  .ret:
    pop edi
    pop esi
    ret

; well.lines.clear()
; Clear detected lines and move everything down.
global well.lines.clear
well.lines.clear:
  push esi
  push edi

  mov esi, well.lines

  ; Return 0 if there are no lines to clear.
  xor eax, eax
  cmp dword [esi], 0
  je .ret

  ; Wait for animation delay to elapse.
  push dword well.lines.DELAY
  push well.lines.timer
  call delay
  add esp, 8
  test eax, eax
  jz .ret

  .lloop:
    lodsd
    test eax, eax
    jz .reset

    ; Copy previous row to current row.
    push esi
    mov edi, eax
    sub eax, well.WIDTH * 2
    mov esi, eax

    .yloop:
      cmp esi, well + well.PAD.LEFT * 2
      je .break

      push esi
      push edi
      mov ecx, well.INSIDE.WIDTH / 2
      rep movsd
      pop edi
      pop esi

      ; Move one row up.
      sub esi, well.WIDTH * 2
      sub edi, well.WIDTH * 2

      jmp .yloop

  .break:
    pop esi
    jmp .lloop

  ; Zero array of detected line clears and return non-zero.
  .reset:
    mov dword [well.lines], 0
    mov dword [well.lines + 4], 0
    mov dword [well.lines + 8], 0
    mov dword [well.lines + 12], 0
    inc eax

  .ret:
    pop edi
    pop esi
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
