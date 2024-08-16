// Holds all offsets

// Base physical address
.equ    MMIO_BASE,              0x3F000000

// Mailbox offsets
.equ    MBOX_BASE,              MMIO_BASE + 0x0000B880
.equ    MBOX_READ,              MBOX_BASE + 0x0
.equ    MBOX_POLL,              MBOX_BASE + 0x10
.equ    MBOX_SENDER,            MBOX_BASE + 0x14
.equ    MBOX_STATUS,            MBOX_BASE + 0x18
.equ    MBOX_CONFIG,            MBOX_BASE + 0x1C
.equ    MBOX_WRITE,             MBOX_BASE + 0x20

// Sys timer
.equ    SYSTMR_LO,              MMIO_BASE + 0x00003004
.equ    SYSTMR_HI,              MMIO_BASE + 0x00003008

// UART offsets
.equ    GPFSEL1,                MMIO_BASE+0x00200004
.equ    GPPUD,                  MMIO_BASE+0x00200094
.equ    GPPUDCLK0,              MMIO_BASE+0x00200098

.equ    UART0_DR,               MMIO_BASE+0x00201000
.equ    UART0_FR,               MMIO_BASE+0x00201018
.equ    UART0_IBRD,             MMIO_BASE+0x00201024
.equ    UART0_FBRD,             MMIO_BASE+0x00201028
.equ    UART0_LCRH,             MMIO_BASE+0x0020102C
.equ    UART0_CR,               MMIO_BASE+0x00201030
.equ    UART0_ICR,              MMIO_BASE+0x00201044
