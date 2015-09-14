%ifdef COM

bits 16
org 0x100

section .text

jmp boot

%macro extern 1+
%endmacro
%macro global 1+
%endmacro

%include "about.asm"
%include "bag.asm"
%include "boot.asm"
%include "current.asm"
%include "debug.asm"
%include "game.asm"
%include "ghost.asm"
%include "gravity.asm"
%include "help.asm"
%include "hold.asm"
%include "itoa.asm"
%include "keyboard.asm"
%include "main.asm"
%include "multiboot.asm"
%include "preview.asm"
%include "random.asm"
%include "score.asm"
%include "tests.asm"
%include "tetrominoes.asm"
%include "timing.asm"
%include "video.asm"
%include "well.asm"

%endif
