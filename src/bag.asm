section .data

; Shuffled bag of tetromino offsets.
global bag
bag dw 0x100, 0x200, 0x300, 0x400, 0x500, 0x600, 0x700

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

  ; bag_next is past the end of bag.
  cmp dword [bag.next], bag.next
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
