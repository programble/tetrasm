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
extern well_collide
extern draw

; current_spawn()
; Spawn the next tetromino from the bag and place it at the top of the well.
global current_spawn
current_spawn:
  call bag_pop
  mov [current_offset], ax
  mov word [current_coords], WELL_WIDTH / 2 - 4
  ret

; current_left()
; Move the current tetromino left, if possible. Returns result of well_collide.
global current_left
current_left:
  ; Check if x == 0.
  push word [current_coords]
  cmp byte [esp], 0
  jne .check

  ; Return 0.
  xor eax, eax
  add esp, 2
  ret

  .check:
    ; Check for collisions to the left.
    dec byte [esp]
    push word [current_offset]
    call well_collide
    jz .ret

    ; Update actual coordinates.
    dec byte [current_coords]

  .ret:
    add esp, 4
    ret

; current_right()
; Move the current tetromino right, if possible. Returns result of well_collide.
global current_right
current_right:
  ; Check for collisions to the right.
  push word [current_coords]
  inc byte [esp]
  push word [current_offset]
  call well_collide
  jz .ret

  ; Update actual coordinates.
  inc byte [current_coords]

  .ret:
    add esp, 4
    ret

; current_down()
; Move the current tetromino down, if possible. Returns result of well_collide.
global current_down
current_down:
  ; Check for collisions one row down.
  push word [current_coords]
  inc byte [esp + 1]
  push word [current_offset]
  call well_collide
  jz .ret

  ; Update actual coordinates.
  inc byte [current_coords + 1]

  .ret:
    add esp, 4
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
