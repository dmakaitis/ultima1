;-------------------------------------------------------------------------------
;
; hello.s
;
; This program initializes the system, displays the title page, and optionally
; prompts the user for which floppy driver to use (probably to implement some
; kind of fast loader for the 1541).
;
;-------------------------------------------------------------------------------

.include "c64.inc"

        .setcpu "6502"

L0C00           := $0C00

hi_routine_1    := $C480
hi_routine_2    := $C483

selected_drive_type:= $B000

KERNEL_SCNKEY   := $FF9F
KERNEL_SETLFS   := $FFBA
KERNEL_SETNAM   := $FFBD
KERNEL_OPEN     := $FFC0
KERNEL_CLOSE    := $FFC3
KERNEL_GETIN    := $FFE4

;-------------------------------------------------------------------------------
;
; The load address for this file is always set to $2000, but is ignored. The
; actual location where this code should be loaded into memory is $8000.
;
;-------------------------------------------------------------------------------

.segment "LOADADDR"

    .addr   $2000

.code

;-----------------------------------------------------------
;                           main
;
; Entry point for Ultima 1. Initializes the system, then
; loads the next part of game code.
;-----------------------------------------------------------

main:   sei
        lda     #$36                    ; Enable all the RAM in the C-64
        sta     $01

        lda     #$7f                    ; Enable all interrupts on the CIA chips
        sta     CIA1_ICR
        sta     CIA2_ICR
        lda     CIA1_ICR
        lda     CIA2_ICR

        lda     #$18
        sta     $1FFE
        lda     #$60
        sta     $1FFF
        lda     #$FE
        sta     $0326
        lda     #$1F
        sta     $0327

        lda     NMIVec + 1              ; See if the NMI vector is already set to $CE00
        cmp     #$CE
        beq     @init_text_display
        lda     #$00                    ; If not, set it now
        sta     NMIVec
        lda     #$CE
        sta     NMIVec + 1

        lda     #$40
        sta     $CE00

@init_text_display:
        lda     #$00                    ; Set the border and background color to black
        sta     VIC_BORDERCOLOR
        sta     VIC_BG_COLOR0
        jsr     clear_screen

        ldx     #$00                    ; Initialize color memory
@loop_init_color:
        lda     #$01
        sta     $D800,x
        sta     $D900,x
        sta     $DA00,x
        sta     $DB00,x
        inx
        bne     @loop_init_color

        lda     #$1E                    ; Display the title page
        sta     L8361
        lda     #$81
        sta     L8362
        lda     #$18
        sta     $FE
        lda     #$05
        sta     $FF
        jsr     display_text_page

        lda     #$17                    ; Set screen memory at $4000 and character/bitmap memory at $2000
        sta     VIC_VIDEO_ADR
        lda     #$08                    ; Enable multi-color mode 
        sta     VIC_CTRL2
        lda     #$17                    ; Turn screen on - 25 rows
        sta     VIC_CTRL1

        lda     #$00                    ; Copy our "high memory" code from $8400 to $C000
        tay
        sta     $FE
        sta     $FC
        lda     #$84
        sta     $FF
        lda     #$C0
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

        ldx     #$10
        jsr     hi_routine_1

        lda     #$83                    ; Reset BASIC idle vector to default value ($A483)
        sta     $0302
        lda     #$A4
        sta     $0303

        lda     #$48                    ; Reset shift key handler vector to default ($EB48)
        sta     $028F
        lda     #$EB
        sta     $0290

        lda     #$A5                    ; Reset load vector to default value ($F4A5)
        sta     $0330
        lda     #$F4
        sta     $0331

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
        lda     #$42
        sta     $0330
        lda     #$C0
        sta     $0331
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

        ldx     #$0E
        jsr     hi_routine_1
        ldx     #$00
        jsr     hi_routine_2

        jmp     L0C00




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
        sta     L8361
        lda     #$81
        sta     L8362
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
; $FFFE must hold the address of the first line of screen
; memory where the text should be output.
;-----------------------------------------------------------

display_text_page:
        ldy     #$00                    ; y stores the column we're currently writing to
L8361           := * + 1
L8362           := * + 2
@loop_display_text:
        lda     title_page              ; Read the next code from the source data
        beq     @display_text_page_end  ; If the code is zero, then we're done

        bpl     @mask_character          ; If the code does not have bit seven set, then skip below to print it

        cmp     #$FF                    ; If the code is $FF, then advance to the next line
        beq     @advance_next_line

        and     #$7F                    ; Strip bit 7 from the code. The result is which column to advance to
        tay
        bne     @inc_src_ptr            ; If we're advancing to column 0, then treat it as a new line character

@advance_next_line:
        ldy     #$00                    ; Reset the column back to zero

        lda     $FE                     ; Add 40 to the current screen memory location stored at $FFFE
        clc
        adc     #$28
        sta     $FE
        lda     $FF
        adc     #$00
        sta     $FF
        bne     @inc_src_ptr            ; Assuming we don't wrap around to write to $0000, advance to the next code...

@mask_character:
        cmp     #$60                    ; Any code greater than $60 needs to have the first three bits stripped off
        bcc     @print_character        ; to determine the output character (this effectively ensures that everything
        and     #$1F                    ; ends up as 'lower' case)

@print_character:
        sta     ($FE),y
        iny

@inc_src_ptr:
        inc     L8361
        bne     @loop_display_text
        inc     L8362
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




unknown_hi_mem_data:
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
