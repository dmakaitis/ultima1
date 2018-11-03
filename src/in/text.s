;-------------------------------------------------------------------------------
;
; text.s
;
; Routines for drawing and erasing text on the intro page.
;
;-------------------------------------------------------------------------------

.include "c64.inc"
.include "kernel.inc"
.include "in.inc"
.include "lo.inc"

.export draw_text
.export erase_text_area

cursor_x        := $32
cursor_y        := $33

        .setcpu "6502"

.segment "CODE_TEXT"

;-----------------------------------------------------------
;                       draw_text
;
; Renders one of three text messages on the display,
; determined by the value in the accumulator when the method
; is called (either 0, 1, or 2).
;-----------------------------------------------------------

draw_text:
        asl                             ; x = a * 2
        tax

        lda     #11                     ; Set initial cursor position to (11, 7) in text coordinates
        sta     cursor_x
        lda     #7
        sta     cursor_y

        lda     @text_pointers,x        ; Load pointer to text to render
        sta     @load_addr
        lda     @text_pointers + 1,x
        sta     @load_addr + 1

@loop:
@load_addr      := * + 1
        lda     @presents_text          ; Get the next character
        bne     @decode_char            ; a $00 means we are finished
        rts

@decode_char:
        bpl     @write_char             ; bit 7 set means newline

        lda     #11                     ; Move cursor back to start of line
        sta     cursor_x
        inc     cursor_y                ; Move cursor down one
        bne     @advance_ptr        

@write_char:
        jsr     draw_character
        inc     cursor_x                ; Move cursor right one

@advance_ptr:
        inc     @load_addr              ; Advance text pointer
        bne     @loop
        inc     @load_addr + 1
        bne     @loop




@text_pointers:
        .addr   @presents_text
        .addr   @new_releast_text
        .addr   @masterpiece_text

@presents_text:
        .byte   $FF
        .byte   $FF
        .byte   $FF
        .byte   "         presents..."
        .byte   $00
@new_releast_text:
        .byte   "...a new release of the best-",$FF
        .byte   "   selling personal computer",$FF
        .byte   "   role-playing adventure..."
        .byte   $00
@masterpiece_text:
        .byte   "...Lord British's original",$FF
        .byte   "   fantasy masterpiece..."
        .byte   $00




;-----------------------------------------------------------
;                       draw_character
;
; Character to draw is in the accumulator. Cursor position 
; is in $32 (x) and $33 (y).
;-----------------------------------------------------------

draw_character:
        sta     temp_value

        lda     cursor_y                ; Convert cursor coordinates to an address in bitmat memory
        asl
        asl
        asl
        tax

        ldy     cursor_x

        lda     bitmap_row_addr_table_low,x
        clc
        adc     bitmap_col_offset_table_low,y
        sta     @write_ptr

        lda     bitmap_row_addr_table_high,x
        adc     bitmap_col_offset_table_high,y
        adc     #$20
        sta     @write_ptr + 1

        lda     temp_value              ; Convert character to render to an address in character memory
        asl     a                       ; starting at $0800
        asl     a
        asl     a
        sta     @read_ptr               ; Bottom five bits of character become LSB of read address

        lda     temp_value
        lsr     a                       ; Top three bits + $08 become MSB of read address
        lsr     a
        lsr     a
        lsr     a
        lsr     a
        clc
        adc     #>lo_font
        sta     @read_ptr + 1

        ldx     #7                      ; Copy the character (8 bytes) to the bitmap
@loop:
@read_ptr       := * + 1
        lda     lo_font,x
@write_ptr      := * + 1
        sta     $2000,x
        dex
        bpl     @loop

        rts




;-----------------------------------------------------------
;                       erase_text_area
;
; Erases (sets to zero) the bitmap screen from (11,6) to 
; (39,12) in text coordinates.
;-----------------------------------------------------------

erase_text_area:
        lda     #6                      ; Lookup address of (11,6)
        asl
        asl
        asl
        tax

        ldy     #11

        lda     bitmap_row_addr_table_low,x
        clc
        adc     bitmap_col_offset_table_low,y
        sta     temp_ptr
        lda     bitmap_row_addr_table_high,x
        adc     bitmap_col_offset_table_high,y
        adc     #$20
        sta     temp_ptr + 1

        ldx     #$07                    ; Do 7 sets of 8 rows

@next_x:
        ldy     #231                    ; Erase area 8 rows high and 232 pixels wide
        lda     #$00

@next_y:
        sta     (temp_ptr),y
        dey
        cpy     #$FF
        bne     @next_y

        lda     temp_ptr                ; Advance down 8 rows ($0140 bytes)
        clc
        adc     #$40
        sta     temp_ptr
        lda     temp_ptr + 1
        adc     #$01
        sta     temp_ptr + 1

        dex
        bne     @next_x

        rts



