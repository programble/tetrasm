section .data

; Previous tick count.
ptsc dq 0

; Previous RTC second for tps.
psec db 0xFF

section .bss

; Number of CPU ticks per millisecond.
global tpms
tpms resd 1

section .text

; rtcs()
; Return the second value of the real-time-clock. Note that the value may or
; may not be represented such that formatting it as hex displays the correct
; clock time.
global rtcs
rtcs:
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

; calibrate()
; Wait at least a full second to calibrate timing.
global calibrate
calibrate:
  push ebx

  call tps
  mov ebx, [tpms]

  .loop1:
    call tps
    cmp ebx, [tpms]
    je .loop1

  mov ebx, [tpms]
  .loop2:
    call tps
    cmp ebx, [tpms]
    je .loop2

  pop ebx
  ret

; interval(dword timer, dword ms)
; Return non-zero every ms milliseconds for the 64-bit tick count pointed to by
; timer.
global interval
interval:
  push ebp
  mov ebp, esp
  sub esp, 8 ; ntsc
  push ebx
  push esi
  push edi

  ; Calculate number of ticks for ms and store in esi:edi.
  mov eax, [tpms]
  mul dword [ebp + 12] ; ms
  mov esi, eax
  mov edi, edx

  ; Get number of ticks and save to update timer.
  rdtsc
  mov [ebp - 8], eax ; ntsc
  mov [ebp - 4], edx ; ntsc

  ; Get difference in ticks.
  mov ebx, [ebp + 8] ; timer
  sub eax, [ebx]
  sbb edx, [ebx + 4]

  ; Check if difference is greater than or equal to ticks for ms.
  cmp edx, edi
  jb .false
  ja .true
  cmp eax, esi
  jb .false

  .true:
    ; Update timer with new tsc.
    lea esi, [ebp - 8] ; ntsc
    mov edi, ebx
    movsd
    movsd

    jmp .ret

  .false:
    xor eax, eax

  .ret:
    pop edi
    pop esi
    pop ebx
    mov esp, ebp
    pop ebp
    ret

; delay(dword timer, dword ms)
; Return non-zero if at least ms milliseconds have elapsed since the first call
; for this timer and reset the timer.
global delay
delay:
  push ebp
  mov ebp, esp
  push ebx
  push esi
  push edi

  ; Check if timer is set. Skip high bits.
  mov ebx, [ebp + 8] ; timer
  cmp dword [ebx], 0
  jne .set

  ; Otherwise, set timer and return zero.
  rdtsc
  mov [ebx], eax
  mov [ebx + 4], edx
  jmp .false

  .set:
    ; Calculate number of ticks for ms and store in esi:edi.
    mov eax, [tpms]
    mul dword [ebp + 12] ; ms
    mov esi, eax
    mov edi, edx

    ; Calculate difference in ticks.
    rdtsc
    sub eax, [ebx]
    sbb edx, [ebx + 4]

    ; Check if difference is greater than or equal to ticks for ms.
    cmp edx, edi
    jb .false
    ja .true
    cmp eax, esi
    jb .false

    .true:
      ; Reset timer.
      mov dword [ebx], 0
      mov dword [ebx + 4], 0
      jmp .ret

    .false:
      xor eax, eax

  .ret:
    pop edi
    pop esi
    pop ebx
    mov esp, ebp
    pop ebp
    ret
