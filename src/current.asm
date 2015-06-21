%include "well.mac"

section .data

global current_offset
current_offset dw 0

global current_coords
current_coords:
current_x db 0
current_y db 0

section .text

extern tetrominoes
extern bag_pop
extern draw

; current_spawn()
; Spawn the next tetromino from the bag and place it at the top of the well.
global current_spawn
current_spawn:
  call bag_pop
  mov [current_offset], ax
  mov word [current_coords], WELL_WIDTH / 2 - 4
  ret

; current_draw()
; Draw the current tetromino inside the well.
global current_draw
current_draw:
  ; Offset coordinates into the well and add dimensions for draw.
  movzx eax, word [current_coords]
  shl eax, 16
  add eax, WELL_Y << 24 | WELL_X << 16 | 0x0408

  movzx edx, word [current_offset]
  add edx, tetrominoes

  push eax
  push edx
  call draw

  add esp, 8

  ret
