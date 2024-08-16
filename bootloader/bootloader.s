.global bootloader_main

.include "./utils.s"

.section .data
current_y:
    .int 16

selected_option:
    .int 0

timer:
    .int 30000 //30s

boot_intro_text:
    .string "Rasberry Pi 3b+ Bootloader\nBy Mohamed Ammar and Seif Tamer"

preparing_text:
    .string "Preparing..."

booting_up_text:
    .string "Booting up..."

boot_menu_title:
    .string "Bootloader Menu"

boot_menu_description:
    .string "Select an option to boot from"

boot_option_1:
    .string "1. Game Console OS"

boot_option_2:
    .string "2. Terminal"

booting_into_text:
    .string "Booting into:"

loading_text:
    .string "Loading..."

.section .text

// ----------------------------------------------------------------------
// Main bootloader function
//
// Arguments:
//
// Returns:
//
// ----------------------------------------------------------------------
bootloader_main:
    pusha64

    // disable double buffering
    mov     w0, wzr
    bl      fb_set_double_buffer

    // clear screen
    ldr     w0, =0xff181818
    bl      fb_clear

    // boot intro

    // fixed increment of 48
    mov     w1, #48

    // display text
    adr     x0, boot_intro_text
    bl      print_boot_text

    // wait for 3 seconds
    mov     w0, #3000
    bl      delay_msec

    // preparing
    adr     x0, preparing_text
    bl      print_boot_text

    // wait for 4 seconds
    mov     w0, #4000
    bl      delay_msec

    // booting up
    adr     x0, booting_up_text
    bl      print_boot_text

    // wait for 2 seconds
    mov     w0, #2000
    bl      delay_msec

    // boot menu
    bl      boot_menu

    // result
    // clear screen
    ldr     w0, =0xff181818
    bl      fb_clear

    // reset cursor position
    mov     w0, #16
    setv    w0, current_y

    adr     x0, booting_into_text
    bl      print_boot_text

    getv    w1, selected_option
    cmp     w1, #0
    beq     boot_game_console
    b       bool_terminal

boot_game_console:
    adr     x0, boot_option_1
    add     x0, x0, #3
    mov     w1, #48
    bl      print_boot_text

    adr     x5, composite_menu
    b       1f

bool_terminal:
    adr     x0, boot_option_2
    add     x0, x0, #3
    mov     w1, #48
    bl      print_boot_text
    adr     x5, terminal

1:
    // display text
    adr     x0, booting_up_text
    bl      print_boot_text

    // wait for 2 seconds
    mov     w0, #2000
    bl      delay_msec

    // clear to black
    ldr     w0, =0xff000000
    bl      fb_clear

    // loading screen
    adr     x0, loading_text
    mov     w1, #280
    mov     w2, #228
    ldr     w3, =0xffccc099
    mov     w4, #3
    bl      fb_drawstring

    // wait for 2 seconds
    mov     w0, #2000
    bl      delay_msec

    // jump to x1
    blr     x5

    popa64
    ret

boot_menu:
    pusha64

    // get dims
    getv    w10, fb_width
    getv    w11, fb_height

    // clear
    ldr     w0, =0xff181818
    bl      fb_clear

    // draw thick border
    mov     w0, 24
    mov     w1, 24

    mov     w2, w10
    sub     w2, w2, 48

    mov     w3, w11
    sub     w3, w3, 48

    ldr     w4, =0xffbfbfbf
    bl      fb_drawfilledrect

    // draw border fg
    mov     w0, 32
    mov     w1, 32

    mov     w2, w10
    sub     w2, w2, 64

    mov     w3, w11
    sub     w3, w3, 64

    ldr     w4, =0xff181818
    bl      fb_drawfilledrect

    // draw title
    adr     x0, boot_menu_title
    mov     w1, #220
    mov     w2, #48
    ldr     w3, =0xffccc099
    mov     w4, #3
    bl      fb_drawstring

    // draw description
    adr     x0, boot_menu_description
    mov     w1, #48
    mov     w2, #100
    ldr     w3, =0xffccc099
    mov     w4, #2
    bl      fb_drawstring

draw_options:
    getv    w12, selected_option

    // draw options

    adr     x0, boot_option_1
    mov     w1, #150
    mov     w2, #0
    bl      draw_option

    adr     x0, boot_option_2
    mov     w1, #200
    mov     w2, #1
    bl      draw_option

    // wait for input
input:
    mov     w0, #10
    bl      delay_msec

    bl      handle_input

    cmp     w0, 'w'
    beq     menu_decrement_option

    cmp     w0, 's'
    beq     menu_increment_option

    cmp     w0, '\n'
    beq     menu_enter

    b       input

menu_increment_option:
    add     w12, w12, #1
    cmp     w12, #1
    ble     update_options

    // set 0
    mov     w12, wzr
    b       update_options

menu_decrement_option:
    sub     w12, w12, #1
    cmp     w12, wzr
    bge     update_options

    // set 0
    mov     w12, #1
    b       update_options

update_options:
    setv    w12, selected_option
    b       draw_options

menu_enter:
    // now exit

    popa64
    ret

// ----------------------------------------------------------------------
// Draws a string on the screen
//
// Arguments:
//      x0 - address of text
//      w1 - y
//      w2 - option
draw_option:
    pusha64

    mov     x13, x0 // address of text
    mov     w14, w1 // y
    mov     w15, w2 // option

    // draw border
    mov     w0, 32
    mov     w1, w14

    mov     w2, w10
    sub     w2, w2, 64

    mov     w3, 48
    ldr     w4, =0xff181818

    // check if opt is selected
    cmp     w12, w15
    bne     1f
    ldr     w4, =0xffbfbfbf

1:
    bl      fb_drawfilledrect

    mov     x0, x13
    mov     w1, #48
    mov     w2, w14
    add     w2, w2, #17
    ldr     w3, =0xffccc099

    // check if opt is selected
    cmp     w12, w15
    bne     2f
    ldr     w3, =0xff000000

2:
    mov     w4, #2
    bl      fb_drawstring

    popa64
    ret

// ----------------------------------------------------------------------
// Prints boot text
//
// Arguments:
//      x0 - address of text
//      w1 - increment y
//
// Returns:
//
// ----------------------------------------------------------------------
print_boot_text:
    push    x30
    pushp   x1, x2
    pushp   x3, x4
    push    x5

    mov     w5, w1

    // display text
    mov     w1, #16
    getv    w2, current_y
    ldr     w3, =0xffccc099 //4daeec
    mov     w4, #2
    bl      fb_drawstring

    // increment y
    add     w2, w2, w5
    setv    w2, current_y

    pop     x5
    popp    x3, x4
    popp    x1, x2
    pop     x30
    ret

terminal:
    // enable double buffering
    mov     w0, #1
    bl      fb_set_double_buffer

1:
    // temp display m&s
    bl      gfx_beginframe

    // clear screen
    ldr     w0, =0xff1f1f1f
    bl      fb_clear

    bl      game_loop

    bl      gfx_endframe

    // sleep for 10ms
    mov     w0, #10
    bl      delay_msec

    b       1b

    ret
