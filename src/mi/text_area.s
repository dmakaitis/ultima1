;-------------------------------------------------------------------------------
;
; text_area.s
;
; Routines for storing and restoring the text window bounderies.
;
;-------------------------------------------------------------------------------

.include "st.inc"

.export mi_restore_text_area
.export mi_store_text_area

        .setcpu "6502"

.segment "CODE_TEXT_AREA"

;-----------------------------------------------------------
;                    mi_restore_text_area
;
; Set the text area bounderies to whatever values were last
; stored by calling mi_store_text_area.
;-----------------------------------------------------------

mi_restore_text_area:
        ldx     #$05

@loop:  lda     text_area_cache,x
        sta     CUR_X_OFF,x
        dex
        bpl     @loop
        
        rts



;-----------------------------------------------------------
;                    mi_store_text_area
;
; Store the bounderies of the current text area.
;-----------------------------------------------------------

mi_store_text_area:
        ldx     #$05

@loop:  lda     CUR_X_OFF,x
        sta     text_area_cache,x
        dex
        bpl     @loop

        rts



.segment "DATA_TEXT_AREA"

text_area_cache:
        .byte   $00,$28,$00,$18,$00,$00
