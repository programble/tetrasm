%include "well.mac"

section .data

extern tetrominoes
extern current.offset, current.coords

ghost.sprite times 64 db 0

global ghost.coords
ghost.coords dw 0

section .text

extern well.collide?
extern draw

; ghost.update()
; Update the ghost sprite and coords from the current tetromino.
global ghost.update
ghost.update:
  push esi
  push edi

  ; Copy current tetromino sprite into ghost sprite.
  movzx esi, word [current.offset]
  add esi, tetrominoes
  mov edi, ghost.sprite
  mov ecx, 16
  rep movsd

  ; Return if current tetromino is null (game over).
  cmp esi, tetrominoes + 0x40
  je .ret

  ; Remove background color from ghost sprite.
  mov edi, ghost.sprite
  mov ecx, 16
  .sloop:
    and dword [edi], 0x0FFF0FFF
    add edi, 4
    loop .sloop

  ; Start at current tetromino coords.
  push word [current.coords]
  push word [current.offset]

  ; Move down until there is a collision.
  .cloop:
    call well.collide?
    jz .update

    inc byte [esp + 3]
    jmp .cloop

  ; Update actual ghost coords (one less than where the collision was).
  .update:
    mov ax, [esp + 2]
    dec ah
    mov [ghost.coords], ax

  add esp, 4

  .ret:
    pop edi
    pop esi
    ret

; ghost.draw()
; Draw the ghost.
global ghost.draw
ghost.draw:
  ; Offset coordinates into the well and add dimensions for draw.
  movzx eax, word [ghost.coords]
  shl eax, 16
  add eax, well.Y << 24 | well.X << 16 | 0x0408

  push eax
  push ghost.sprite
  call draw

  add esp, 8
  ret
