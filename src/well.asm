%include "video.mac"

%define WELL_WIDTH 22
%define WELL_HEIGHT 23

%define WELL_X (COLS / 2 - WELL_WIDTH / 2)
%define WELL_Y 0

%define INSIDE_WIDTH WELL_WIDTH - 2
%define INSIDE_HEIGHT WELL_HEIGHT - 3

%define INSIDE_X WELL_X + 1
%define INSIDE_Y WELL_Y + 2

section .data

well:
  ; First two rows are empty.
  times WELL_WIDTH dw 0
  times WELL_WIDTH dw 0

  ; Middle rows have a border on either side.
%rep INSIDE_HEIGHT
  dw BG_GRAY
  times INSIDE_WIDTH dw 0
  dw BG_GRAY
%endrep

  ; Bottom row is all border.
  times WELL_WIDTH dw BG_GRAY

section .text

extern fill
extern draw

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
