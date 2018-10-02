;-------------------------------------------------------------------------------
;
; nothing4.s
;
; This method does nothing. It is probably a placeholder for another method
; that was eliminated from the library.
;
;-------------------------------------------------------------------------------

.export do_nothing4

        .setcpu "6502"

.segment "CODE_NOTHING4"

;-----------------------------------------------------------
;                        do_nothing4
;
; This method does nothing.
;-----------------------------------------------------------

do_nothing4:
        rts
