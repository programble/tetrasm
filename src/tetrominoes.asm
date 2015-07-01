%include "video.mac"

; Use colons in sprites to make ghost rendering easier.
%define o 0, 0
%define C ':' | FG.CYAN    | BG.CYAN,    ':' | FG.CYAN    | BG.CYAN
%define B ':' | FG.BLUE    | BG.BLUE,    ':' | FG.BLUE    | BG.BLUE
%define A ':' | FG.GRAY    | BG.GRAY,    ':' | FG.GRAY    | BG.GRAY
%define Y ':' | FG.YELLOW  | BG.YELLOW,  ':' | FG.YELLOW  | BG.YELLOW
%define G ':' | FG.GREEN   | BG.GREEN,   ':' | FG.GREEN   | BG.GREEN
%define M ':' | FG.MAGENTA | BG.MAGENTA, ':' | FG.MAGENTA | BG.MAGENTA
%define R ':' | FG.RED     | BG.RED,     ':' | FG.RED     | BG.RED

section .data

; Each tetromino rotation is represented by a sprite of height 4 and width 8.
; After an initial null tetromino, there are 7 tetrominoes with 4 rotations
; each. Each tetromino is at an offset of 256 bytes, and each rotation is at an
; offset of 64 bytes.
global tetrominoes
tetrominoes:

.null:
  times 128 dw 0

.I:
  dw o,o,o,o
  dw C,C,C,C
  dw o,o,o,o
  dw o,o,o,o

  dw o,o,C,o
  dw o,o,C,o
  dw o,o,C,o
  dw o,o,C,o

  dw o,o,o,o
  dw o,o,o,o
  dw C,C,C,C
  dw o,o,o,o

  dw o,C,o,o
  dw o,C,o,o
  dw o,C,o,o
  dw o,C,o,o

.J:
  dw B,o,o,o
  dw B,B,B,o
  dw o,o,o,o
  dw o,o,o,o

  dw o,B,B,o
  dw o,B,o,o
  dw o,B,o,o
  dw o,o,o,o

  dw o,o,o,o
  dw B,B,B,o
  dw o,o,B,o
  dw o,o,o,o

  dw o,B,o,o
  dw o,B,o,o
  dw B,B,o,o
  dw o,o,o,o

.L:
  dw o,o,A,o
  dw A,A,A,o
  dw o,o,o,o
  dw o,o,o,o

  dw o,A,o,o
  dw o,A,o,o
  dw o,A,A,o
  dw o,o,o,o

  dw o,o,o,o
  dw A,A,A,o
  dw A,o,o,o
  dw o,o,o,o

  dw A,A,o,o
  dw o,A,o,o
  dw o,A,o,o
  dw o,o,o,o

.O:
%rep 4
  dw o,Y,Y,o
  dw o,Y,Y,o
  dw o,o,o,o
  dw o,o,o,o
%endrep

.S:
  dw o,G,G,o
  dw G,G,o,o
  dw o,o,o,o
  dw o,o,o,o

  dw o,G,o,o
  dw o,G,G,o
  dw o,o,G,o
  dw o,o,o,o

  dw o,o,o,o
  dw o,G,G,o
  dw G,G,o,o
  dw o,o,o,o

  dw G,o,o,o
  dw G,G,o,o
  dw o,G,o,o
  dw o,o,o,o

.T:
  dw o,M,o,o
  dw M,M,M,o
  dw o,o,o,o
  dw o,o,o,o

  dw o,M,o,o
  dw o,M,M,o
  dw o,M,o,o
  dw o,o,o,o

  dw o,o,o,o
  dw M,M,M,o
  dw o,M,o,o
  dw o,o,o,o

  dw o,M,o,o
  dw M,M,o,o
  dw o,M,o,o
  dw o,o,o,o

.Z:
  dw R,R,o,o
  dw o,R,R,o
  dw o,o,o,o
  dw o,o,o,o

  dw o,o,R,o
  dw o,R,R,o
  dw o,R,o,o
  dw o,o,o,o

  dw o,o,o,o
  dw R,R,o,o
  dw o,R,R,o
  dw o,o,o,o

  dw o,R,o,o
  dw R,R,o,o
  dw R,o,o,o
  dw o,o,o,o
