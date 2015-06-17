section .text

extern tests

global main
main:
  ; Move text mode cursor off screen.
  mov dx, 0x3D4
  mov al, 0x0E
  out dx, al
  inc dx
  mov al, 0xFF
  out dx, al

%ifdef TEST
  jmp tests
%endif

  hlt
  jmp main
