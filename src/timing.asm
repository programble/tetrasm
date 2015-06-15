section .data

; 64-bit tick count.
ti dd 0, 0

last_sec db 0xFF

section .bss

; Number of CPU ticks per millisecond
global tpms
tpms resw 1

section .text

; rtcs()
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
global tps
tps:
  push ebp
  mov ebp, esp
  sub esp, 8 ; tf
  push esi
  push edi

  ; Return if a second hasn't passed since last call.
  call rtcs
  cmp al, [last_sec]
  je .ret
  mov [last_sec], al

  ; Get number of ticks since boot.
  rdtsc

  ; Save tf to update ti.
  mov [ebp - 8], eax ; tf
  mov [ebp - 4], edx ; tf

  ; Calculate difference in ticks.
  sub eax, [ti]
  sbb edx, [ti + 4]

  ; Divide by 1000 and set tpms.
  mov ecx, 1000
  div ecx
  mov [tpms], eax

  ; Update ti.
  mov edi, ti
  lea esi, [ebp - 8] ; tf
  movsd
  movsd

  .ret:
    pop edi
    pop esi
    mov esp, ebp
    pop ebp
    ret
