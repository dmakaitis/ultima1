;-------------------------------------------------------------------------------
;
; border.s
;
; Draws the border around the world view.
;
;-------------------------------------------------------------------------------

.include "st.inc"

.export mi_clear_screen_and_draw_border

.export draw_border

.import mi_cursor_to_col_0
.import mi_print_char
.import mi_print_x_chars

        .setcpu "6502"

.segment "CODE_BORDER"

;-----------------------------------------------------------
;              mi_clear_screen_and_draw_border
;
; Clears the screen, then draws the border around the world
; view.
;-----------------------------------------------------------

mi_clear_screen_and_draw_border:
        jsr     st_set_text_window_full
        jsr     st_clear_text_window

        ; continued in draw_border



;-----------------------------------------------------------
;                        draw_border
;
; Draws the border around the world view.
;-----------------------------------------------------------

draw_border:
        jsr     st_set_text_window_full

        lda     #$10                                    ; Draw the top-left corner
        jsr     mi_print_char

        ldx     #$26                                    ; Draw the top border
        lda     #$04
        jsr     mi_print_x_chars

        lda     #$12                                    ; Draw the top-right corner
        jsr     st_print_char

@loop:  inc     CUR_Y                                   ; Advance cursor to the next line
        jsr     mi_cursor_to_col_0

        lda     #$0A                                    ; Draw the left border
        jsr     st_print_char

        lda     #$27                                    ; Advance cursor to the right edge
        sta     CUR_X

        lda     #$08                                    ; Draw the right border
        jsr     st_print_char

        jsr     st_scan_and_buffer_input                ; Buffer any keys the user might be pressing

        lda     CUR_Y                                   ; Keep looping until we have drawn 18 rows
        eor     #$12
        bne     @loop



        sta     CUR_X                                   ; Advance the cursor to the next line
        inc     CUR_Y

        lda     #$04                                    ; Draw the bottom-left corner
        jsr     mi_print_char

        ldx     #$26                                    ; Draw the bottom border
        lda     #$06
        jsr     mi_print_x_chars

        lda     #$04                                    ; Draw the bottom-right corner.
        jsr     st_print_char

        lda     #$1E                                    ; Move the cursor back to column 30
        sta     CUR_X



        lda     #$02                                    ; Draw the divider between the command area and the stats area...
        jsr     st_print_char

        lda     #$0C

@loop_divider:
        inc     CUR_Y                                   ; Move the cursor down one row

        jsr     st_print_char                           ; Draw the divider

        ldx     CUR_Y                                   ; Keep going until we have reached the bottom of the screen
        cpx     #$17
        bcc     @loop_divider

        rts
