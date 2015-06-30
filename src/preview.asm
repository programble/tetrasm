%include "video.mac"

%define PREVIEW_X (COLS * 3 / 4)
%define PREVIEW_Y 3

extern tetrominoes
extern bag_next
extern fill, draw

; preview_draw()
; Draw the next tetromino in the bag.
global preview_draw
preview_draw:
  ; Clear previous preview first.
  push dword PREVIEW_Y << 24 | PREVIEW_X << 16 | 0x0408
  push word 0
  call fill

  ; Leave coordinates and dimensions on the stack.
  add esp, 2

  ; Find sprite for next tetromino in bag.
  mov eax, [bag_next]
  movzx eax, word [eax]
  add eax, tetrominoes

  push eax
  call draw

  add esp, 8

  ret
