%include "video.mac"

%define ATTRS FG_BRIGHT | FG_GRAY | BG_BLUE

section .data

hello db 'Hello, World!', 0

key db 0

itimer dd 0, 0
marquee dd 1

dtimer dd 0, 0
delaystr db 'DELAY', 0
blankstr db '     ', 0

random dd 0
rtimer dd 0, 0

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

extern scan
extern reset
test_scan:
  call scan
  mov byte [key], al
  test al, al
  jz .skip

  cmp al, 0x93 ; R
  je reset

  push word 0x1002
  push eax
  call itoa

  push word 0x0501
  push word ATTRS
  push eax
  call puts

  add esp, 14

  .skip:

extern rtcs
test_rtcs:
  call rtcs

  push word 0x1002
  push eax
  call itoa

  push word 0x0701
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

  push word 0x0801
  push word ATTRS
  push eax
  call puts

  add esp, 14

extern interval
test_interval:
  push dword 500
  push itimer
  call interval

  test eax, eax
  jz .render
  rol dword [marquee], 1

  .render:
    ; High bits of itimer
    push word 0x1008
    push dword [itimer + 4]
    call itoa

    push word 0x0901
    push word ATTRS
    push eax
    call puts

    ; Low bits of itimer
    push word 0x1008
    push dword [itimer]
    call itoa

    push word 0x0909
    push word ATTRS
    push eax
    call puts

    ; Marquee
    push word 0x0220
    push dword [marquee]
    call itoa

    push word 0x0912
    push word ATTRS
    push eax
    call puts

  add esp, 50

extern delay
test_delay:
  ; High bits of dtimer
  push word 0x1008
  push dword [dtimer + 4]
  call itoa

  push word 0x0A01
  push word ATTRS
  push eax
  call puts

  ; Low bits of dtimer
  push word 0x1008
  push dword [dtimer]
  call itoa

  push word 0x0A09
  push word ATTRS
  push eax
  call puts

  add esp, 28

  ; Check if waiting.
  cmp dword [dtimer], 0
  je .clear
  push dword 2000
  push dtimer
  call delay
  add esp, 8
  test eax, eax
  jnz .clear

  ; Show delay display.
  push word 0x0A12
  push word ATTRS
  push delaystr
  call puts
  add esp, 8
  jmp .end

  .clear:
    ; Clear delay display.
    push word 0x0A12
    push word ATTRS
    push blankstr
    call puts

    add esp, 8

  ; Start delay on key press.
  cmp byte [key], 0xA0 ; D
  jne .end

  push dword 2000
  push dtimer
  call delay
  add esp, 8

  .end:

extern rand
test_rand:
  push dword 1000
  push rtimer
  call interval
  add esp, 8

  test eax, eax
  jz .render

  push dword 100
  call rand
  add esp, 4

  mov [random], eax

  .render:
    push word 0x0A03
    push dword [random]
    call itoa

    push word 0x0C01
    push word ATTRS
    push eax
    call puts

    add esp, 14

jmp test_loop
