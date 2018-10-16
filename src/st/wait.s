;-------------------------------------------------------------------------------
;
; wait.s
;
; Waits for the screen raster to reach the bottom of the visible screen. The 
; method will scan for and buffer input while it's waiting.
;
;-------------------------------------------------------------------------------

.include "c64.inc"

.export wait_for_raster

.import scan_and_buffer_input

        .setcpu "6502"

.segment "CODE_WAIT"

;-----------------------------------------------------------
;                     wait_for_raster
;
; Waits for the screen raster to reach the bottom of the
; visible screen. The method will scan for and buffer input
; while it's waiting.
;-----------------------------------------------------------

wait_for_raster:
        jsr     scan_and_buffer_input
        lda     VIC_CTRL1
        bpl     wait_for_raster
        rts
