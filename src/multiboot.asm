%define MAGIC 0x1BADB002
%define FLAGS 0x0
%define CHECKSUM -(MAGIC + FLAGS)

section .multiboot

dd MAGIC
dd FLAGS
dd CHECKSUM
