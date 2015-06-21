%include "video.mac"
%include "well.mac"

section .data

well:
  ; First two rows are empty.
  times WELL_WIDTH dw 0
  times WELL_WIDTH dw 0

  ; Middle rows have a thin border on either side.
%rep INSIDE_HEIGHT
  dw 0
  dw BG_GRAY
  times INSIDE_WIDTH dw 0
  dw BG_GRAY
  dw 0
%endrep

  ; Bottom row completes the border.
  dw 0
  times INSIDE_WIDTH + 2 dw BG_GRAY
  dw 0

section .text

extern fill, draw

; well_draw()
; Draw the well.
global well_draw
well_draw:
  ; Background fill inside well.
  push dword INSIDE_Y << 24 | INSIDE_X << 16 | INSIDE_HEIGHT << 8 | INSIDE_WIDTH
  push word ':' | FG_GRAY
  call fill

  ; The well itself.
  push dword WELL_Y << 24 | WELL_X << 16 | WELL_HEIGHT << 8 | WELL_WIDTH
  push well
  call draw

  add esp, 14

  ret
