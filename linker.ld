ENTRY (boot)
SECTIONS
{
  .multiboot 0x00100000 : { *(.multiboot) }

  .text ALIGN(0x1000) : { *(.text) }
  .data ALIGN(0x1000) : { *(.data) }
  .bss  ALIGN(0x1000) : { *(.bss) }
}
