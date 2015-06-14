section .data

digits db '0123456789ABCDEF'

section .bss

fstr resb 34

section .text

; itoa(dword number, byte width, byte radix)
global itoa
itoa:
  push ebp
  mov ebp, esp
  push ebx
  push edi

  ; Start at end of output string, set null terminator.
  mov edi, fstr
  add edi, 33
  mov byte [edi], 0

  ; Keep track of width.
  xor cl, cl

  ; Load number for division and iteration.
  mov eax, [ebp + 8] ; number

  .loop:
    dec edi

    ; Divide number by radix.
    movzx ebx, byte [ebp + 13] ; radix
    cdq
    div ebx

    ; Use remainder to set digit in output string.
    mov edx, [digits + edx]
    mov [edi], dl

    ; Check if we've reached the right width yet.
    inc cl
    cmp cl, [ebp + 12] ; width
    jl .loop

  mov eax, edi

  pop edi
  pop ebx
  mov esp, ebp
  pop ebp
  ret
