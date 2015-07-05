%include "video.mac"
%include "well.mac"

%define hold.X (COLS / 4 - 6)
%define hold.Y 3

section .data

extern current.offset, current.coords

hold.offset dw 0

; Whether hold is available. Reset on spawn.
global hold.available?
hold.available? db 1

section .text

extern tetrominoes
extern bag.pop
extern fill, draw

; hold()
; Swap the current tetromino with the hold tetromino.
global hold
hold:
  test byte [hold.available?], 1
  jz .ret

  ; Check if there is no hold tetromino yet.
  mov ax, [hold.offset]
  test ax, ax
  jnz .swap

  call bag.pop

  .swap:
    xchg ax, [current.offset]
    ; Round down to default rotation.
    and ax, 0xFF00
    mov [hold.offset], ax

  ; Respawn tetromino.
  ; FIXME: Repeated formula.
  mov word [current.coords], well.WIDTH / 2 - 4

  and byte [hold.available?], 0

  .ret:
    ret

; hold.draw()
; Draw the hold tetromino.
global hold.draw
hold.draw:
  ; Clear previous hold tetromino.
  push dword hold.Y << 24 | hold.X << 16 | 0x0408
  push word 0
  call fill

  ; Leave coordinates and dimensions on the stack.
  add esp, 2

  ; Find sprite for hold tetromino.
  movzx eax, word [hold.offset]
  add eax, tetrominoes

  push eax
  call draw

  add esp, 8

  ret
