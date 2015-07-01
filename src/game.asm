%include "video.mac"
%include "keyboard.mac"

section .text

extern clear, about_draw
extern calibrate, scan, reset
extern bag_init, current_spawn
extern current_left, current_right, current_down, current_rotate, current_drop
extern ghost_update
extern hold
extern well_draw, current_draw, ghost_draw, preview_draw, hold_draw

global game
game:
  ; Show title while timing calibrates.
  push word BG_BLACK
  call clear
  call about_draw
  call calibrate
  call clear
  add esp, 2

  ; Initialize game state.
  call bag_init
  call current_spawn

  ; Game loop tracks if state has changed in ebx for redrawing.
  mov ebx, 1

%macro bind 2
  cmp byte [esp], %1
  jne %%next
  call %2
  add ebx, eax
  %%next:
%endmacro

game_loop:
  call scan
  push ax
  bind KEY_R,     reset
  bind KEY_LEFT,  current_left
  bind KEY_RIGHT, current_right
  bind KEY_DOWN,  current_down
  bind KEY_UP,    current_rotate
  bind KEY_ENTER, current_drop
  bind KEY_SHIFT, hold
  add esp, 2

  test ebx, ebx
  jz game_loop

  call ghost_update

  call well_draw
  call ghost_draw
  call current_draw
  call preview_draw
  call hold_draw

  xor ebx, ebx
  jmp game_loop
