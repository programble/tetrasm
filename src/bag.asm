section .data

; Shuffled bag of tetromino offsets.
bag dw 0x100, 0x200, 0x300, 0x400, 0x500, 0x600, 0x700

; Pointer to next tetromino in bag.
global bag_next
bag_next dd bag

section .text

extern shufflew

; bag_shuffle()
; Shuffle the bag and reset the bag_next pointer.
global bag_shuffle
bag_shuffle:
  push dword 7
  push bag
  call shufflew
  add esp, 8

  mov dword [bag_next], bag

  ret

; bag_pop()
; Return the next tetromino offset in the bag. Decrement the bag_next pointer
; and re-shuffle if necessary.
global bag_pop
bag_pop:
  mov eax, [bag_next]
  movzx eax, word [eax]

  add dword [bag_next], 2

  ; bag_next is past the end of bag.
  cmp dword [bag_next], bag_next
  jne .ret

  push eax
  call bag_shuffle
  pop eax

  .ret:
    ret

; bag_init()
; Shuffle the bag until the first tetrimono is not S or Z.
global bag_init
bag_init:
  .loop:
    call bag_shuffle

    cmp word [bag], 0x500
    je .loop
    cmp word [bag], 0x700
    je .loop

  ret
