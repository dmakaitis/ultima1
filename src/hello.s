;-------------------------------------------------------------------------------
;
; hello.s
;
; This program initializes the system, displays the title page, and optionally
; prompts the user for which floppy driver to use (probably to implement some
; kind of fast loader for the 1541). It contains all coded needed to load and
; save files to disk.
;-------------------------------------------------------------------------------

.include "c64.inc"
.include "kernel.inc"

        .setcpu "6502"

        .export main, load_file, load_file_cached, save_file

PROCESSOR_PORT  := $01

LOAD_ADDRESS    := $AE

SHIFT_HANDLER_VECTOR:= $028F
BASIC_IDLE_LOOP_VECTOR:= $0302
CHROUT_VECTOR   := $0326
LOAD_VECTOR     := $0330

display_logo    := $0C00

L4946           := $4946

DEFAULT_BASIC_IDLE_LOOP:= $A483

selected_drive_type:= $B000

fast_serial_buffer:= $C600
LC609           := $C609
LC632           := $C632

custom_nmi_handler:= $CE00

COLOR_RAM       := $D800

DEFAULT_SHIFT_HANDLER:= $EB48
DEFAULT_LOAD_HANDLER:= $F4A5

;-------------------------------------------------------------------------------
;
; The load address for this file is always set to $2000, but is ignored. The
; actual location where this code should be loaded into memory is $8000.
;
;-------------------------------------------------------------------------------

.segment "LOADADDR"

    .addr   $2000

.segment "HELLO_CODE"

;-----------------------------------------------------------
;                           main
;
; Entry point for Ultima 1. Initializes the system, then
; loads the next part of game code.
;-----------------------------------------------------------

main:   sei
        lda     #$36                    ; Enable RAM at $A000-$BFFF, I/O at $D000-$DFFF,
        sta     PROCESSOR_PORT          ; and KERNEL ROM at $E000-$FFFF (no BASIC ROM)

        lda     #$7f                    ; Enable all interrupts on the CIA chips
        sta     CIA1_ICR
        sta     CIA2_ICR
        lda     CIA1_ICR
        lda     CIA2_ICR

        ;-----------------------------------------------------------
        ; Set up custom CHROUT routine
        ;-----------------------------------------------------------

        lda     #$18                    ; Set CHROUT routine to the following:
        sta     $1FFE
        lda     #$60                    ; $1FFE     CLC
        sta     $1FFF                   ;           RTS
        lda     #$FE
        sta     CHROUT_VECTOR
        lda     #$1F
        sta     CHROUT_VECTOR + 1

        ;-----------------------------------------------------------
        ; Set up NMI handler
        ;-----------------------------------------------------------

        lda     NMIVec + 1              ; See if the NMI vector is already set to $CE00
        cmp     #>custom_nmi_handler
        beq     @init_text_display
        lda     #<custom_nmi_handler    ; If not, set it now
        sta     NMIVec
        lda     #>custom_nmi_handler
        sta     NMIVec + 1

        lda     #$40                    ; NMI handler consists of one instruction: RTI
        sta     custom_nmi_handler

        ;-----------------------------------------------------------
        ; Initialize the display
        ;-----------------------------------------------------------

@init_text_display:
        lda     #$00                    ; Set the border and background color to black
        sta     VIC_BORDERCOLOR
        sta     VIC_BG_COLOR0
        jsr     clear_screen

        ldx     #$00                    ; Initialize color memory
@loop_init_color:
        lda     #$01
        sta     COLOR_RAM,x
        sta     COLOR_RAM + $0100,x
        sta     COLOR_RAM + $0200,x
        sta     COLOR_RAM + $0300,x
        inx
        bne     @loop_init_color

        lda     #<title_page            ; Display the title page
        sta     text_src_vec
        lda     #>title_page
        sta     text_src_vec + 1

        @output_addr = $0400 + 7 * 40   ; start output on line 8 of the display

        lda     #<@output_addr                   
        sta     $FE
        lda     #>@output_addr
        sta     $FF
        jsr     display_text_page

        lda     #$17                    ; Set screen memory at $0400 and character/bitmap memory at $2000
        sta     VIC_VIDEO_ADR
        lda     #$08                    ; Set width to 40 columns 
        sta     VIC_CTRL2
        lda     #$17                    ; Turn screen on - set height to 25 rows
        sta     VIC_CTRL1

        ;-----------------------------------------------------------
        ; Load program code to $C000-$C600
        ;-----------------------------------------------------------

        lda     #<high_code_target       ; Copy our "high memory" code from $8400 to $C000
        tay
        sta     $FE
        sta     $FC
        lda     #>high_code_base
        sta     $FF
        lda     #>high_code_target
        sta     $FD
        ldx     #$07
@loop_copy_code:
        lda     ($FE),y
        sta     ($FC),y
        iny
        bne     @loop_copy_code
        inc     $FF
        inc     $FD
        dex
        bpl     @loop_copy_code

        ;-----------------------------------------------------------
        ; Load the file that indicates which floppy driver has been
        ; selected (one byte into $B000).
        ;-----------------------------------------------------------

        ldx     #$10
        jsr     load_file_cached

        ;-----------------------------------------------------------
        ; Initialize vectors
        ;-----------------------------------------------------------

        lda     #<DEFAULT_BASIC_IDLE_LOOP   ; Reset BASIC idle vector to default value ($A483)
        sta     BASIC_IDLE_LOOP_VECTOR
        lda     #>DEFAULT_BASIC_IDLE_LOOP
        sta     BASIC_IDLE_LOOP_VECTOR + 1

        lda     #<DEFAULT_SHIFT_HANDLER ; Reset shift key handler vector to default ($EB48)
        sta     SHIFT_HANDLER_VECTOR
        lda     #>DEFAULT_SHIFT_HANDLER
        sta     SHIFT_HANDLER_VECTOR + 1

        lda     #<DEFAULT_LOAD_HANDLER  ; Reset load vector to default value ($F4A5)
        sta     LOAD_VECTOR
        lda     #>DEFAULT_LOAD_HANDLER
        sta     LOAD_VECTOR + 1

        ;-----------------------------------------------------------
        ; Select floppy drive driver and initialize
        ;-----------------------------------------------------------

        jsr     KERNEL_SCNKEY           ; Check to see if user is holding space bar
        jsr     KERNEL_GETIN
        cmp     #$20
        beq     @prompt_for_drive_type

        lda     selected_drive_type     ; If not, has a drive type already been selected?
        bne     @drive_type_selected

@prompt_for_drive_type:
        jsr     prompt_for_drive_type

@drive_type_selected:
        lda     selected_drive_type     ; Was the non-1541/1571 drive model selected?
        cmp     #$02
        beq     @reset_drive

        sei                             ; Set the load vector to use the 1541 floppy driver
        lda     #<load_handler_1541
        sta     LOAD_VECTOR
        lda     #>load_handler_1541
        sta     LOAD_VECTOR + 1
        cli

@reset_drive:
        ldx     #$5C                    ; Reset the floppy drive
        ldy     #$83
        lda     #$02
        jsr     KERNEL_SETNAM
        lda     #$0F
        tay
        ldx     #$08
        jsr     KERNEL_SETLFS
        jsr     KERNEL_OPEN

        lda     #$0C                    ; Delay while drive resets (should delay until LED is off, but we're guessing here)
        sta     $08
        ldx     #$00
        ldy     #$00
@reset_drive_delay:
        dex
        bne     @reset_drive_delay
        dey
        bne     @reset_drive_delay
        dec     $08
        bpl     @reset_drive_delay

        lda     #$0F
        jsr     KERNEL_CLOSE

        ;-----------------------------------------------------------
        ; Load the file 'LO' into memory at $0800.
        ;-----------------------------------------------------------

        ldx     #$0E
        jsr     load_file_cached

        ;-----------------------------------------------------------
        ; Save the selected floppy driver indicator to disk (file
        ; 'DD').
        ;-----------------------------------------------------------

        ldx     #$00            
        jsr     save_file

        ;-----------------------------------------------------------
        ; Initialization complete - display the Origin logo
        ;-----------------------------------------------------------

        jmp     display_logo




.segment "HELLO_DATA"

title_page:
        .byte   $90,"@@@@@@@@",$FF
        .byte   $90,"Ultima I",$FF
        .byte   $90,"@@@@@@@@",$FF
        .byte   $FF
        .byte   $87,"The First Age of Darkness",$FF
        .byte   $FF
        .byte   $FF
        .byte   $FF
        .byte   $FF
        .byte   $FF
        .byte   $FF
        .byte   $FF
        .byte   $FF
        .byte   $81,"Copyright 1986 by Origin Systems, Inc.",$00




;-----------------------------------------------------------
;                   prompt_for_drive_type
;
; Prompts the user to select which floppy drive type they
; are using. They can either choose a 1541/1571, or an 
; Enhancer 2000 / MSD drive.
;
; The user selection will be written out to $B000 as a byte
; with one of the following values:
;
;   1 - 1541/1571
;   2 - Enhancer 2000 or MSD
;-----------------------------------------------------------

.segment "HELLO_CODE2"

prompt_for_drive_type:
        ldx     #$FF                    ; Pause briefly (probably for user experience reasons)
@delay: iny
        bne     @delay
        dex
        bne     @delay

        jsr     clear_screen

        lda     #$50                    ; Display the select drive prompt
        sta     $FE
        lda     #$04
        sta     $FF
        lda     #$C0
        sta     text_src_vec
        lda     #$81
        sta     text_src_vec + 1
        jsr     display_text_page

@loop:  jsr     KERNEL_SCNKEY           ; Wait until the user is pressing either the '1' or '2' key
        jsr     KERNEL_GETIN
        cmp     #$31
        bcc     @loop
        cmp     #$33
        bcs     @loop

        sec                             ; Convert the PETSCII code of the selection to a byte value and save it
        sbc     #$30
        sta     selected_drive_type

        jsr     clear_screen
        rts




.segment "HELLO_DATA2"

select_drive_page:
        .byte   "Please enter which type of disk drive",$FF
        .byte   "you will be using.  Your choice will",$FF
        .byte   "be saved to disk.  If you need to",$FF
        .byte   "change drives later, hold down the",$FF
        .byte   "space bar while Ultima I is loading to",$FF
        .byte   "return to this menu.",$FF
        .byte   $FF
        .byte   "     1. 1541 or 1571 drive",$FF
        .byte   "     2. Enhancer 2000 or MSD drive",$FF
        .byte   $FF
        .byte   "Note: With some 1571 drives, Ultima I",$FF
        .byte   "will not load correctly if you select",$FF
        .byte   "option 1.  If this happens to you,",$FF
        .byte   "just reboot and select option 2.",$00




reset_drive_command:
        .byte   "UJ"



;-----------------------------------------------------------
;                   display_text_page
;
; Displays a page of text for the user
;
; The word at (display_text_page + 4) must hold the address 
; the text to display will be read from, and the word at
; $FE must hold the address of the first line of screen
; memory where the text should be output.
;-----------------------------------------------------------

text_src_vec   := display_text_page + 3 ; enables modifying the display_text_page code to read from a different location

.segment "HELLO_CODE3"

display_text_page:
        ldy     #$00                    ; y stores the column we're currently writing to
@loop_display_text:
        lda     title_page              ; Read the next code from the source data
        beq     @display_text_page_end  ; If the code is zero, then we are done

        bpl     @mask_character         ; If the code does not have bit seven set, then skip below to print it

        cmp     #$FF                    ; If the code is $FF, then advance to the next line
        beq     @advance_next_line

        and     #$7F                    ; Strip bit 7 from the code. The result is which column to advance to
        tay
        bne     @inc_src_ptr            ; If we are advancing to column 0, then treat it as a new line character

@advance_next_line:
        ldy     #$00                    ; Reset the column back to zero

        lda     $FE                     ; Add 40 to the current screen memory location stored at $FE
        clc
        adc     #$28
        sta     $FE
        lda     $FF
        adc     #$00
        sta     $FF
        bne     @inc_src_ptr            ; Assuming we do not wrap around to write to $0000, advance to the next code...

@mask_character:
        cmp     #$60                    ; Any code greater than $60 needs to have the first three bits stripped off
        bcc     @print_character        ; to determine the output character (this effectively ensures that everything
        and     #$1F                    ; ends up as 'lower' case)

@print_character:
        sta     ($FE),y
        iny

@inc_src_ptr:
        inc     text_src_vec
        bne     @loop_display_text
        inc     text_src_vec + 1
        bne     @loop_display_text

@display_text_page_end:
        rts




;-----------------------------------------------------------
;                   clear_screen
;
; Fills the text display memory with $20 (spaces).
;-----------------------------------------------------------

clear_screen:
        lda     #$00
        tax
@loop_clear_screen:
        lda     #$20
        sta     $0400,x
        sta     $0500,x
        sta     $0600,x
        sta     $0700,x
        inx
        bne     @loop_clear_screen
        rts




.segment "HELLO_DATA3"

unknown_data:
        .byte   $D3,$D9,$D3,$D4,$C5,$CD,$A0,$AA
        .byte   $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
        .byte   $AA,$00,$03,$80,$02,$00,$14,$01
        .byte   $02,$01,$00,$00,$00,$04,$01,$00
        .byte   " "
        .byte   $00,$00,$00,$00,$01,$00,$AE,$D3
        .byte   $D9,$D3,$D4,$C5,$CD,$8D,$08,$C0
        .byte   $B5
        .byte   "B"
        .byte   $8D,$09,$C0,$95
        .byte   "B"
        .byte   $CA,$10,$F3,$A9
        .byte   "(8"
        .byte   $8D,$08,$C0
        .byte   "`;"
        .byte   $FD,$00,$00,$00,$00
        .byte   "Y"
        .byte   $FA
        .byte   "Y"
        .byte   $FF
        .byte   "ZLY"
        .byte   $FF
        .byte   "LY"
        .byte   $FF
        .byte   "LY"
        .byte   $FF


;-----------------------------------------------------------
;
; Everything from this point forward will be copied out to
; $C000, and executed from there...
;


high_code_base:

        .org        $C000

.segment "HELLO_DATA4"

high_code_target:
        .byte   $18,$90,$18,$A9,$A5,$8D
        .byte   "0"
        .byte   $03,$A9,$F4,$8D
        .byte   "1"
        .byte   $03,$A0,$00,$B9
        .byte   ")"
        .byte   $C0,$F0,$06
        .byte   " "
        .byte   $16,$E7,$C8,$D0,$F5
        .byte   "`"
        .byte   $A9
        .byte   "B"
        .byte   $8D
        .byte   "0"
        .byte   $03,$A9,$C0,$8D
        .byte   "1"
        .byte   $03,$A0,$0D,$D0,$E6,$0D
        .byte   "SIZZLE OFF"

        .byte   $0D,$00,$0D
        .byte   "SIZZLE ON"

        .byte   $0D,$00

;-----------------------------------------------------------
;                    1541/1571 load handler
;-----------------------------------------------------------

.segment "HELLO_CODE4"

load_handler_1541:
        sta     $93                     ; Check if we are loading or verifying
        lda     $93
        beq     @use_custom_load_handler    ; Only use custom handler when loading

@use_default_load_handler:
        lda     $93
        jmp     DEFAULT_LOAD_HANDLER

@use_custom_load_handler:
        ldy     #$00                    ; If the filename starts with a '$', fall back to the default handler
        lda     (FNAM),y
        cmp     #$24
        beq     @use_default_load_handler

        lda     #$00
        sta     $90
        jsr     set_secondary_address
        jsr     KERNEL_UNLSTN
        bit     $90
        beq     @clear_buffer
        rts

@clear_buffer:
        ldx     #$10                    ; Clear out our filename buffer
        lda     #$A0
@loop_clear:
        sta     filename_buffer,x
        dex
        bpl     @loop_clear

@loop_copy:
        lda     (FNAM),y                ; Copy filename into the buffer
        sta     filename_buffer,y
        iny
        cpy     FNAM_LEN
        bcc     @loop_copy

        ; Read current status of VIC and CIA2 chips to synchronize serial bus with raster:

        lda     VIC_CTRL1               ; Record the current raster scroll position and write to $FB
        and     #$07
        clc
        adc     #$2F
        sta     $FB

        lda     CIA2_PRA                ; Record the current values of the VIC bank control register from CIA2 into $FC
        and     #$07
        sta     $FC

        ora     #$20                    ; Record the same values, but with bit 5 set into $FE
        sta     $FE

        lda     #$FF
        ldx     #$04
@loop_mask:
        eor     $FC
        rol
        rol
        dex
        bne     @loop_mask
        rol
        sta     $FD                     ; TODO: what is this for?

        lda     #$02                    ; Write 64 bytes from $C22C to the 1541 drive at $0146
        sta     $FF
        lda     #<_1541_fastload_bootstrap
        sta     _1541_data_addr
        lda     #>_1541_fastload_bootstrap
        sta     _1541_data_addr + 1
        lda     #$46
        sta     _1541_mem_addr
        lda     #$01
        sta     _1541_mem_addr + 1
        jsr     write_to_1541_memory

        jsr     set_secondary_address   ; Instruct the 1541 to execute the code we just wrote out there
        ldy     #$00
@loop_send_execute_command:
        lda     _1541_memory_execute_command,y
        jsr     KERNEL_IECOUT
        iny
        cpy     #$05
        bne     @loop_send_execute_command
        jsr     KERNEL_UNLSTN

        jsr     build_serial_control_stream

        sei                             ; Disable interrupts to ensure exact timing

        ; Now send 512 bytes of data from _1541_fastload_code to address $0500 on the 1541:

        ldx     #<_1541_fastload_code ; Write the first 256 bytes of data to $0500
        ldy     #>_1541_fastload_code
        stx     _serial_data_vector
        sty     _serial_data_vector + 1
        lda     #$02
        sta     $FF
@loop_send_1541_data:
        jsr     write_page_to_serial_bus
        inc     _serial_data_vector + 1 ; Advance to the next 256 bytes of data
        dec     $FF
        bne     @loop_send_1541_data

        jsr     read_page_from_serial_bus
        bit     fast_serial_buffer
        bmi     LC140
        ldy     $C3
        ldx     $C4
        lda     SECADR
        beq     LC0FB
        ldy     $C602
        ldx     $C603
LC0FB:  sty     LOAD_ADDRESS
        stx     LOAD_ADDRESS + 1
        ldx     #$04
        lda     fast_serial_buffer
        beq     LC120
LC106:  ldy     #$00
LC108:  lda     fast_serial_buffer,x
        sta     (LOAD_ADDRESS),y
        iny
        inx
        bne     LC108
        jsr     increase_load_addr
        jsr     read_page_from_serial_bus

;-----------------------------------------------------------

        .byte   $A2
LC118:  .byte   $02
        lda     fast_serial_buffer
        bmi     LC143
        bne     LC106
LC120:  ldy     #$00
LC122:  lda     fast_serial_buffer,x
        sta     (LOAD_ADDRESS),y
        iny
        inx
        cpx     $C601
        bcc     LC122
        lda     fast_serial_buffer,x
        sta     (LOAD_ADDRESS),y
        iny
        jsr     increase_load_addr
        clc
LC138:  pha
        pla
        ldx     LOAD_ADDRESS
        ldy     LOAD_ADDRESS + 1
        cli
        rts
LC140:  lda     #$04
        .byte   $2C
LC143:  lda     #$00
        sec
        bcs     LC138




;-----------------------------------------------------------
;                   increase_load_addr
;
; Increases the value of the load address pointer.
;-----------------------------------------------------------

increase_load_addr:
        clc
        tya
        adc     LOAD_ADDRESS
        sta     LOAD_ADDRESS
        lda     LOAD_ADDRESS + 1
        adc     #$00
        sta     LOAD_ADDRESS + 1
        rts




;-----------------------------------------------------------
;                    write_to_1541_memory
;
; Writes data to the memory of the 1541 drive. The memory
; location on the drive to write to must first be set at
; the location '_1541_mem_addr', and the data to write must
; be set at location '_1541_data_addr'. Finally, the value 
; at $FF must be set to the number of 32 byte blocks that
; will be written out.
;-----------------------------------------------------------


write_to_1541_memory:
        jsr     set_secondary_address

        ldy     #$00                    ; Send a command header to write 32 bytes to 1541 memory...
@loop_header:
        lda     _1541_memory_write_command,y
        jsr     KERNEL_IECOUT
        iny
        cpy     #$06
        bne     @loop_header

        ldy     #$00                    ; write the 32 bytes
_1541_data_addr:= * + 1
@loop_data:
        lda     $FFFF,y
        jsr     KERNEL_IECOUT
        iny
        cpy     #$20
        bcc     @loop_data

        lda     _1541_data_addr         ; increment the data address by 32
        adc     #$1F                    ; (adding 0x1f instead of 0x20 because we know the carry flag is set)
        sta     _1541_data_addr
        bcc     @increment_1541_address
        inc     _1541_data_addr + 1

@increment_1541_address:
        clc                             ; increment the source address by 32
        lda     _1541_mem_addr
        adc     #$20
        sta     _1541_mem_addr
        bcc     @complete_1541_command
        inc     _1541_mem_addr + 1

@complete_1541_command:
        jsr     KERNEL_UNLSTN
        dec     $FF
        bne     write_to_1541_memory
        rts




;-----------------------------------------------------------
;                   set_secondary_address
;
; Writes the secondary address to the serial bus. The
; device to write to must be stored in $BA.
;-----------------------------------------------------------

set_secondary_address:
        lda     DEVNUM
        jsr     KERNEL_LISTEN
        lda     #$6F
        jmp     KERNEL_LSTNSA




_1541_memory_write_command:
        .byte   "M-W"
_1541_mem_addr:
        .byte   $00
        .byte   $00
        .byte   $20




_1541_memory_execute_command:
        .byte   "M-E"
        .addr   $0146




;-----------------------------------------------------------
;               build_serial_control_stream
;
; Sets up a sequence of bytes that can be written to the
; CIA2 port A to control the serial bus while only modifying
; the high. The current value of the 4 lower bits of the 
; port must be stored in $FC so the can be properly masked
; with the control stream.
;-----------------------------------------------------------

build_serial_control_stream:
        ldy     #$1F
@loop:  lda     _serial_control_stream,y
        and     #$30
        ora     $FC
        sta     _serial_control_stream,y
        dey
        bpl     @loop
        rts



;-----------------------------------------------------------
; The 'serial control streams' are coded in such a way so
; that each four bit sequence can be transmitted as two
; subsequent values on the CLOCK and DATA lines from the C64
; to the 1541. On the VIA chip of the 1541, these can be
; read as bits 0 and 2 on the serial bus port, so that to
; decode the value, the 1541 simply has to sample the two
; lines, shift the resulting bits left once, then sample the
; two lines again and OR them with the first value.
;
; Since we will be using both the CLOCK and DATA lines, we
; can not depend on using the CLOCK line to synchronize the
; serial communications. Instead, we will be assuming that
; both the C64 and 1541 CPUs are running at the same clock
; speed and that the 1541 will be reading at the same rate
; the C64 is writing. To ensure this, we need to make sure
; that interrupts are disabled on both devices so the
; transfer code is not interrupted. We also need to ensure
; that the C64s VIC chip is not rendering a 'bad' scan
; line so it will not sieze control from the CPU during
; transmission.
;-----------------------------------------------------------

_serial_control_stream:
        .byte   $07,$07,$27,$27,$07,$07,$27,$27
        .byte   $17,$17,$37,$37,$17,$17,$37,$37

_serial_control_stream2:
        .byte   $07,$27,$07,$27,$17,$37,$17,$37
        .byte   $07,$27,$07,$27,$17,$37,$17,$37




;-----------------------------------------------------------
;                write_page_to_serial_bus
;
; This will write 256 bytes to the serial bus using a fast
; transfer protocol. It does this by direct manipulation
; of the clock and data lines through the CIA2 chip.
;
; The address of the data to write must first be stored
; in the word at '_serial_data_vector'. In addition, the
; following values must be stored in the following zero-page
; locations to ensure the VIC chip does not steal control
; from the CPU in the middle of transfering a byte:
;
; lower bits of VIC control 1 + 0x2f => $FB
; lower bits of VIC control 1 => $FC
; lower bits of CIA2_PRA | 0x20 => $FE
;
; This routine uses the memory $C600-$C6FF as a buffer.
;-----------------------------------------------------------

write_page_to_serial_bus:
        ldy     #$00                    ; Copy 256 bytes to buffer at $c600
_serial_data_vector:= * + 1
@loop_copy:                        
        lda     $FFFF,y                 ; lda $C2B2,y
        sta     fast_serial_buffer,y
        iny
        bne     @loop_copy

@wait_for_clock_in_low:  
        bit     CIA2_PRA                ; wait for the 1541 to signal it is ready to receive data
        bvs     @wait_for_clock_in_low

@loop:  lda     fast_serial_buffer,y    ; get the high 4 bits stored at $C600,y and store in x
        lsr     a
        lsr     a
        lsr     a
        lsr     a
        tax

@wait_for_scan_line:
        sec                             ; wait until the VIC is on a 'good' scan line so it will not steal processor time
        lda     VIC_HLINE
        sbc     $FB
        bcc     @scan_line_reached
        and     #$07
        beq     @wait_for_scan_line

@scan_line_reached:
        lda     $FE                     ; set DATA OUT to signal the start of data
        sta     CIA2_PRA
        nop
        lda     _serial_control_stream,x    ; write upper four bits of data (already stored in x above)
        sta     CIA2_PRA
        lda     _serial_control_stream2,x
        sta     CIA2_PRA
        lda     fast_serial_buffer,y    ; write lower four bits of data
        and     #$0F
        tax
        lda     _serial_control_stream,x
        sta     CIA2_PRA
        lda     _serial_control_stream2,x
        sta     CIA2_PRA
        nop

        lda     $FC                     ; Clear CLOCK OUT and DATA OUT
        sta     CIA2_PRA
        iny
        bne     @loop
        rts




;-----------------------------------------------------------
;                _1541_fastload_bootstrap
;
; The following section will be copied out to the 1541 drive
; to bootstrap the fastload code. It contains enough code to
; handle receiving and decoding a 256 byte block of data
; over the CLOCK and DATA lines of the serial port, then 
; pass control to the received block.
;-----------------------------------------------------------

_1541_fastload_bootstrap:

        .incbin "hello_1541_bootstrap.prg"

;-----------------------------------------------------------
;                read_page_from_serial_bus
;
; This will read 256 bytes of data from the serial bus
; using the fast load protocol. The folowing values must be
; set prior to calling to ensure proper synchronization with
; the VIC chip to avoid bad scan lines:
;
;   lower bits of VIC control 1 => $FC
;   ???? => $FD (some manipulatio of the value in $FC)
;   lower bits of CIA2_PRA | 0x20 => $FE
;
; Each byte of data is sent as a sequence of four values of
; the CLOCK and DATA lines on the serial bus. Since the
; CLOCK line will not be used for synchronization, the
; routine depends on the speed of the CPUs in both the C64
; and the 1541, and the number of clock cycles that need
; to elapse between each sample. The devices will
; resynchronize after every byte to ensure they do not
; drift out of sync.
;
; The eight bits in a byte are encoded as the following
; values on the line for each of the four samples:
;
;     SAMPLE  CLOCK    DATA
;       1       6       7
;       2       4       5
;       3       2       3
;       4       0       1
;
; Note this is different than how the 1541 receives data as
; the data is encoded on each end in a manner that can be
; decoded on the other end the fastest based on available
; hardware. Each device has a lookup table to aid in
; encoding data for transmission.
;-----------------------------------------------------------

read_page_from_serial_bus:  ldy     #$00                    ; Read 256 bytes from the serial port into buffer

@loop_read:  
        lda     $FE                     ; Set all serial CLOCK and DATA lines low (VIC bank at $4000)
        sta     CIA2_PRA

@loop:  bit     CIA2_PRA                ; wait for signal
        bvs     @loop

@wait_for_scan_line:
        sec                             ; Wait until the VIC will not hit a 'bad' scan line while reading
        lda     VIC_HLINE
        sbc     $FB
        bcc     @scan_line_reached
        and     #$07
        beq     @wait_for_scan_line

@scan_line_reached:
        lda     $FC                     ; Send signal that we are ready to receive
        sta     CIA2_PRA

        nop                             ; Delay to give 1541 time to start sending
        nop
        nop
        nop
        nop

        lda     $FD                     ; Read high four bits
        eor     CIA2_PRA
        rol
        rol
        nop
        eor     CIA2_PRA
        rol
        rol

        nop
        nop
        nop
        nop

        eor     CIA2_PRA                ; Read lower four bits
        rol
        rol
        nop
        eor     CIA2_PRA
        rol
        rol
        rol

        sta     fast_serial_buffer,y    ; Store in buffer
        iny
        bne     @loop_read              ; Have we read 256 bytes yet?
        rts



;-----------------------------------------------------------
;                    _1541_fastload_code
;
; The following section will be copied out to the 1541
; drive, and contains the fastload code that will be
; executed on the 1541.
;-----------------------------------------------------------

_1541_fastload_code:

        .incbin "hello_1541_fastload.prg"



;-----------------------------------------------------------
; The following filename buffer is shared between the C64
; and the 1541. It gets copied to the 1541 along with the
; fastload code above when we load a file using the
; 1541 fastload driver.
;-----------------------------------------------------------

filename_buffer:
        .byte   $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
        .byte   $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
        .byte   $00,$00




load_file_cached:
        jmp     load_file_cached_a
save_file:
        jmp     save_file_a
load_file:
        jmp     load_file_a
        ldx     LC4F8
        inx
        inx




;-----------------------------------------------------------
;                         save_file
;
; Saves one of the game files. The file to save is selected
; by the value in the x register, which may be one of the
; following:
;
;   0 : DD @ $B000-$B001 - disk driver selection
;   1 : RO @ $B000-$B040 - ???
;   2 : P0 @ $81E2-$83AC - Player save slot 1
;   3 : P1 @ $81E2-$83AC - Player save slot 2
;   4 : P2 @ $81E2-$83AC - Player save slot 3
;   5 : P3 @ $81E2-$83AC - Player save slot 4
;
; The memory range saved for each file is listed above.
;-----------------------------------------------------------

save_file_a:
        txa                             ; x = x * 2
        asl
        tax

        lda     write_filenames,x       ; Load the two character filename into memory at $C595
        sta     filename                ; $C593 already holds the characters 'S:', so the result
        lda     write_filenames + 1,x   ; will be a DOS command to delete the file at $C593
        sta     filename + 1

        lda     write_start_addresses,x  ; Get start address of data to save
        sta     file_start_address
        lda     write_start_addresses + 1,x
        sta     file_start_address + 1

        lda     write_end_addresses,x    ; Get end address of data to save (+1)
        sta     file_end_address
        lda     write_end_addresses + 1,x
        sta     file_end_address + 1

        ;-----------------------------------------------------------
        ; Delete the requested file
        ;-----------------------------------------------------------

        lda     #$04                    ; Set filename to four characters at $C593
        ldx     #$93
        ldy     #$C5
        jsr     KERNEL_SETNAM

        lda     #$0F                    ; open 15,8,5,"S:xx"
        tay
        ldx     #$08
        jsr     KERNEL_SETLFS
        jsr     KERNEL_OPEN
        lda     #$0F
        jsr     KERNEL_CLOSE

        ;-----------------------------------------------------------
        ; Save the requested file
        ;-----------------------------------------------------------

        lda     #$02                    ; Save file
        ldx     #$08
        ldy     #$FF
        jsr     KERNEL_SETLFS
        lda     #$02
        ldx     #$95
        ldy     #$C5
        jsr     KERNEL_SETNAM
        lda     file_start_address
        sta     $60
        lda     file_start_address + 1
        sta     $61
        lda     #$60
        ldx     file_end_address
        ldy     file_end_address + 1
        jsr     KERNEL_SAVE
        jmp     LC564
LC4F8:  brk




;-----------------------------------------------------------
;                     load_file_cached
; 
; Functions identically to load_file below, except if the
; index of the file to read is $05 ("OU"), then the file
; will be loaded from RAM instead of from disk.
;
; This is probably to allow the 'OU' file to be cached under
; KERNEL ROM to allow it to be reloaded quickly on demand.
;-----------------------------------------------------------

load_file_cached_a:
        cpx     #$05
        bne     load_file_a

        lda     PROCESSOR_PORT          ; Disable KERNEL ROM
        and     #$FD
        sta     PROCESSOR_PORT

        lda     #$00                    ; Copy 30 * 256 bytes from $E000-F800 to $8C9E
        tay
        sta     $60
        lda     #$E0
        sta     $61
        lda     #$9E
        sta     $62
        lda     #$8C
        sta     $63
        ldx     #$18
@loop:  lda     ($60),y
        sta     ($62),y
        iny
        bne     @loop
        inc     $61
        inc     $63
        dex
        bne     @loop

        lda     PROCESSOR_PORT          ; Enable KERNEL ROM
        ora     #$02
        sta     PROCESSOR_PORT

        clc
        rts




;-----------------------------------------------------------
;                       load_file_a
;
; Saves one of the game files. The file to save is selected
; by the value in the x register, which may be one of the
; following:
;
;   00 : TC @ $4000 - ???
;   01 : MA @ $C700 - ???
;   02 : PL @ $6400 - ???
;   03 : FI @ $6420 - ???
;   04 : GE @ $8C9E - ???
;   05 : OU @ $E000 - ???
;   06 : DN @ $8C9E - ???
;   07 : TW @ $8C9E - ???
;   08 : CA @ $8C9E - ???
;   09 : SP @ $8C9E - ???
;   0a : TM @ $8C9E - ???
;   0b : ST @ $0C00 - ???
;   0c : IN @ $6800 - ???
;   0d : MI @ $7400 - ???
;   0e : LO @ $0800 - ???
;   0f : PR @ $12C0 - ???
;   10 : DD @ $B000 - disk driver selection
;   11 : RO @ $B000 - ???
;   12 : P0 @ $81E2 - Player save slot 1
;   13 : P1 @ $81E2 - Player save slot 2
;   14 : P2 @ $81E2 - Player save slot 3
;   15 : P3 @ $81E2 - Player save slot 4
;
; The file will be loaded into the memory location listed
; for the file above.
;
; The processor carry flag will be set if the status after
; reading the file is not $30, which indicates the write
; was successful.
;-----------------------------------------------------------

load_file_a:
        txa                             ; x = x * 2
        asl     a
        tax

        lda     read_filenames,x        ; Get the filename and start address
        sta     filename
        lda     read_filenames + 1,x
        sta     filename + 1
        lda     read_start_addresses,x
        sta     file_start_address
        lda     read_start_addresses + 1,x
        sta     file_start_address + 1

        lda     #$02                    ; open the file and load it
        ldx     #$08
        ldy     #$00
        jsr     KERNEL_SETLFS
        lda     #$02
        ldx     #$95
        ldy     #$C5
        jsr     KERNEL_SETNAM
        lda     #$00
        ldx     file_start_address
        ldy     file_start_address + 1
        jsr     KERNEL_LOAD

LC564:  lda     #$00                    ; Clear out file name
        jsr     KERNEL_SETNAM
        lda     #$0F                    ; open 15,8,15
        tay
        ldx     #$08
        jsr     KERNEL_SETLFS
        jsr     KERNEL_OPEN
        ldx     #$0F                    ; Read status from channel 15
        jsr     KERNEL_CHKIN
        jsr     KERNEL_CHRIN
        pha

        lda     #$0F                    ; Close the channel and restore default I/O channels
        jsr     KERNEL_CLOSE
        jsr     KERNEL_CLRCHN

        pla
        cmp     #$30
        beq     LC58C
        sec
        rts




LC58C:  clc
        rts
        rts

.segment "HELLO_DATA5"

file_start_address:
        .addr   $0000
file_end_address:
        .addr   $0000

        .byte   "S:"
filename:  
        .byte   "GM"




read_filenames:  
        .byte   "TC"
        .byte   "MA"
        .byte   "PL"
        .byte   "FI"

        .byte   "GE"
        .byte   "OU"
        .byte   "DN"
        .byte   "TW"

        .byte   "CA"
        .byte   "SP"
        .byte   "TM"
        .byte   "ST"

        .byte   "IN"
        .byte   "MI"
        .byte   "LO"
        .byte   "PR"




write_filenames:
        .byte   "DD"
        .byte   "RO"
        .byte   "P0"
        .byte   "P1"
        .byte   "P2"
        .byte   "P3"




read_start_addresses:
        .addr   $4000
        .addr   $C700
        .addr   $6400
        .addr   $6420

        .addr   $8C9E
        .addr   $E000
        .addr   $8C9E
        .addr   $8C9E

        .addr   $8C9E
        .addr   $8C9E
        .addr   $8C9E
        .addr   $0C00

        .addr   $6800
        .addr   $7400
        .addr   $0800
        .addr   $12C0




write_start_addresses:
        .addr   $B000
        .addr   $B000
        .addr   $81E2
        .addr   $81E2
        .addr   $81E2
        .addr   $81E2
write_end_addresses:
        .addr   $B001
        .addr   $B040
        .addr   $83AC
        .addr   $83AC
        .addr   $83AC
        .addr   $83AC




        .byte   $00
