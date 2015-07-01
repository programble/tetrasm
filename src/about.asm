%include "video.mac"

%define C FG.BRIGHT | FG.CYAN    | BG.CYAN
%define B FG.BRIGHT | FG.BLUE    | BG.BLUE
%define A FG.BRIGHT | FG.GRAY    | BG.GRAY
%define Y FG.BRIGHT | FG.YELLOW  | BG.YELLOW
%define G FG.BRIGHT | FG.GREEN   | BG.GREEN
%define M FG.BRIGHT | FG.MAGENTA | BG.MAGENTA
%define R FG.BRIGHT | FG.RED     | BG.RED

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

; about.draw()
; Draw title and info.
global about.draw
about.draw:
  push dword (ROWS - 1) << 24 | FG.BRIGHT | FG.GRAY
  push info
  call puts

  push dword (ROWS / 2 - 1) << 24 | (COLS / 2 - 10) << 16 | 0x0315
  push title
  call draw

  add esp, 16

  ret
