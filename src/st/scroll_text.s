;-------------------------------------------------------------------------------
;
; scroll_text.s
;
; 
;
;-------------------------------------------------------------------------------

.include "c64.inc"
.include "stlib.inc"

.export scroll_text_area_up
.export clear_current_text_row
.export clear_to_end_of_text_row_a
.export clear_entire_text_row_a

.import scan_and_buffer_input

.import bitmap_x_offset_hi
.import bitmap_x_offset_lo
.import bitmap_y_offset_hi
.import bitmap_y_offset_lo

CHAR_REV                := $1F

ROWS_TO_COPY            := $43

BYTES_TO_COPY           := $5E
MORE_TO_COPY_IND        := $5F

BITMAP_MEM              := $2000
BITMAP_MEM2             := $4000

SCRN_MEM                := $0400
SCRN_MEM2               := $6000

        .setcpu "6502"

.segment "CODE_SCROLL"

;-----------------------------------------------------------
;                    scroll_text_area_up
;
; Moves all the text in the text area up one line.
;-----------------------------------------------------------

scroll_text_area_up:
        ldx     CUR_Y_MAX                               ; move cursor to last row
        dex
        txa
        sta     CUR_Y

        sec                                             ; ROWS_TO_COPY := number of rows to move
        sbc     CUR_Y_MIN
        sta     ROWS_TO_COPY

        lda     CUR_Y_MIN                               ; x := y bitmap coordinate of top of first text row
        asl     a
        asl     a
        asl     a
        tax

        lda     #$60                                    ; Set color of first column of every row to blue
        sta     SCRN_MEM + $0320
        sta     SCRN_MEM + $0348
        sta     SCRN_MEM + $0370
        sta     SCRN_MEM2 + $0320
        sta     SCRN_MEM2 + $0348
        sta     SCRN_MEM2 + $0370

@row_loop:
        lda     bitmap_y_offset_lo,x                    ; Get bitmap address for first text column of the current row of pixels
        ldy     CUR_X_OFF
        clc
        adc     bitmap_x_offset_lo,y
        sta     @bitmap_dest
        sta     @bitmap2_dest

        lda     bitmap_y_offset_hi,x
        adc     bitmap_x_offset_hi,y
        sta     @bitmap_dest + 1
        eor     BM2_ADDR_MASK
        sta     @bitmap2_dest + 1

        lda     @bitmap_dest                            ; Get bitmap address for first text column of the row of pixels 8 pixels down
        adc     #$40
        sta     @bitmap_src
        lda     @bitmap_dest + 1
        adc     #$01
        sta     @bitmap_src + 1

        lda     #$00                                    ; Determine how many bytes need to be moved
        sta     MORE_TO_COPY_IND                        ; Bytes = 8 * CUR_X_MAX
        lda     CUR_X_MAX
        sec
        sbc     #$01                                    
        asl     a
        asl     a
        asl     a
        rol     MORE_TO_COPY_IND

        ora     #$07
        tay
        sta     BYTES_TO_COPY
        lda     MORE_TO_COPY_IND                        ; if CUR_X_MAX >= 33, then we'll only copy 256 bytes (32 text columns), and get the rest later
        beq     @loop
        ldy     #$FF

@loop:
@bitmap_src     := * + 1
        lda     BITMAP_MEM + $0100,y                    ; copy y sets of pixels from the row below into the current row
@bitmap_dest    := * + 1
        sta     BITMAP_MEM,y
@bitmap2_dest   := * + 1
        sta     BITMAP_MEM2,y
        dey
        cpy     #$FF
        bne     @loop

        ldy     BYTES_TO_COPY                           ; Reset our byte counter
        inc     @bitmap_dest + 1                        ; Update our destination pointers (why not our source? May be a bug, but the command window is less than 30 characters wide anyway...)
        inc     @bitmap2_dest + 1
        dec     MORE_TO_COPY_IND                        ; If we have more bytes for the current row, go back and copy them now
        bpl     @loop                                   ; (we'll probably copy some extra bytes, but we'll fix that later)

        txa                                             ; Advance x to the top of the next bitmap row to scroll to.
        clc
        adc     #$08
        tax

        dec     ROWS_TO_COPY                            ; Do we have more text rows to move?
        bne     @row_loop

        ; continued below



;-----------------------------------------------------------
;                  clear_current_text_row
;
; Moves all the text in the text area up one line.
;-----------------------------------------------------------

clear_current_text_row:
        lda     CUR_Y

        ; continued below



;-----------------------------------------------------------
;                 clear_entire_text_row_a
;
; Clears the entire row of text identified by the row number
; contained in the accumulator.
;-----------------------------------------------------------

clear_entire_text_row_a:
        ldx     #$00
        stx     CUR_X
        beq     do_clear_text_row

        ; continued below (do_clear_text_row)



;-----------------------------------------------------------
;               clear_to_end_of_text_row_a
;
; Clears the text row identified by the row number contained
; in the accumulator from the current cursor X position to
; the end of the row.
;-----------------------------------------------------------

clear_to_end_of_text_row_a:
        ldx     CUR_X                                   ; If the cursor is already at the end of the row, just skip to the end...
        cpx     CUR_X_MAX
        bcs     done_clearing
        lda     CUR_Y

        ; continued below



;-----------------------------------------------------------
;                     do_clear_text_row
;
; Clears a section of the text area. When calling, the 
; accumulator should contain the text row number to clear,
; and the X register should contain the starting column
; number from which to clear to the end of the row.
;-----------------------------------------------------------

do_clear_text_row:
        asl     a                                       ; x := top bitmap coordinate of row to clear
        asl     a
        asl     a
        tax

        lda     CUR_X_OFF                               ; y := (left bitmap coordinate from which to clear) / 8
        clc
        adc     CUR_X
        tay

        lda     bitmap_y_offset_lo,x                    ; Calculate starting bitmap addresses
        clc
        adc     bitmap_x_offset_lo,y
        sta     @bitmap_addr
        sta     @bitmap2_addr
        lda     bitmap_y_offset_hi,x
        adc     bitmap_x_offset_hi,y
        eor     BM_ADDR_MASK
        sta     @bitmap_addr + 1
        eor     BM2_ADDR_MASK
        sta     @bitmap2_addr + 1

        lda     #$00                                    ; Determine how many bytes to copy in the row
        sta     MORE_TO_COPY_IND
        lda     CUR_X_MAX
        sec
        sbc     CUR_X
        sec
        sbc     #$01
        asl     a
        asl     a
        asl     a
        rol     MORE_TO_COPY_IND

        ora     #$07
        tay
        sta     BYTES_TO_COPY
        lda     MORE_TO_COPY_IND
        beq     @ready
        ldy     #$FF

@ready: lda     CHAR_REV                                ; We'll fill the area with the value stored in CHAR_REV (which is normally $00)

@loop:
@bitmap_addr    := * + 1
        sta     BITMAP_MEM,y                            ; Loop through and clear the row
@bitmap2_addr   := * + 1
        sta     BITMAP_MEM2,y
        dey
        cpy     #$FF
        bne     @loop

        ldy     BYTES_TO_COPY                           ; If there's more that needs to be cleared, do so
        inc     @bitmap_addr + 1
        inc     @bitmap2_addr + 1
        dec     MORE_TO_COPY_IND
        bpl     @loop

done_clearing:
        jmp     scan_and_buffer_input                   ; When we're done, see if there's any input that needs to be buffered
