%include "video.mac"

%define preview.X (COLS * 3 / 4)
%define preview.Y 3

extern tetrominoes
extern bag.next
extern fill, draw

; preview.draw()
; Draw the next tetromino in the bag.
global preview.draw
preview.draw:
  ; Clear previous preview first.
  push dword preview.Y << 24 | preview.X << 16 | 0x0408
  push word 0
  call fill

  ; Leave coordinates and dimensions on the stack.
  add esp, 2

  ; Find sprite for next tetromino in bag.
  mov eax, [bag.next]
  movzx eax, word [eax]
  add eax, tetrominoes

  push eax
  call draw

  add esp, 8

  ret
