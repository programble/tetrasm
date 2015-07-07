%include "video.mac"
%include "keyboard.mac"

%define game.STATUS.X (COLS * 3 / 4)
%define game.STATUS.Y (ROWS / 4 + 2)

section .data

extern gravity.timer

global game.over
game.paused db 0
game.over db 0

game.paused.label db 'PAUSED', 0
game.over.label db 'GAME OVER', 0

section .text

extern clear, puts, about.draw
extern calibrate, tps, scan, reset
extern bag.init, current.spawn
extern current.left, current.right, current.down, current.rotate, current.drop
extern ghost.update
extern hold
extern gravity.fall, gravity.lock
extern well.lines.detect, well.lines.animate, well.lines.clear
extern well.draw, current.draw, ghost.draw, preview.draw, hold.draw, score.draw

%ifdef DEBUG
extern debug.cycle, debug.draw
%endif

; game.pause()
; Toggle the paused state.
game.pause:
  xor byte [game.paused], 1

  ; Reset gravity timer on unpause to prevent it being applied immediately.
  mov dword [gravity.timer], 0
  mov dword [gravity.timer + 4], 0

  ; Clear the screen to remove pause/about.
  push word BG.BLACK
  call clear
  add esp, 2

  ; Return non-zero to trigger draw.
  inc eax
  ret

; game.paused.draw()
; Clear the screen, draw the paused status and about screen.
game.paused.draw:
  test byte [game.paused], 1
  jz .ret

  push word BG.BLACK
  call clear

  push dword game.STATUS.Y << 24 | (game.STATUS.X + 2) << 16 | FG.BRIGHT | FG.YELLOW
  push game.paused.label
  call puts
  add esp, 10

  call about.draw

  .ret:
    ret

; game.over.draw()
; Draw the game over status.
game.over.draw:
  test byte [game.over], 1
  jz .ret

  push dword game.STATUS.Y << 24 | game.STATUS.X << 16 | FG.BRIGHT | FG.RED
  push game.over.label
  call puts
  add esp, 8

  .ret:
    ret

global game
game:
  ; Show title while timing calibrates.
  push word BG.BLACK
  call clear
  call about.draw
  call calibrate
  call clear
  add esp, 2

  ; Initialize game state.
  call bag.init
  call current.spawn

  ; Game loop tracks if state has changed in ebx for redrawing.
  mov ebx, 1

%macro bind 2
  cmp byte [esp], %1
  jne %%next
  call %2
  add ebx, eax
  %%next:
%endmacro

%macro call.update 1
  call %1
  add ebx, eax
%endmacro

game.loop:
  .timing:
    call tps

  .input:
    call scan
    push ax

%ifdef DEBUG
    bind KEY.D,     debug.cycle
%endif

    bind KEY.R,     reset

    test byte [game.over], 1
    jnz .input$

    bind KEY.P,     game.pause

    test byte [game.paused], 1
    jnz .input$

    bind KEY.LEFT,  current.left
    bind KEY.RIGHT, current.right
    bind KEY.DOWN,  current.down
    bind KEY.UP,    current.rotate
    bind KEY.ENTER, current.drop
    bind KEY.SHIFT, hold

  .input$:
    add esp, 2

  .update:
    ; game.paused || game.over
    cmp word [game.paused], 0
    jne .draw

    call.update gravity.lock
    call.update gravity.fall
    call        well.lines.detect
    call.update well.lines.animate
    call.update well.lines.clear

  .draw:
%ifdef DEBUG
    call debug.draw
%endif

    test ebx, ebx
    jz game.loop

    call ghost.update

    call well.draw
    call ghost.draw
    call current.draw
    call preview.draw
    call hold.draw
    call game.paused.draw
    call score.draw
    call game.over.draw

  xor ebx, ebx
  jmp game.loop
