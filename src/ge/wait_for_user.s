;-------------------------------------------------------------------------------
;
; wait_for_user.s
;
; Prints a message asking the user to press space, then waits for the user to
; press a key before clearing the bottom portion of the screen.
;
;-------------------------------------------------------------------------------

.include "mi.inc"
.include "st.inc"

.import cursor_to_1_1

.export clear_text_area_below_cursor
.export wait_for_user

character_roster    := $B000

        .setcpu "6502"

.segment "CODE_WAIT"

;-----------------------------------------------------------
;                      wait_for_user
;
; Prints a message asking the user to press space, then
; waits for the user to press a key before clearing the
; bottom portion of the screen.
;-----------------------------------------------------------

wait_for_user:
        ldx     #$02
        ldy     #$15
        jsr     mi_print_text_at_x_y

        .byte   "Press Space to continue: ",$00

        jsr     st_read_input
        jsr     mi_cursor_to_col_1

        lda     #$14
        sta     CUR_Y
        bne     clear_text_area_below_cursor

        jsr     st_set_text_window_full
        jsr     cursor_to_1_1

        ; continued in clear_text_area_below_cursor



;-----------------------------------------------------------
;                clear_text_area_below_cursor
;
; Clears the screen starting from the cursor position to
; the bottom of the screen.
;-----------------------------------------------------------

clear_text_area_below_cursor:
        jsr     mi_store_text_area

        dec     CUR_X_MAX

@loop:  jsr     st_clear_to_end_of_text_row_a

        jsr     mi_cursor_to_col_1
        inc     CUR_Y

        ldy     CUR_Y
        iny
        cpy     CUR_Y_MAX
        bcc     @loop

        jmp     mi_restore_text_area
