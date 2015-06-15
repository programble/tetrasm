section .data

; Qword previous tick count.
ptsc dd 0, 0

; Previous RTC second for tps.
psec db 0xFF

section .bss

; Number of CPU ticks per millisecond.
global tpms
tpms resw 1

section .text

; rtcs()
; Return the second value of the real-time-clock. Note that the value may or
; may not be represented such that formatting it as hex displays the correct
; clock time.
global rtcs
rtcs:
  push ebp
  mov ebp, esp

  ; Zero eax for return value.
  xor eax, eax

  ; Keep track of last second value.
  xor dl, dl

  .oloop:
    ; Wait for update not in progress.
    .iloop:
      mov al, 0x0A
      out 0x70, al
      in al, 0x71
      test al, 0x80
      jnz .iloop

    ; Read seconds
    xor al, al
    out 0x70, al
    in al, 0x71

    ; Wait until value is the same twice in a row.
    cmp al, dl
    mov dl, al
    jne .oloop

  mov esp, ebp
  pop ebp
  ret

; tps()
; Update tpms based on the number of ticks in the last second, if a second has
; passed since the last call.
global tps
tps:
  push ebp
  mov ebp, esp
  sub esp, 8 ; ntsc
  push esi
  push edi

  ; Return if a second hasn't passed since last call.
  call rtcs
  cmp al, [psec]
  je .ret
  mov [psec], al

  ; Get number of ticks since boot.
  rdtsc

  ; Save ntsc to update ptsc.
  mov [ebp - 8], eax ; ntsc
  mov [ebp - 4], edx ; ntsc

  ; Calculate difference in ticks.
  sub eax, [ptsc]
  sbb edx, [ptsc + 4]

  ; Divide by 1000 and set tpms.
  mov ecx, 1000
  div ecx
  mov [tpms], eax

  ; Update ptsc.
  mov edi, ptsc
  lea esi, [ebp - 8] ; ntsc
  movsd
  movsd

  .ret:
    pop edi
    pop esi
    mov esp, ebp
    pop ebp
    ret
