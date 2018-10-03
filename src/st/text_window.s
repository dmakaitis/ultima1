;-------------------------------------------------------------------------------
;
; text_window.s
;
; 
;
;-------------------------------------------------------------------------------

.include "stlib.inc"

.export set_text_window_command
.export set_text_window_full
.export set_text_window_main
.export set_text_window_stats

        .setcpu "6502"

.segment "CODE_WINDOW"

;-----------------------------------------------------------
;                  set_text_window_command
;
; Sets the text window to an area 29 characters wide by 4
; characters high starting at (0, 20) on the text display.
;-----------------------------------------------------------

set_text_window_command:
        lda     #$1E
        sta     CUR_X_MAX
        lda     #$00
        beq     set_window_x_pos



;-----------------------------------------------------------
;                  set_text_window_stats
;
; Sets the text window to an area 9 characters wide by 4
; characters high starting at (31, 20) on the text display.
;-----------------------------------------------------------

set_text_window_stats:
        lda     #$0A
        sta     CUR_X_MAX
        lda     #$1F

set_window_x_pos:
        sta     CUR_X_OFF
        lda     #$18
        sta     CUR_Y_MAX
        lda     #$14

set_window_y_pos:
        sta     CUR_Y_MIN
        sta     CUR_Y
        lda     #$00
        sta     CUR_X
        rts



;-----------------------------------------------------------
;                  set_text_window_full
;
; Sets the text window to an area 40 characters wide by 24
; characters high starting at (0, 0) on the text display.
;-----------------------------------------------------------

set_text_window_full:
        lda     #$28
        sta     CUR_X_MAX
        lda     #$18
        sta     CUR_Y_MAX
        lda     #$00
        sta     CUR_X_OFF
        beq     set_window_y_pos



;-----------------------------------------------------------
;                  set_text_window_main
;
; Sets the text window to an area 38 characters wide by 18
; characters high starting at (1, 1) on the text display.
;-----------------------------------------------------------

set_text_window_main:
        lda     #$26
        sta     CUR_X_MAX
        lda     #$13
        sta     CUR_Y_MAX
        lda     #$01
        sta     CUR_X_OFF
        bne     set_window_y_pos




