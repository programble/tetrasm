%include "well.mac"

section .data

extern ghost_coords

global current_offset
current_offset dw 0

global current_coords
current_coords:
current_x db 0
current_y db 0

section .text

extern tetrominoes
extern bag_pop
extern well_collide, well_lock
extern draw

; current_spawn()
; Spawn the next tetromino from the bag and place it at the top of the well.
global current_spawn
current_spawn:
  call bag_pop
  mov [current_offset], ax
  mov word [current_coords], WELL_WIDTH / 2 - 4
  ret

; current_lock()
; Lock the current tetromino in the well and spawn another.
global current_lock
current_lock:
  ; Push coordinates and offset.
  push dword [current_offset]
  call well_lock
  add esp, 4

  call current_spawn

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
    sub byte [esp], 2
    push word [current_offset]
    call well_collide
    jz .ret

    ; Update actual coordinates.
    sub byte [current_coords], 2

  .ret:
    add esp, 4
    ret

; current_right()
; Move the current tetromino right, if possible. Returns result of well_collide.
global current_right
current_right:
  ; Check for collisions to the right.
  push word [current_coords]
  add byte [esp], 2
  push word [current_offset]
  call well_collide
  jz .ret

  ; Update actual coordinates.
  add byte [current_coords], 2

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

; current_rotate()
; Rotate the current tetromino, if possible. Returns result of well_collide.
global current_rotate
current_rotate:
  push word [current_coords]
  push word [current_offset]

  ; Rotate by moving to the next sprite.
  add word [esp], 64

  ; Check if the next sprite is a different tetromino (256-byte offsets).
  mov ax, [esp]
  and ax, 0xFF
  jnz .collide

  ; Move back to the first rotation of the current tetromino.
  sub word [esp], 256

  .collide:
    call well_collide
    jnz .update

    ; Wall kick right.
    add byte [esp + 2], 2
    call well_collide
    jnz .update

    ; Wall kick left.
    sub byte [esp + 2], 4
    call well_collide
    jz .ret

  ; Update actual coordinates and offset in one go.
  .update:
    mov edx, [esp]
    mov [current_offset], edx

  .ret:
    add esp, 4
    ret

; current_drop()
; Hard drop the current tetromino to where its ghost is.
global current_drop
current_drop:
  mov ax, [ghost_coords]
  mov [current_coords], ax
  call current_lock
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
