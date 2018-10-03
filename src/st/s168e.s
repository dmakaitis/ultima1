;-------------------------------------------------------------------------------
;
; s168e.s
;
; 
;
;-------------------------------------------------------------------------------

.include "c64.inc"
.include "stlib.inc"

.export do_s168E

.import bitmap_x_offset_hi
.import bitmap_x_offset_lo
.import bitmap_y_offset_hi
.import bitmap_y_offset_lo

.import scrmem_y_offset_hi
.import scrmem_y_offset_lo

.import w1786
.import w1788

zp26            := $26
zp27            := $27

TMP_5E          := $5E
TMP_PTR_LO      := $60
TMP_PTR_HI      := $61
TMP_PTR2_LO     := $62
TMP_PTR2_HI     := $63

TMP_PTR4_LO     := $34
TMP_PTR4_HI     := $35

r1380           := $1380

        .setcpu "6502"

.segment "CODE_S168E"

;-----------------------------------------------------------
;                         do_s168E
;
; 
;-----------------------------------------------------------

do_s168E:
        ldy     zp27
        bmi     b1864
        ldx     zp26
        lda     bitmap_y_offset_hi + $10,y
        eor     BM_ADDR_MASK
        sta     TMP_PTR2_HI
        lda     bitmap_y_offset_lo + $10,y
        sta     TMP_PTR2_LO
s17FF:  sty     TMP_5E
        tya
        lsr     a
        lsr     a
        lsr     a
        tay
        lda     scrmem_y_offset_lo + $02,y
        sta     TMP_PTR_LO
        lda     scrmem_y_offset_hi + $02,y
        ldy     BM_ADDR_MASK
        beq     b1815
        clc
        adc     #$5C
b1815:  sta     TMP_PTR_HI
        txa
        lsr     a
        lsr     a
        lsr     a
        clc
        adc     #$04
        tay
        sta     y_cache2
        lda     w1788
        sta     (TMP_PTR_LO),y
        lda     TMP_PTR2_LO
        clc
        adc     bitmap_x_offset_lo,y
        sta     TMP_PTR4_LO
        lda     TMP_PTR2_HI
        adc     bitmap_x_offset_hi,y
        sta     TMP_PTR4_HI
        ldy     #$00
        lda     w1786
        eor     (TMP_PTR4_LO),y
        and     r1380,x
        eor     (TMP_PTR4_LO),y
        sta     (TMP_PTR4_LO),y
        inx
        beq     b1862
        txa
        and     #$07
        bne     b1862
        ldy     #$08
        lda     w1786
        eor     (TMP_PTR4_LO),y
        and     #$80
        eor     (TMP_PTR4_LO),y
        sta     (TMP_PTR4_LO),y
        ldy     y_cache2
        iny
        lda     w1788
        sta     (TMP_PTR_LO),y
b1862:  ldy     TMP_5E
b1864:  rts

y_cache2:
        .byte   $00
