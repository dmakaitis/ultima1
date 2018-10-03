;-------------------------------------------------------------------------------
;
; s1652.s
;
; 
;
;-------------------------------------------------------------------------------

.include "stlib.inc"

.import scrmem_y_offset_hi
.import scrmem_y_offset_lo

.import clear_entire_text_row_a

.export do_s1652

TMP_PTR_LO      := $60
TMP_PTR_HI      := $61

        .setcpu "6502"

.segment "CODE_S1652"

;-----------------------------------------------------------
;                        do_s1652
;
; 
;-----------------------------------------------------------

do_s1652:
        ldy     CUR_Y_MIN
        sty     CUR_Y

@loop:  tya
        pha
        lda     scrmem_y_offset_lo,y
        sta     TMP_PTR_LO
        lda     scrmem_y_offset_hi,y
        ldx     BM_ADDR_MASK
        beq     @set_ptr_hi
        clc
        adc     #$5C

@set_ptr_hi:  
        sta     TMP_PTR_HI
        ldx     CUR_X_MAX
        ldy     CUR_X_OFF
        lda     #$10

@loop2: sta     (TMP_PTR_LO),y
        iny
        dex
        bne     @loop2

        pla
        pha
        jsr     clear_entire_text_row_a
        pla
        tay
        iny
        cpy     CUR_Y_MAX
        bcc     @loop
        rts