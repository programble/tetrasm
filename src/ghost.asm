%include "well.mac"

section .data

extern tetrominoes
extern current_offset, current_coords

ghost_sprite times 64 db 0

ghost_coords dw 0

section .text

extern well_collide
extern draw

; ghost_update()
; Update the ghost sprite and coords from the current tetromino.
global ghost_update
ghost_update:
  push esi
  push edi

  ; Copy current tetromino sprite into ghost sprite.
  movzx esi, word [current_offset]
  add esi, tetrominoes
  mov edi, ghost_sprite
  mov ecx, 16
  rep movsd

  ; Remove background color and add bright to ghost sprite.
  mov edi, ghost_sprite
  mov ecx, 16
  .sloop:
    and dword [edi], 0x0FFF0FFF
    ;or dword [edi], FG_BRIGHT << 16 | FG_BRIGHT
    add edi, 4
    loop .sloop

  ; Start at current tetromino coords.
  push word [current_coords]
  push word [current_offset]

  ; Move down until there is a collision.
  .cloop:
    call well_collide
    jz .update

    inc byte [esp + 3]
    jmp .cloop

  ; Update actual ghost coords (one less than where the collision was).
  .update:
    mov ax, [esp + 2]
    dec ah
    mov [ghost_coords], ax

  add esp, 4
  pop edi
  pop esi
  ret

; ghost_draw()
; Draw the ghost.
global ghost_draw
ghost_draw:
  ; Offset coordinates into the well and add dimensions for draw.
  movzx eax, word [ghost_coords]
  shl eax, 16
  add eax, WELL_Y << 24 | WELL_X << 16 | 0x0408

  push eax
  push ghost_sprite
  call draw

  add esp, 8
  ret
