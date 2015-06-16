section .text

extern tests

global main
main:
%ifdef TEST
  jmp tests
%endif

  hlt
  jmp main
