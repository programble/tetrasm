%include "video.mac"

%define R FG_BRIGHT | FG_RED     | BG_RED
%define A FG_BRIGHT | FG_GRAY    | BG_GRAY
%define M FG_BRIGHT | FG_MAGENTA | BG_MAGENTA
%define B FG_BRIGHT | FG_BLUE    | BG_BLUE
%define G FG_BRIGHT | FG_GREEN   | BG_GREEN
%define Y FG_BRIGHT | FG_YELLOW  | BG_YELLOW
%define C FG_BRIGHT | FG_CYAN    | BG_CYAN

section .data

title:
  dw R,R,R,A,A,A,M,M,M,B,B,B,G,G,G,Y,Y,Y,C,C,C
  dw R, 'T' | R, R
  dw A, 'E' | A, A
  dw M, 'T' | M, M
  dw B, 'R' | B, B
  dw G, 'A' | G, G
  dw Y, 'S' | Y, Y
  dw C, 'M' | C, C
  dw R,R,R,A,A,A,M,M,M,B,B,B,G,G,G,Y,Y,Y,C,C,C

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
