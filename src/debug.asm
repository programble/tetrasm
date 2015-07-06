%include "debug.mac"
%include "video.mac"

%ifdef DEBUG

section .data

extern keyboard.debug, timing.debug, bag.debug, current.debug

debug.functions:
  dd 0
  dd keyboard.debug
  dd timing.debug
  dd bag.debug
  dd current.debug
debug.functions$:

debug.function dd debug.functions

section .text

extern fill

; debug.cycle()
; Cycle through debug functions and clear the debug area.
global debug.cycle
debug.cycle:
  add dword [debug.function], 4
  cmp dword [debug.function], debug.functions$
  jne .fill
  mov dword [debug.function], debug.functions

  .fill:
    push dword debug.Y << 24 | debug.X << 16 | debug.HEIGHT << 8 | debug.WIDTH
    push word BG.BLACK
    call fill
    add esp, 6

  ret

; debug.draw()
; Call the current debug function.
global debug.draw
debug.draw:
  mov eax, [debug.function]
  cmp eax, debug.functions
  je .ret
  call [eax]
  .ret:
    ret

%endif
