%include "video.mac"

%define score.X (COLS * 3 / 4)
%define score.Y (ROWS / 2)

%define level.X score.X
%define level.Y (score.Y + 4)

section .data

extern current.coords, ghost.coords

global level, score
level dd 1
score dd 0

; Score factors for number of lines cleared.
score.factors dd 100, 300, 500, 800

; Lines cleared in the current level.
level.lines dd 0

score.label db 'SCORE', 0
level.label db 'LEVEL', 0

section .text

extern gravity.update
extern itoa
extern puts

; score.down()
; Increase the score for moving the tetromino down.
global score.down
score.down:
  inc dword [score]
  ret

; score.drop()
; Increase the score for hard dropping the tetromino. Must be called before the
; tetromino is moved.
global score.drop
score.drop:
  ; Award points double the number of rows being dropped.
  ; Subtract the coordinate words, where the low bytes (x) will always be
  ; equal. Shift the difference of the high bytes right 7 bits instead of 8 to
  ; get the double.
  movzx eax, word [ghost.coords]
  sub ax, [current.coords]
  shr ax, 7
  add [score], eax
  ret

; score.lines(dword lines)
; Award points for lines cleared.
global score.lines
score.lines:
  push ebp
  mov ebp, esp

  ; Index into score factors.
  mov ecx, [esp + 8] ; lines
  mov eax, [score.factors + ecx * 4 - 4]

  ; Increase score by factor * level.
  mul dword [level]
  add [score], eax

  add [level.lines], ecx
  cmp dword [level.lines], 10
  jb .ret

  ; Level up!
  inc dword [level]
  mov dword [level.lines], 0
  call gravity.update

  .ret:
    mov esp, ebp
    pop ebp
    ret

; score.draw()
; Draw the score and level.
global score.draw
score.draw:
  push dword score.Y << 24 | (score.X + 2) << 16 | FG.BLUE
  push score.label
  call puts

  push word 0x0A09
  push dword [score]
  call itoa

  push dword (score.Y + 2) << 24 | score.X << 16 | FG.BRIGHT | FG.BLUE
  push eax
  call puts

  add esp, 22

  push dword level.Y << 24 | (level.X + 2) << 16 | FG.BLUE
  push level.label
  call puts

  push word 0x0A03
  push dword [level]
  call itoa

  push dword (level.Y + 2) << 24 | (level.X + 3) << 16 | FG.BRIGHT | FG.BLUE
  push eax
  call puts

  add esp, 22
  ret
