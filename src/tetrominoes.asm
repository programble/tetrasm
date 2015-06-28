%include "video.mac"

%define o 0, 0
%define C BG_CYAN, BG_CYAN
%define B BG_BLUE, BG_BLUE
%define A BG_GRAY, BG_GRAY
%define Y BG_YELLOW, BG_YELLOW
%define G BG_GREEN, BG_GREEN
%define M BG_MAGENTA, BG_MAGENTA
%define R BG_RED, BG_RED

section .data

; Each tetromino rotation is represented by a sprite of height 4 and width 8.
; After an initial null tetromino, there are 7 tetrominoes with 4 rotations
; each. Each tetromino is at an offset of 256 bytes, and each rotation is at an
; offset of 64 bytes.
global tetrominoes
tetrominoes:

global tetromino_null
tetromino_null:
  times 128 dw 0

global tetromino_I
tetromino_I:
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

global tetromino_J
tetromino_J:
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

global tetromino_L
tetromino_L:
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

global tetromino_O
tetromino_O:
%rep 4
  dw o,Y,Y,o
  dw o,Y,Y,o
  dw o,o,o,o
  dw o,o,o,o
%endrep

global tetromino_S
tetromino_S:
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

global tetromino_T
tetromino_T:
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

global tetromino_Z
tetromino_Z:
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
