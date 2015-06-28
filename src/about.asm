%include "video.mac"

%define C FG_BRIGHT | FG_CYAN    | BG_CYAN
%define B FG_BRIGHT | FG_BLUE    | BG_BLUE
%define A FG_BRIGHT | FG_GRAY    | BG_GRAY
%define Y FG_BRIGHT | FG_YELLOW  | BG_YELLOW
%define G FG_BRIGHT | FG_GREEN   | BG_GREEN
%define M FG_BRIGHT | FG_MAGENTA | BG_MAGENTA
%define R FG_BRIGHT | FG_RED     | BG_RED

section .data

title:
  dw C,C,C,B,B,B,A,A,A,Y,Y,Y,G,G,G,M,M,M,R,R,R
  dw C, 'T' | C, C
  dw B, 'E' | B, B
  dw A, 'T' | A, A
  dw Y, 'R' | Y, Y
  dw G, 'A' | G, G
  dw M, 'S' | M, M
  dw R, 'M' | R, R
  dw C,C,C,B,B,B,A,A,A,Y,Y,Y,G,G,G,M,M,M,R,R,R

info db 'Tetrasm https://github.com/programble/tetrasm', 0

section .text

extern draw, puts

; about_draw()
; Draw title and info.
global about_draw
about_draw:
  push dword (ROWS - 1) << 24 | FG_BRIGHT | FG_GRAY
  push info
  call puts

  push dword (ROWS / 2 - 1) << 24 | (COLS / 2 - 10) << 16 | 0x0315
  push title
  call draw

  add esp, 16

  ret
