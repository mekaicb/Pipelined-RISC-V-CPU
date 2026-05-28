ENTRY(_start)

MEMORY {
    ROM (rx)  : ORIGIN = 0x00000000, LENGTH = 64K
    RAM (rwx) : ORIGIN = 0x00010000, LENGTH = 128K
}

SECTIONS {
    .text : {
        *(.text*)
    } > ROM

    .data : {
        *(.data*)
        *(.rodata*)
    } > RAM

    .bss : {
        *(.bss*)
        *(COMMON)
    } > RAM
}