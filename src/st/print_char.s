;-------------------------------------------------------------------------------
;
; s1652.s
;
; 
;
;-------------------------------------------------------------------------------

.include "global.inc"
.include "stlib.inc"

.import bitmap_x_offset_hi
.import bitmap_x_offset_lo
.import bitmap_y_offset_hi
.import bitmap_y_offset_lo

.import scrmem_y_offset_hi
.import scrmem_y_offset_lo

.import char_colors

.export print_char

CHAR_REV        := $1F

CHAR_TO_PRINT   := $5E

TMP_PTR_LO      := $60
TMP_PTR_HI      := $61
TMP_PTR2_LO     := $62
TMP_PTR2_HI     := $63

BITMAP_MEM      := $2000
BITMAP_MEM2     := $4000

        .setcpu "6502"

.segment "CODE_PRINT_CHAR"

;-----------------------------------------------------------
;                        print_char
;
; Prints a character to the screen at the current cursor
; location. When calling the method, the accumulator should
; contain the code of the character that should be printed.
;-----------------------------------------------------------

print_char:
        pha
        stx     temp_x

        ldx     CUR_X                           ; If the cursor is already past the edge of the window, then do nothing
        cpx     CUR_X_MAX
        bcs     @done

        and     #$7F                            ; Make sure the character code is in range and store it for future reference
        sta     CHAR_TO_PRINT

        lda     CUR_Y                           ; Calculate the bitmap addresses to write the character (for both screens)
        asl     a
        asl     a
        asl     a
        tax

        lda     CUR_X_OFF
        clc
        adc     CUR_X
        tay

        lda     bitmap_y_offset_lo,x
        clc
        adc     bitmap_x_offset_lo,y
        sta     @bitmap_addr
        sta     @bitmap2_addr

        lda     bitmap_y_offset_hi,x
        adc     bitmap_x_offset_hi,y
        eor     BM_ADDR_MASK
        sta     @bitmap_addr + 1
        eor     BM2_ADDR_MASK
        sta     @bitmap2_addr + 1

        lda     CHAR_TO_PRINT                   ; Calculate the address in font memory that contains the character
        asl     a
        asl     a
        asl     a
        sta     @font_addr

        lda     CHAR_TO_PRINT
        lsr     a
        lsr     a
        lsr     a
        lsr     a
        lsr     a
        clc
        adc     #$08
        sta     @font_addr + 1

        ldx     #$07                            ; Copy the 8 bytes for the character to bitmap memory
@loop:
@font_addr      := * + 1
        lda     font,x
        eor     CHAR_REV
@bitmap_addr    := * + 1
        sta     BITMAP_MEM,x
@bitmap2_addr   := * + 1
        sta     BITMAP_MEM2,x
        dex
        bpl     @loop

        ldx     CUR_Y                           ; Calculate the location for the character in screen memory (for both screens)
        lda     scrmem_y_offset_lo,x
        sta     TMP_PTR_LO
        sta     TMP_PTR2_LO

        lda     scrmem_y_offset_hi,x
        ldx     BM_ADDR_MASK
        beq     @set_scrmem_hi
        clc
        adc     #$5C
@set_scrmem_hi:
        sta     TMP_PTR_HI

        ldx     BM2_ADDR_MASK
        beq     @set_scrmem2_hi
        eor     #$64
@set_scrmem2_hi:
        sta     TMP_PTR2_HI

        lda     CUR_X
        clc
        adc     CUR_X_OFF
        tay

        ldx     CHAR_TO_PRINT                   ; Load the proper color for the character
        lda     char_colors,x

        sta     (TMP_PTR_LO),y                  ; Set the color for the character in screen memory (both)
        sta     (TMP_PTR2_LO),y

@done:  ldx     temp_x                          ; Restore the accumulator and X register
        pla
        rts



temp_x: .byte   $00