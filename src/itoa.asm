section .data

digits db '0123456789ABCDEF'

; Maximum length, 32 bits formatted as binary and a null-terminator.
output db '00000000000000000000000000000000', 0

section .text

; itoa(dword number, byte width, byte radix)
; Format number as string of width in radix. Returns pointer to string.
global itoa
itoa:
  push ebp
  mov ebp, esp
  push ebx
  push esi
  push edi

  ; Start at end of output string and work backwards.
  lea edi, [output + 32]
  std

  ; Load number and radix for division and iteration.
  mov eax, [ebp + 8] ; number
  movzx ebx, byte [ebp + 13] ; radix

  ; Loop width times.
  movzx ecx, byte [ebp + 12] ; width

  .loop:
    ; Clear remainder / upper bits of dividend.
    xor edx, edx

    ; Divide number by radix.
    div ebx

    ; Use remainder to set digit in output string.
    lea esi, [digits + edx]
    movsb

    loop .loop

  ; The last movsb brought us too far back.
  lea eax, [edi + 1]

  cld
  pop edi
  pop esi
  pop ebx
  mov esp, ebp
  pop ebp
  ret
