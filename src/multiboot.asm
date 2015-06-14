MAGIC equ 0x1BADB002
FLAGS equ 0x0
CHECKSUM equ -(MAGIC + FLAGS)

section .multiboot

dd MAGIC
dd FLAGS
dd CHECKSUM
