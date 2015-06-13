ENTRY (boot)
SECTIONS
{
  . = 0x00100000;
  .multiboot : { *(.multiboot) }
  .text      : { *(.text) }
  .data      : { *(.data) }
  .bss       : { *(.bss) }
}
