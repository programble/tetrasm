section .data

hello db 'Hello, World!', 0

section .text

%include "video.mac"
extern clear
extern putc
extern puts
extern itoa
extern scan

global main
main:
  push BG_GREEN
  call clear
  add esp, 2

  push word 1 << 8 | 1
  push word 'H' | FG_BRIGHT | FG_GRAY | BG_BLACK
  call putc
  add esp, 4

  push word 3 << 8 | 3
  push word FG_BRIGHT | FG_BLUE | BG_BLUE
  push hello
  call puts
  add esp, 8

  push word 10 << 8 | 2
  push dword 42
  call itoa
  add esp, 6

  push word 4 << 8 | 1
  push word FG_BLACK | BG_GREEN
  push eax
  call puts
  add esp, 8

  .loop:
    call scan
    test eax, eax
    je .loop
    push word 16 << 8 | 2
    push eax
    call itoa
    add esp, 6
    push word 8 << 8 | 8
    push word FG_BRIGHT | FG_GREEN | BG_GREEN
    push eax
    call puts
    add esp, 8
    jmp .loop

hang:
  hlt
  jmp hang
