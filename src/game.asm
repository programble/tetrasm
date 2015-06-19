%include "video.mac"

section .text

extern clear
extern about_draw
extern calibrate
extern bag_init
extern well_draw

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

  call well_draw

  hlt
  jmp game
