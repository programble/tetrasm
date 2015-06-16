section .text

; rand(dword range)
; Generate a random number from 0 inclusive to range exclusive.
global rand
rand:
  push ebp
  mov ebp, esp

  rdtsc
  div dword [ebp + 8] ; range
  mov eax, edx

  mov esp, ebp
  pop ebp
  ret
