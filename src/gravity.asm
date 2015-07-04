; Lock delay in milliseconds.
%define gravity.lock.DELAY 500

section .data

extern current.coords, current.offset

; Millisecond interval at which to apply gravity.
gravity.interval dd 1000

; Gravity and lock delay timers.
gravity.timer dq 0
gravity.lock.timer dq 0

; Lock delay movement counter.
gravity.lock.counter db 15

section .text

extern interval, delay
extern current.fall, current.lock
extern well.collide?

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
