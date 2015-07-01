%ifdef TEST

%include "video.mac"
%include "keyboard.mac"

%define ATTRS FG.BRIGHT | FG.GRAY | BG.BLUE

section .data

hello db 'Hello, World!', 0

sprite:
  dw BG.GREEN,   BG.GREEN,   0, BG.CYAN,   BG.CYAN,   0, BG.RED,  BG.RED
  dw 0,          0,          0, 0,         0,         0, 0,       0
  dw BG.MAGENTA, BG.MAGENTA, 0, BG.YELLOW, BG.YELLOW, 0, BG.GRAY, BG.GRAY

calibratestr db 'Calibrating...', 0
caliblankstr db '              ', 0

key db 0

itimer dq 0
marquee dd 1

dtimer dq 0
delaystr db 'DELAY', 0
blankstr db '     ', 0

random dd 0
rtimer dq 0

sbytes db 'ABCDE', 0
swords dw 0xAAAA, 0xBBBB, 0xCCCC, 0xDDDD, 0xEEEE
stimer dq 0

bag.current dw 0

section .text

global tests
tests:

extern clear
test.clear:
  push BG.BLUE
  call clear
  add esp, 2

extern putc
test.putc:
  push dword 0x0101 << 16 | 'H' | ATTRS
  call putc
  add esp, 4

extern puts
test.puts:
  push dword 0x0201 << 16 | ATTRS
  push hello
  call puts
  add esp, 8

extern fill
test.fill:
  push dword 0x01250306
  push word BG.GRAY
  call fill
  add esp, 6

extern draw
test.draw:
  push dword 0x01380308
  push sprite
  call draw
  add esp, 8

extern itoa
test.itoa:
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
test.calibrate:
  push dword 0x0501 << 16 | ATTRS
  push calibratestr
  call puts

  call calibrate

  push dword 0x0501 << 16 | ATTRS
  push caliblankstr
  call puts

  add esp, 16

test.loop:

extern scan, reset
test.scan:
  call scan
  mov byte [key], al
  test al, al
  jz .skip

  cmp al, KEY.R
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
test.rtcs:
  call rtcs

  push word 0x1002
  push eax
  call itoa

  push dword 0x0701 << 16 | ATTRS
  push eax
  call puts

  add esp, 14

extern tps, tpms
test.tps:
  call tps

  push word 0x0A0A
  push dword [tpms]
  call itoa

  push dword 0x0801 << 16 | ATTRS
  push eax
  call puts

  add esp, 14

extern interval
test.interval:
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
test.delay:
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
  cmp byte [key], KEY.D
  jne .end

  push dword 2000
  push dtimer
  call delay
  add esp, 8

  .end:

extern rand
test.rand:
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

extern shuffleb, shufflew
test.shuffle:
  push dword 1000
  push stimer
  call interval
  add esp, 8

  test eax, eax
  jz .render

  push dword 5
  push sbytes
  call shuffleb
  add esp, 8

  push dword 5
  push swords
  call shufflew
  add esp, 8

  .render:
    push dword 0x0D01 << 16 | ATTRS
    push sbytes
    call puts
    add esp, 8

    mov esi, swords
    mov edi, 0x0D07 << 16 | ATTRS
    mov ecx, 5
    .loop:
      push ecx

      push word 0x1004
      movzx eax, word [esi]
      push eax
      call itoa

      push edi
      push eax
      call puts

      add esp, 14

      ; Move to next word in array and 5 columns over.
      add esi, 2
      add edi, 0x00050000

      pop ecx
      loop .loop

extern bag, bag.init, bag.pop
test.bag:
  .init:
    cmp byte [key], KEY.I
    jne .pop

    call bag.init

  .pop:
    cmp byte [key], KEY.P
    jne .render

    call bag.pop
    mov word [bag.current], ax

  .render:
  push word 0x1003
  push word 0
  push word [bag.current]
  call itoa

  push dword 0x0F01 << 16 | ATTRS
  push eax
  call puts

  add esp, 14

  mov esi, bag
  mov edi, 0x0F07 << 16 | ATTRS
  mov ecx, 7
  .loop:
    push ecx

    push word 0x1003
    push word 0
    push word [esi]
    call itoa

    push edi
    push eax
    call puts

    add esp, 14

    add esi, 2
    add edi, 0x000040000

    pop ecx
    loop .loop

jmp test.loop

%endif
