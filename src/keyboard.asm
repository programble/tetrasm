section .data

key db 0

section .text

; scan()
global scan
scan:
  push ebp
  mov ebp, esp

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
    mov esp, ebp
    pop ebp
    ret
