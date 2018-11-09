;-------------------------------------------------------------------------------
;
; cursor_back.s
;
; Moves the cusor back to immediately after the last non-space character on the
; current row.
;
;-------------------------------------------------------------------------------

.export move_cursor_back_to_last_character

.include "st.inc"

BITMAP_PTR      := $36

        .setcpu "6502"

.segment "CODE_BACK"

;-----------------------------------------------------------
;           move_cursor_back_to_last_character
;
; Moves the cusor back to immediately after the last
; non-space character on the current row, or the beginning
; of the row if there are no non-space characters before
; the current cursor position on the row.
;-----------------------------------------------------------

move_cursor_back_to_last_character:
        lda     CUR_Y                                   ; x := 8 * cursor Y coordinate
        asl     a
        asl     a
        asl     a
        tax

@loop_left:
        ldy     CUR_X                                   ; y := cursor X coordinate

        beq     @done                                   ; if y != 0 then we are done.

        dey                                             ; y -= 1

        lda     st_bitmap_y_offset_lo,x                 ; Get bitmap memory address of (CUR_X - 1, CUR_Y)
        clc
        adc     st_bitmap_x_offset_lo,y
        sta     BITMAP_PTR
        lda     st_bitmap_y_offset_hi,x
        eor     BM_ADDR_MASK
        adc     st_bitmap_x_offset_hi,y
        sta     BITMAP_PTR + 1

        ldy     #$07                                    ; See if any pixels are currently on at CUR_X, CUR_Y
        lda     #$00

@loop_character:
        ora     (BITMAP_PTR),y
        bne     @done                                   ; If something is there, then we are done

        dey
        bpl     @loop_character

        dec     CUR_X                                   ; Move cursor left one and...
        bne     @loop_left                              ; ...if we are not at the left edge keep going

@done:  rts
