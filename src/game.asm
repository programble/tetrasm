%include "video.mac"
%include "keyboard.mac"

section .text

extern clear, about.draw
extern calibrate, scan, reset
extern bag.init, current.spawn
extern current.left, current.right, current.down, current.rotate, current.drop
extern ghost.update
extern hold
extern gravity.fall, gravity.lock
extern well.lines.detect, well.lines.animate, well.lines.clear
extern well.draw, current.draw, ghost.draw, preview.draw, hold.draw, score.draw

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

game.loop:
  .input:
    call scan
    push ax

    bind KEY.R,     reset
    bind KEY.LEFT,  current.left
    bind KEY.RIGHT, current.right
    bind KEY.DOWN,  current.down
    bind KEY.UP,    current.rotate
    bind KEY.ENTER, current.drop
    bind KEY.SHIFT, hold

    add esp, 2

  .update:
    call gravity.lock
    add ebx, eax

    call gravity.fall
    add ebx, eax

    call well.lines.detect

    call well.lines.animate
    add ebx, eax

    call well.lines.clear
    add ebx, eax

  .draw:
    test ebx, ebx
    jz game.loop

    call ghost.update

    call well.draw
    call ghost.draw
    call current.draw
    call preview.draw
    call hold.draw
    call score.draw

  xor ebx, ebx
  jmp game.loop
