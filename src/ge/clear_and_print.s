;-------------------------------------------------------------------------------
;
; clear_and_print_text_at_2_20.s
;
; Clears the bottom five lines of the text screen, then prints the message
; located immediately after the call to this routine at location (2, 20).
;
;-------------------------------------------------------------------------------

.include "st.inc"
.include "milib.inc"

.export clear_and_print_text_at_2_20

.import clear_text_area_below_cursor

        .setcpu "6502"

.segment "CODE_CLEAR"

;-----------------------------------------------------------
;                clear_and_print_text_at_2_20
;
; Clears the bottom five lines of the text screen, then
; prints the message located immediately after the call to
; this routine at location (2, 20).
;-----------------------------------------------------------

clear_and_print_text_at_2_20:
        ldx     #$02
        stx     CUR_X
        ldy     #$14
        sty     CUR_Y
        jsr     clear_text_area_below_cursor
        jmp     mi_print_text
