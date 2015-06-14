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
