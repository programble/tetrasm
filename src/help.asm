%include "video.mac"

%define help.X 1
%define help.Y (ROWS - 11)

%define help.WIDTH 24
%define help.HEIGHT 9

section .data

help.show db 1

help.text:
  .left  db 'LEFT',       0, 0, '- Move left', 0
  .right db 'RIGHT',         0, '- Move right', 0
  .up    db 'UP',   0, 0, 0, 0, '- Rotate clockwise', 0
  .down  db 'DOWN',       0, 0, '- Soft drop', 0
  .enter db 'ENTER',         0, '- Hard drop', 0
  .shift db 'SHIFT',         0, '- Hold', 0
  .p     db 'P', 0, 0, 0, 0, 0, '- Pause', 0
  .h     db 'H', 0, 0, 0, 0, 0, '- Toggle help', 0
  .r     db 'R', 0, 0, 0, 0, 0, '- Hard reset', 0

section .text

extern fill, puts

; help.toggle()
; Toggle help.
global help.toggle
help.toggle:
  xor byte [help.show], 1

  ; Clear draw area.
  push dword help.Y << 24 | help.X << 16 | help.HEIGHT << 8 | help.WIDTH
  push word BG.BLACK
  call fill
  add esp, 6

  inc eax
  ret

%macro help.draw.line 2
  push dword (help.Y + %1) << 24 | help.X << 16 | FG.BRIGHT | FG.BLUE
  push %2
  call puts

  add dword [esp], 6
  add dword [esp + 4], 6 << 16
  xor dword [esp + 4], FG.BRIGHT
  call puts

  add esp, 8
%endmacro

; help.draw()
; Draw help text.
global help.draw
help.draw:
  test byte [help.show], 1
  jz .ret

  help.draw.line 0, help.text.left
  help.draw.line 1, help.text.right
  help.draw.line 2, help.text.up
  help.draw.line 3, help.text.down
  help.draw.line 4, help.text.enter
  help.draw.line 5, help.text.shift
  help.draw.line 6, help.text.p
  help.draw.line 7, help.text.h
  help.draw.line 8, help.text.r

  .ret:
    ret
