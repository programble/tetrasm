%include "well.mac"

section .data

extern ghost.coords
extern hold.available?

global current.offset
current.offset dw 0

global current.coords
current.coords:
.x db 0
.y db 0

section .text

extern tetrominoes
extern bag.pop
extern well.collide?, well.lock
extern draw

; current.spawn()
; Spawn the next tetromino from the bag and place it at the top of the well.
global current.spawn
current.spawn:
  call bag.pop
  mov [current.offset], ax
  mov word [current.coords], well.WIDTH / 2 - 4
  or byte [hold.available?], 1
  ret

; current.lock()
; Lock the current tetromino in the well and spawn another.
global current.lock
current.lock:
  ; Push coordinates and offset.
  push dword [current.offset]
  call well.lock
  add esp, 4

  call current.spawn

  ret

; current.left()
; Move the current tetromino left, if possible. Returns result of well_collide.
global current.left
current.left:
  ; Check if x == 0.
  push word [current.coords]
  cmp byte [esp], 0
  jne .check

  ; Return 0.
  xor eax, eax
  add esp, 2
  ret

  .check:
    ; Check for collisions to the left.
    sub byte [esp], 2
    push word [current.offset]
    call well.collide?
    jz .ret

    ; Update actual coordinates.
    sub byte [current.coords], 2

  .ret:
    add esp, 4
    ret

; current.right()
; Move the current tetromino right, if possible. Returns result of well_collide.
global current.right
current.right:
  ; Check for collisions to the right.
  push word [current.coords]
  add byte [esp], 2
  push word [current.offset]
  call well.collide?
  jz .ret

  ; Update actual coordinates.
  add byte [current.coords], 2

  .ret:
    add esp, 4
    ret

; current.down()
; Move the current tetromino down, if possible. Returns result of well_collide.
global current.down
current.down:
  ; Check for collisions one row down.
  push word [current.coords]
  inc byte [esp + 1]
  push word [current.offset]
  call well.collide?
  jz .ret

  ; Update actual coordinates.
  inc byte [current.coords + 1]

  .ret:
    add esp, 4
    ret

; current.rotate()
; Rotate the current tetromino, if possible. Returns result of well_collide.
global current.rotate
current.rotate:
  push word [current.coords]
  push word [current.offset]

  ; Rotate by moving to the next sprite.
  add word [esp], 64

  ; Check if the next sprite is a different tetromino (256-byte offsets).
  test word [esp], 0xFF
  jnz .collide

  ; Move back to the first rotation of the current tetromino.
  sub word [esp], 256

  .collide:
    call well.collide?
    jnz .update

    ; Wall kick right.
    add byte [esp + 2], 2
    call well.collide?
    jnz .update

    ; Wall kick left.
    sub byte [esp + 2], 4
    call well.collide?
    jz .ret

  ; Update actual coordinates and offset in one go.
  .update:
    mov edx, [esp]
    mov [current.offset], edx

  .ret:
    add esp, 4
    ret

; current.drop()
; Hard drop the current tetromino to where its ghost is.
global current.drop
current.drop:
  mov ax, [ghost.coords]
  mov [current.coords], ax
  call current.lock
  ret

; current.draw()
; Draw the current tetromino inside the well.
global current.draw
current.draw:
  ; Offset coordinates into the well and add dimensions for draw.
  movzx eax, word [current.coords]
  shl eax, 16
  add eax, well.Y << 24 | well.X << 16 | 0x0408

  movzx edx, word [current.offset]
  add edx, tetrominoes

  push eax
  push edx
  call draw

  add esp, 8

  ret
