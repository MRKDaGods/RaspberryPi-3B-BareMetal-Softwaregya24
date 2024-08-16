.global uart_init
.global uart_try_getc

.include "utils.s"
.include "offsets.s"

// gpio constants
    .equ MMIO_BASE, 0x3F000000
    

.section .text

// ----------------------------------------------------------------------
// Initialize UART
//
// Arguments:
//
// Returns:
//
// ----------------------------------------------------------------------
uart_init:
    pusha64

    tempReg .req x20

    // *UART0_CR = 0
    ldr tempReg, =UART0_CR
    mov x0, 0
    str w0, [tempReg]

    // x10 = mbox_buffer
    adr x10, mbox_buffer

    // setup clock
    // construct mbox buffer

    mov w0, #9*4
    str w0, [x10]

    str wzr, [x10, #4]// MBOX_REQUEST

    ldr w0, =0x38002 // MBOX_TAG_SETCLKRATE
    str w0, [x10, #8]

    mov w0, #12
    str w0, [x10, #12]

    mov w0, #8
    str w0, [x10, #16]

    mov w0, #2 // UART clock
    str w0, [x10, #20]

    ldr w0, =4000000 // 4Mhz
    str w0, [x10, #24]

    str wzr, [x10, #28]// clear turbo

    str wzr, [x10, #32]// MBOX_TAG_LAST

    mov w0, #8 // MBOX_CH_PROP
    bl mbox_call

    // map UART0 to GPIO pins
    ldr tempReg, =GPFSEL1
    ldr w1, [tempReg]// read GPFSEL1

    // gpio14, gpio15
    mov w0, #0xFFFC0FFF // w0 = ~((7 << 12) | (7 << 15))
    and w1, w1, w0 // w1 &= w0

    // alt0 for gpio14, gpio15
    ldr w0, =0x24000 // w0 = (4 << 12) | (4 << 15)
    orr w1, w1, w0 // w1 |= w0

    ldr tempReg, =GPFSEL1
    str w1, [tempReg]// write GPFSEL1

    // enable pins 14 and 15
    ldr tempReg, =GPPUD
    str wzr, [tempReg]

    // wait for 150 cycles
    mov w0, #150
    bl wait_cycles

    // clock the changes into the GPIO pins
    ldr tempReg, =GPPUDCLK0
    mov w0, #0xC000 // w0 = (1 << 14) | (1 << 15)
    str w0, [tempReg] // *GPPUDCLK0 = w0

    // wait for 150 cycles
    mov w0, #150
    bl wait_cycles

    // flush GPIO setup
    str wzr, [tempReg]

    // clear interrupts
    ldr tempReg, =UART0_ICR
    mov w0, #0x7FF
    str w0, [tempReg]

    // 115200 baud
    ldr tempReg, =UART0_IBRD
    mov w0, #2
    str w0, [tempReg]

    ldr tempReg, =UART0_FBRD
    mov w0, 0xB
    str w0, [tempReg]

    // 8n1, FIFO enabled
    ldr tempReg, =UART0_LCRH
    mov w0, 0x70
    str w0, [tempReg]

    // enable UART0, receive & transfer part of UART
    ldr tempReg, =UART0_CR
    mov w0, 0x301
    str w0, [tempReg]

.unreq tempReg

    popa64
    ret

// ----------------------------------------------------------------------
// Try to get a character from UART
//
// Arguments:
//
// Returns:
//  w0 - character if available, 0 otherwise
//
// ----------------------------------------------------------------------
uart_try_getc:
    push x1

    // if *UART0_FR & 0x10 == 0, return 0
    ldr x1, =UART0_FR
    ldr w0, [x1]
    and w0, w0, #0x10
    cbz w0, 1f
    mov w0, wzr
    b 2f

1:
    // return *UART0_DR
    ldr x1, =UART0_DR
    ldr w0, [x1]

2:
    pop x1
    ret
