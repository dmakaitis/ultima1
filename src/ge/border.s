;-------------------------------------------------------------------------------
;
; border.s
;
; Prints the border around the main menu screen.
;
;-------------------------------------------------------------------------------

.include "milib.inc"
.include "stlib.inc"

.export cursor_to_1_1
.export draw_border

        .setcpu "6502"

.segment "CODE_BORDER"

;-----------------------------------------------------------
;                       draw_border
;
; Draws a border around the full screen text display.
;-----------------------------------------------------------

draw_border:
        lda     #$10                                    ; Draw the top-left corner
        jsr     mi_print_char

        ldx     #$26                                    ; Draw the top border
        lda     #$04
        jsr     mi_print_x_chars

        lda     #$12                                    ; Drop the top-right corner
        jsr     st_print_char

@loop:  inc     CUR_Y                                   ; Move the cursor to the next row
        jsr     mi_cursor_to_col_0

        lda     #$0A                                    ; Draw the left border
        jsr     st_print_char

        lda     #$27                                    ; Move the cursor to the right side and draw the right border
        sta     CUR_X
        lda     #$08
        jsr     st_print_char

        jsr     st_scan_and_buffer_input                ; Buffer any keypresses the user might have made

        lda     CUR_Y                                   ; Loop until we've reached row 22
        eor     #$16
        bne     @loop

        sta     CUR_X                                   ; Move the cursor to the left edge of the next row
        inc     CUR_Y

        lda     #$14                                    ; Draw the bottom-left corner
        jsr     mi_print_char

        ldx     #$26                                    ; Draw the bottom border
        lda     #$02
        jsr     mi_print_x_chars

        lda     #$16                                    ; Draw the bottom-right corner
        jsr     st_print_char

        ; continued below



;-----------------------------------------------------------
;                      cursor_to_1_1
;
; Moves the cursor to the top-left corner of the text
; display.
;-----------------------------------------------------------

cursor_to_1_1:
        ldx     #$01                                    ; Move the cursor to (1, 1)
        stx     CUR_X
        stx     CUR_Y
        
        rts
