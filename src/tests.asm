%include "video.mac"

%define ATTRS FG_BRIGHT | FG_GRAY | BG_BLUE

section .data

hello db 'Hello, World!', 0
timer dd 0, 0
marquee dd 1

section .text

global tests
tests:

extern clear
test_clear:
  push BG_BLUE
  call clear
  add esp, 2

extern putc
test_putc:
  push word 0x0101
  push word 'H' | ATTRS
  call putc
  add esp, 4

extern puts
test_puts:
  push word 0x0201
  push word ATTRS
  push hello
  call puts
  add esp, 8

extern itoa
test_itoa:
  ; Binary
  push word 0x0208
  push dword 42
  call itoa

  push word 0x0301
  push word ATTRS
  push eax
  call puts

  add esp, 14

  ; Decimal
  push word 0x0A03
  push dword 42
  call itoa

  push word 0x030A
  push word ATTRS
  push eax
  call puts

  add esp, 14

  ; Hexadecimal
  push word 0x1002
  push dword 42
  call itoa

  push word 0x030E
  push word ATTRS
  push eax
  call puts

  add esp, 14

test_loop:

extern rtcs
test_rtcs:
  call rtcs

  push word 0x1002
  push eax
  call itoa

  push word 0x0501
  push word ATTRS
  push eax
  call puts

  add esp, 14

extern tps
extern tpms
test_tps:
  call tps

  push word 0x0A0A
  push dword [tpms]
  call itoa

  push word 0x0601
  push word ATTRS
  push eax
  call puts

  add esp, 14

extern interval
test_interval:
  push dword 500
  push timer
  call interval

  test al, al
  jz .render
  rol dword [marquee], 1

  .render:
    ; High bits of timer
    push word 0x1008
    push dword [timer + 4]
    call itoa

    push word 0x0701
    push word ATTRS
    push eax
    call puts

    ; Low bits of timer
    push word 0x1008
    push dword [timer]
    call itoa

    push word 0x0709
    push word ATTRS
    push eax
    call puts

    ; Marquee
    push word 0x0220
    push dword [marquee]
    call itoa

    push word 0x0712
    push word ATTRS
    push eax
    call puts

  add esp, 50

extern scan
extern reset
test_scan:
  call scan
  test al, al
  jz .skip

  cmp al, 0x93 ; R
  je reset

  push word 0x1002
  push eax
  call itoa

  push word 0x0901
  push word ATTRS
  push eax
  call puts

  add esp, 14

  .skip:

jmp test_loop
