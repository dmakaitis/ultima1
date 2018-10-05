;-------------------------------------------------------------------------------
;
; clear_text_window.s
;
; Clears the text window, setting the text area to black and initializing
; screen memory to print white over black for the entire text window.
;
;-------------------------------------------------------------------------------

.include "stlib.inc"

.import scrmem_y_offset_hi
.import scrmem_y_offset_lo

.import clear_entire_text_row_a

.export clear_text_window

TMP_PTR_LO      := $60
TMP_PTR_HI      := $61

        .setcpu "6502"

.segment "CODE_S1652"

;-----------------------------------------------------------
;                    clear_text_window
;
; Clears the text window, setting the text area to black and
; initializing screen memory to print white over black for
; the entire text window.
;-----------------------------------------------------------

clear_text_window:
        ldy     CUR_Y_MIN                               ; Set cursor to top of text window
        sty     CUR_Y

@loop:  tya                                             ; Loop through every row in the text area
        pha
        lda     scrmem_y_offset_lo,y                    ; Calculate the pointer to the row in screen memory
        sta     TMP_PTR_LO
        lda     scrmem_y_offset_hi,y
        ldx     BM_ADDR_MASK
        beq     @set_ptr_hi
        clc
        adc     #$5C

@set_ptr_hi:  
        sta     TMP_PTR_HI

        ldx     CUR_X_MAX                               ; Initialize screen memory for every character in the text window for the current row
        ldy     CUR_X_OFF
        lda     #$10

@loop2: sta     (TMP_PTR_LO),y
        iny
        dex
        bne     @loop2
        pla                                             ; Now, clear the bitmap for the current row

        pha
        jsr     clear_entire_text_row_a
        pla

        tay                                             ; Loop until we've done every row in the text window
        iny
        cpy     CUR_Y_MAX
        bcc     @loop

        rts
