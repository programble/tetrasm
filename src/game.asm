%include "video.mac"
%include "keyboard.mac"

section .text

extern clear
extern about_draw
extern calibrate
extern bag_init
extern well_draw
extern current_spawn, current_left, current_right, current_down, current_draw
extern scan
extern reset

global game
game:
  ; Show title while timing calibrates.
  push word BG_BLACK
  call clear

  call about_draw

  call calibrate

  push word BG_BLACK
  call clear

  add esp, 4

  ; Initialize game state.
  call bag_init
  call current_spawn

  .loop:
    call scan
    push ax
    .left:
      cmp byte [esp], KEY_LEFT
      jne .right
      call current_left
      inc ebx
    .right:
      cmp byte [esp], KEY_RIGHT
      jne .down
      call current_right
      inc ebx
    .down:
      cmp byte [esp], KEY_DOWN
      jne .reset
      call current_down
      inc ebx
    .reset:
      cmp byte [esp], KEY_R
      jne .end
      jmp reset

    .end:
      add esp, 2

    .draw:
      test ebx, ebx
      jz .continue

      call well_draw
      call current_draw

    .continue:
      xor ebx, ebx
      jmp .loop
