%include "video.mac"

section .text

extern clear
extern about_draw
extern calibrate

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

  hlt
  jmp game
