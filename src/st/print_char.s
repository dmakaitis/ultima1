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

TMP_5E          := $5E

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
; 
;-----------------------------------------------------------

print_char:
        pha
        stx     temp_x
        ldx     CUR_X
        cpx     CUR_X_MAX
        bcs     b1B00
        and     #$7F
        sta     TMP_5E
        lda     CUR_Y
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
        sta     bitmap_addr_lo
        sta     bitmap2_addr_lo
        lda     bitmap_y_offset_hi,x
        adc     bitmap_x_offset_hi,y
        eor     BM_ADDR_MASK
        sta     bitmap_addr_hi
        eor     BM2_ADDR_MASK
        sta     bitmap2_addr_hi
        lda     TMP_5E
        asl     a
        asl     a
        asl     a
        sta     font_addr_lo
        lda     TMP_5E
        lsr     a
        lsr     a
        lsr     a
        lsr     a
        lsr     a
        clc
        adc     #$08
        sta     font_addr_hi
        ldx     #$07
b1AC6:
font_addr_lo    := * + 1
font_addr_hi    := * + 2
        lda     font,x
        eor     CHAR_REV
bitmap_addr_lo  := * + 1
bitmap_addr_hi  := * + 2
        sta     BITMAP_MEM,x
bitmap2_addr_lo := * + 1
bitmap2_addr_hi := * + 2
        sta     BITMAP_MEM2,x
        dex
        bpl     b1AC6
        ldx     CUR_Y
        lda     scrmem_y_offset_lo,x
        sta     TMP_PTR_LO
        sta     TMP_PTR2_LO
        lda     scrmem_y_offset_hi,x
        ldx     BM_ADDR_MASK
        beq     b1AE7
        clc
        adc     #$5C
b1AE7:  sta     TMP_PTR_HI
        ldx     BM2_ADDR_MASK
        beq     b1AEF
        eor     #$64
b1AEF:  sta     TMP_PTR2_HI
        lda     CUR_X
        clc
        adc     CUR_X_OFF
        tay
        ldx     TMP_5E
        lda     char_colors,x
        sta     (TMP_PTR_LO),y
        sta     (TMP_PTR2_LO),y
b1B00:  ldx     temp_x
        pla
        rts

temp_x: .byte   $00