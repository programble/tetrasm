; Lock delay in milliseconds.
%define gravity.lock.DELAY 500

section .data

extern current.coords, current.offset

p007 dq 0.007
p8 dq 0.8
d1000 dq 1000.0

; Millisecond interval at which to apply gravity.
gravity.interval dd 1000

; Gravity and lock delay timers.
global gravity.timer
gravity.timer dq 0
gravity.lock.timer dq 0

; Lock delay movement counter.
gravity.lock.counter db 15

section .text

extern interval, delay
extern current.fall, current.lock
extern well.collide?
extern level

; gravity.fall()
; Apply gravity to falling tetromino.
global gravity.fall
gravity.fall:
  push dword [gravity.interval]
  push gravity.timer
  call interval
  add esp, 8
  test eax, eax
  jz .ret

  call current.fall

  .ret:
    ret

; gravity.update()
; Update gravity interval based on current level.
global gravity.update
gravity.update:
  ; (0.8 - (level - 1) * 0.007) ^ (level - 1) * 1000

  ; a = level - 1
  push dword [level]
  dec dword [esp]

  ; b = a * 0.007
  fild dword [esp]
  fmul qword [p007]

  ; c = 0.8 - b
  fsubr qword [p8]

  ; d = c ^ a
  fild dword [esp]
  fxch
  fyl2x
  f2xm1
  fld1
  faddp

  ; e = d * 1000
  fmul qword [d1000]

  fistp dword [esp]
  pop eax
  mov [gravity.interval], eax

  ret

; gravity.lock()
; Apply lock delay. Returns non-zero on update.
global gravity.lock
gravity.lock:
  push ebx

  ; Determine if lock delay is in progress.
  test dword [gravity.lock.timer], 0xFFFFFFFF
  setnz bl

  ; Determine if tetromino can move down.
  push word [current.coords]
  inc byte [esp + 1]
  push word [current.offset]
  call well.collide?
  setnz bh
  add esp, 4

  ; If lock delay in progress and can move down, reset.
  test bh, bl
  jz .check
  mov dword [gravity.lock.timer], 0
  mov dword [gravity.lock.timer + 4], 0
  mov byte [gravity.lock.counter], 15
  jmp .ret

  ; If lock delay in progress and can't move down, check if expired and lock.
  .check:
    test bl, bl
    jz .start

    ; Lock if move counter is expired.
    cmp byte [gravity.lock.counter], 0
    je .lock

    ; Lock if delay is expired.
    push dword gravity.lock.DELAY
    push gravity.lock.timer
    call delay
    add esp, 8
    test eax, eax
    jz .ret

  .lock:
    call current.lock
    pop ebx
    ret

  ; Start lock delay if can't move down.
  .start:
    test bh, bh
    jnz .ret

    push dword gravity.lock.DELAY
    push gravity.lock.timer
    call delay
    add esp, 8

  .ret:
    xor eax, eax
    pop ebx
    ret

; gravity.lock.reset()
; Decrement the lock delay movement counter and reset the lock delay timer.
global gravity.lock.reset
gravity.lock.reset:
  ; Do nothing if lock delay is not currently in progress.
  cmp dword [gravity.lock.timer], 0
  je .ret

  ; Decrement counter and reset timer.
  dec byte [gravity.lock.counter]
  mov dword [gravity.lock.timer], 0
  mov dword [gravity.lock.timer + 4], 0

  .ret:
    ret

%ifdef DEBUG
%include "debug.mac"

extern itoa, puts

global gravity.debug
gravity.debug:
  push word 0x0A0A
  push dword [gravity.interval]
  call itoa
  push dword debug.Y << 24 | debug.X << 16 | debug.ATTRS
  push eax
  call puts
  add esp, 14

  push word 0x1008
  push dword [gravity.timer + 4]
  call itoa
  push dword (debug.Y + 1) << 24 | debug.X << 16 | debug.ATTRS
  push eax
  call puts
  push word 0x1008
  push dword [gravity.timer]
  call itoa
  push dword (debug.Y + 1) << 24 | (debug.X + 8) << 16 | debug.ATTRS
  push eax
  call puts
  add esp, 28

  push word 0x1008
  push dword [gravity.lock.timer + 4]
  call itoa
  push dword (debug.Y + 2) << 24 | debug.X << 16 | debug.ATTRS
  push eax
  call puts
  push word 0x1008
  push dword [gravity.lock.timer]
  call itoa
  push dword (debug.Y + 2) << 24 | (debug.X + 8) << 16 | debug.ATTRS
  push eax
  call puts
  add esp, 28

  push word 0x0A03
  push dword [gravity.lock.counter]
  call itoa
  push dword (debug.Y + 3) << 24 | debug.X << 16 | debug.ATTRS
  push eax
  call puts
  add esp, 14

  ret

%endif
