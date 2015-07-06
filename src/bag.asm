section .data

; Shuffled bag of tetromino offsets.
global bag
bag dw 0x100, 0x200, 0x300, 0x400, 0x500, 0x600, 0x700
bag$:

; Pointer to next tetromino in bag.
global bag.next
bag.next dd bag

section .text

extern shufflew

; bag.shuffle()
; Shuffle the bag and reset the bag_next pointer.
global bag.shuffle
bag.shuffle:
  push dword 7
  push bag
  call shufflew
  add esp, 8

  mov dword [bag.next], bag

  ret

; bag.pop()
; Return the next tetromino offset in the bag. Decrement the bag_next pointer
; and re-shuffle if necessary.
global bag.pop
bag.pop:
  mov eax, [bag.next]
  movzx eax, word [eax]

  add dword [bag.next], 2

  cmp dword [bag.next], bag$
  jne .ret

  push eax
  call bag.shuffle
  pop eax

  .ret:
    ret

; bag.init()
; Shuffle the bag until the first tetrimono is not S or Z.
global bag.init
bag.init:
  .loop:
    call bag.shuffle

    cmp word [bag], 0x500
    je .loop
    cmp word [bag], 0x700
    je .loop

  ret

%ifdef DEBUG
%include "debug.mac"

extern itoa, puts

global bag.debug
bag.debug:
  push ebx
  push edi

  mov ebx, bag
  mov edi, debug.Y << 24 | debug.X << 16 | debug.ATTRS
  mov ecx, 7
  .loop:
    push ecx

    push word 0x1003
    push dword [ebx]
    call itoa
    push edi
    push eax
    call puts
    add esp, 14

    add ebx, 2
    add edi, 4 << 16

    pop ecx
    loop .loop

  push word 0x1003
  mov eax, [bag.next]
  push dword [eax]
  call itoa
  push dword (debug.Y + 1) << 24 | debug.X << 16 | debug.ATTRS
  push eax
  call puts
  add esp, 14

  pop edi
  pop ebx
  ret

%endif
