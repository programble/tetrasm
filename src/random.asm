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

; shuffle(dword array, dword length)
; Shuffle length bytes pointed to by array using Fisher-Yates.
global shuffle
shuffle:
  push ebp
  mov ebp, esp
  push ebx

  mov ebx, [ebp + 8] ; array

  ; Start at end of array.
  mov ecx, [ebp + 12] ; length
  sub ecx, 1

  .loop:
    ; Choose random index to swap with.
    lea eax, [ecx + 1]
    push eax
    call rand
    add esp, 4

    ; Swap values.
    mov dl, [ebx + ecx]
    xchg dl, [ebx + eax]
    mov [ebx + ecx], dl

    loop .loop

  pop ebx
  mov esp, ebp
  pop ebp
  ret
