# Tetrasm

Tetris for x86 in NASM.

Somewhat a port from C of
[Bare Metal Tetris](https://github.com/programble/bare-metal-tetris).

![Screenshot](https://raw.githubusercontent.com/programble/tetrasm/master/screenshot.png)

## Features

- Ghost
- Preview
- Hold
- Scoring
- Levels with increasing gravity
- Line clear "animation"
- Lock delay with limited movement
- Pause

## Binaries

ELF binaries and ISO images can be downloaded on the [releases][releases] page.

[releases]: https://github.com/programble/tetrasm/releases

## Dependencies

- [NASM][nasm], with support for `elf32` output format
- Linker capable of emulating `elf_i386`
- `genisoimage` (from [cdrkit][cdrkit]) or `mkisofs` (from [cdrtools][cdrtools])

If the system linker does not support emulating `elf_i386`, a cross-linker can
be built from [GNU binutils][binutils]. Use `./configure --target i386-elf`,
then set `LD = i386-elf-ld`.

To use `mkisofs` instead of `genisoimage`, set `GENISOIMAGE = mkisofs`.

Make variables can be set on the command line or in `config.mk`.

[nasm]: http://nasm.us
[cdrkit]: https://en.wikipedia.org/wiki/Cdrkit
[cdrtools]: https://en.wikipedia.org/wiki/Cdrtools
[binutils]: http://www.gnu.org/software/binutils/

## Build

```
make
```

This will assemble and link a multiboot ELF file, `tetrasm.elf`.

The default build is `debug`, which includes debug symbols and runtime debug
functions. The `release` build excludes these.

```
make BUILD=release
```

There is also a test build, which features tests of the core functions rather
than the game.

```
make BUILD=test
```

## ISO

```
make iso
```

This will create a bootable ISO using GRUB Legacy, `tetrasm.iso`.

## Emulation

```
make qemu
```

This will boot `tetrasm.elf` in QEMU using multiboot.

```
make qemu-iso
```

This will boot `tetrasm.iso` in QEMU.

## Debugging

```
make gdb
```

This will attach GDB to QEMU started from `make qemu`.

## License

Copyright © 2015, Curtis McEnroe <curtis@cmcenroe.me>

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
