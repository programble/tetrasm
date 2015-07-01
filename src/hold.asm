%include "video.mac"
%include "well.mac"

%define HOLD_X (COLS / 4 - 6)
%define HOLD_Y 3

section .data

extern current_offset, current_coords

hold_offset dw 0

; Whether hold is available. Reset on spawn.
global hold_available
hold_available db 1

section .text

extern tetrominoes
extern bag_pop
extern fill, draw

; hold()
; Swap the current tetromino with the hold tetromino.
global hold
hold:
  test byte [hold_available], 1
  jz .ret

  ; Check if there is no hold tetromino yet.
  mov ax, [hold_offset]
  test ax, ax
  jnz .swap

  call bag_pop

  .swap:
    xchg ax, [current_offset]
    mov [hold_offset], ax

  ; Respawn tetromino.
  ; FIXME: Repeated formula.
  mov word [current_coords], WELL_WIDTH / 2 - 4

  and byte [hold_available], 0

  .ret:
    ret

; hold_draw()
; Draw the hold tetromino.
global hold_draw
hold_draw:
  ; Clear previous hold tetromino.
  push dword HOLD_Y << 24 | HOLD_X << 16 | 0x0408
  push word 0
  call fill

  ; Leave coordinates and dimensions on the stack.
  add esp, 2

  ; Find sprite for hold tetromino.
  movzx eax, word [hold_offset]
  add eax, tetrominoes

  push eax
  call draw

  add esp, 8

  ret
