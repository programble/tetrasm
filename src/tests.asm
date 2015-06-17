%ifdef TEST

%include "video.mac"

%define ATTRS FG_BRIGHT | FG_GRAY | BG_BLUE

section .data

hello db 'Hello, World!', 0
calibratestr db 'Calibrating...', 0
caliblankstr db '              ', 0

key db 0

itimer dd 0, 0
marquee dd 1

dtimer dd 0, 0
delaystr db 'DELAY', 0
blankstr db '     ', 0

random dd 0
rtimer dd 0, 0

array db 'ABCDE', 0
stimer dd 0, 0

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
  push dword 0x0101 << 16 | 'H' | ATTRS
  call putc
  add esp, 4

extern puts
test_puts:
  push dword 0x0201 << 16 | ATTRS
  push hello
  call puts
  add esp, 8

extern itoa
test_itoa:
  ; Binary
  push word 0x0208
  push dword 42
  call itoa

  push dword 0x0301 << 16 | ATTRS
  push eax
  call puts

  add esp, 14

  ; Decimal
  push word 0x0A03
  push dword 42
  call itoa

  push dword 0x030A << 16 | ATTRS
  push eax
  call puts

  add esp, 14

  ; Hexadecimal
  push word 0x1002
  push dword 42
  call itoa

  push dword 0x030E << 16 | ATTRS
  push eax
  call puts

  add esp, 14

extern calibrate
test_calibrate:
  push dword 0x0501 << 16 | ATTRS
  push calibratestr
  call puts

  call calibrate

  push dword 0x0501 << 16 | ATTRS
  push caliblankstr
  call puts

  add esp, 16

test_loop:

extern scan
extern reset
test_scan:
  call scan
  mov byte [key], al
  test al, al
  jz .skip

  cmp al, 0x13 ; R
  je reset

  push word 0x1002
  push eax
  call itoa

  push dword 0x0501 << 16 | ATTRS
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

  push dword 0x0701 << 16 | ATTRS
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

  push dword 0x0801 << 16 | ATTRS
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

    push dword 0x0901 << 16 | ATTRS
    push eax
    call puts

    ; Low bits of itimer
    push word 0x1008
    push dword [itimer]
    call itoa

    push dword 0x0909 << 16 | ATTRS
    push eax
    call puts

    ; Marquee
    push word 0x0220
    push dword [marquee]
    call itoa

    push dword 0x0912 << 16 | ATTRS
    push eax
    call puts

  add esp, 50

extern delay
test_delay:
  ; High bits of dtimer
  push word 0x1008
  push dword [dtimer + 4]
  call itoa

  push dword 0x0A01 << 16 | ATTRS
  push eax
  call puts

  ; Low bits of dtimer
  push word 0x1008
  push dword [dtimer]
  call itoa

  push dword 0x0A09 << 16 | ATTRS
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
  push dword 0x0A12 << 16 | ATTRS
  push delaystr
  call puts
  add esp, 8
  jmp .end

  .clear:
    ; Clear delay display.
    push dword 0x0A12 << 16 | ATTRS
    push blankstr
    call puts

    add esp, 8

  ; Start delay on key press.
  cmp byte [key], 0x20 ; D
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

    push dword 0x0C01 << 16 | ATTRS
    push eax
    call puts

    add esp, 14

extern shuffle
test_shuffle:
  push dword 1000
  push stimer
  call interval
  add esp, 8

  test eax, eax
  jz .render

  push dword 5
  push array
  call shuffle
  add esp, 8

  .render:
    push dword 0x0D01 << 16 | ATTRS
    push array
    call puts
    add esp, 8

jmp test_loop

%endif
