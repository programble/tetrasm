section .data

; Previous scancode.
key db 0

section .text

; scan()
; Scan for new keypress. Returns new scancode if changed since last call, zero
; otherwise.
global scan
scan:
  ; Zero eax for return.
  xor eax, eax

  ; Scan.
  in al, 0x60

  ; If scancode has changed, update key and return it.
  cmp al, [key]
  je .zero
  mov [key], al
  jmp .ret

  ; Otherwise, return zero.
  .zero:
    xor eax, eax

  .ret:
    ret

%ifdef DEBUG
%include "debug.mac"

extern itoa, puts

global keyboard.debug
keyboard.debug:
  push word 0x1002
  push dword [key]
  call itoa
  push dword debug.Y << 24 | debug.X << 16 | debug.ATTRS
  push eax
  call puts
  add esp, 14
  ret

%endif
