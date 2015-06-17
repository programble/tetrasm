%include "video.mac"

%define R BG_RED
%define A BG_GRAY
%define M BG_MAGENTA
%define B BG_BLUE
%define G BG_GREEN
%define Y BG_YELLOW
%define C BG_CYAN

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
%rep 2
  dw 0,0,0,0,0,0,0,0
  dw R,R,R,R,R,R,R,R
  dw 0,0,0,0,0,0,0,0
  dw 0,0,0,0,0,0,0,0

  dw 0,0,R,R,0,0,0,0
  dw 0,0,R,R,0,0,0,0
  dw 0,0,R,R,0,0,0,0
  dw 0,0,R,R,0,0,0,0
%endrep

global tetromino_J
tetromino_J:
  dw A,A,0,0,0,0,0,0
  dw A,A,A,A,A,A,0,0
  dw 0,0,0,0,0,0,0,0
  dw 0,0,0,0,0,0,0,0

  dw 0,0,A,A,A,A,0,0
  dw 0,0,A,A,0,0,0,0
  dw 0,0,A,A,0,0,0,0
  dw 0,0,0,0,0,0,0,0

  dw 0,0,0,0,0,0,0,0
  dw A,A,A,A,A,A,0,0
  dw 0,0,0,0,A,A,0,0
  dw 0,0,0,0,0,0,0,0

  dw 0,0,A,A,0,0,0,0
  dw 0,0,A,A,0,0,0,0
  dw A,A,A,A,0,0,0,0
  dw 0,0,0,0,0,0,0,0

global tetromino_L
tetromino_L:
  dw 0,0,0,0,M,M,0,0
  dw M,M,M,M,M,M,0,0
  dw 0,0,0,0,0,0,0,0
  dw 0,0,0,0,0,0,0,0

  dw 0,0,M,M,0,0,0,0
  dw 0,0,M,M,0,0,0,0
  dw 0,0,M,M,M,M,0,0
  dw 0,0,0,0,0,0,0,0

  dw 0,0,0,0,0,0,0,0
  dw M,M,M,M,M,M,0,0
  dw M,M,0,0,0,0,0,0
  dw 0,0,0,0,0,0,0,0

  dw M,M,M,M,0,0,0,0
  dw 0,0,M,M,0,0,0,0
  dw 0,0,M,M,0,0,0,0
  dw 0,0,0,0,0,0,0,0

global tetromino_O
tetromino_O:
%rep 4
  dw 0,0,0,0,0,0,0,0
  dw 0,0,B,B,B,B,0,0
  dw 0,0,B,B,B,B,0,0
  dw 0,0,0,0,0,0,0,0
%endrep

global tetromino_S
tetromino_S:
%rep 2
  dw 0,0,0,0,0,0,0,0
  dw 0,0,G,G,G,G,0,0
  dw G,G,G,G,0,0,0,0
  dw 0,0,0,0,0,0,0,0

  dw 0,0,G,G,0,0,0,0
  dw 0,0,G,G,G,G,0,0
  dw 0,0,0,0,G,G,0,0
  dw 0,0,0,0,0,0,0,0
%endrep

global tetromino_T
tetromino_T:
  dw 0,0,Y,Y,0,0,0,0
  dw Y,Y,Y,Y,Y,Y,0,0
  dw 0,0,0,0,0,0,0,0
  dw 0,0,0,0,0,0,0,0

  dw 0,0,Y,Y,0,0,0,0
  dw 0,0,Y,Y,Y,Y,0,0
  dw 0,0,Y,Y,0,0,0,0
  dw 0,0,0,0,0,0,0,0

  dw 0,0,0,0,0,0,0,0
  dw Y,Y,Y,Y,Y,Y,0,0
  dw 0,0,Y,Y,0,0,0,0
  dw 0,0,0,0,0,0,0,0

  dw 0,0,Y,Y,0,0,0,0
  dw Y,Y,Y,Y,0,0,0,0
  dw 0,0,Y,Y,0,0,0,0
  dw 0,0,0,0,0,0,0,0

global tetromino_Z
tetromino_Z:
%rep 2
  dw 0,0,0,0,0,0,0,0
  dw C,C,C,C,0,0,0,0
  dw 0,0,C,C,C,C,0,0
  dw 0,0,0,0,0,0,0,0

  dw 0,0,0,0,C,C,0,0
  dw 0,0,C,C,C,C,0,0
  dw 0,0,C,C,0,0,0,0
  dw 0,0,0,0,0,0,0,0
%endrep
