section .text

; rand(dword range)
; Generate a random number from 0 inclusive to range exclusive.
global rand
rand:
  push ebp
  mov ebp, esp

  rdtsc

  ; Zero out edx so quotient can always fit in eax.
  xor edx, edx

  ; Modulo range.
  div dword [ebp + 8] ; range
  mov eax, edx

  mov esp, ebp
  pop ebp
  ret
