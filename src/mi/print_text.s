;-------------------------------------------------------------------------------
;
; print_text.s
;
; Text printing routines.
;
;-------------------------------------------------------------------------------

.include "c64.inc"
.include "st.inc"

.export mi_cursor_to_col_0
.export mi_cursor_to_col_1
.export mi_print_char
.export mi_print_crlf_col_1
.export mi_print_string_entry_x
.export mi_print_string_entry_x2
.export mi_print_text
.export mi_print_text_at_x_y
.export mi_print_x_chars

.export inc_then_read_ptr
.export reduce_text_window_size
.export rts_ptr

.export indent

.export clear_to_end_then_print_lfcr
.export print_digit
.export print_2_digits

.import next_row_or_column
.import print_long_int

.import mi_number_padding
.import mi_selected_item

string_entry    := $46

zpA2            := $A2

        .setcpu "6502"

.segment "CODE_PRINT_TEXT"

;-----------------------------------------------------------
;                       print_2_digits
;
; Prints the two digits stored in the accumulator to the
; screen at the current cursor position, then advances the
; cursor by two. The digit in the high nibble will be
; printed first.
;-----------------------------------------------------------

print_2_digits:
        pha
        lsr     a
        lsr     a
        lsr     a
        lsr     a
        jsr     print_digit
        pla



;-----------------------------------------------------------
;                        print_digit
;
; Prints the digit stored in the accumulator to the screen
; at the current cursor position, then advances the cursor
; by one. The digit must be in the range of 0-F in hex (the
; top 4 bits in the accumulator are ignored).
;-----------------------------------------------------------

print_digit:
        and     #$0F                                    ; Convert the digit to the appropriate character
        ora     #$30

        cmp     #$3A                                    ; If the digit is greater than 9...
        bcc     mi_print_char
        adc     #$06                                    ; ...convert to the appropriate hex character

        ; continued in mi_print_char



;-----------------------------------------------------------
;                        mi_print_char
;
; Prints the character in the accumulator to the screen at
; the current cursor position, then advances the cursor by
; one.
;-----------------------------------------------------------

mi_print_char:
        jsr     st_print_char                           ; Print the character and advance the cursor
        inc     CUR_X

done:   rts



;-----------------------------------------------------------
;                      print_char_or_esc
;
; Either prints the charater in the accumulator, or it is
; an escape code, perform the appropriate action:
;
; $7C - print line feed/carriage return
; $7D - do nothing
; $7E - print line feed/carriage return, and move cursor to
;       the second column
; $7F - If the cursor is in the first column, advance to
;       the second column, otherwise treat like $7E
;-----------------------------------------------------------

print_char_or_esc:
        and     #$7F                                    ; Strip off the top bit.

        cmp     #$7C                                    ; If the character is not an escape code, print it
        bcc     mi_print_char

        beq     print_lfcr                              ; Handle code $7C

        cmp     #$7E
        beq     mi_print_crlf_col_1                     ; Handle code $7E

        cmp     #$7D
        bne     done                                    ; Handle code $7D

        ; Continued in indent

;-----------------------------------------------------------
;                          indent
;
; Indents the cursor position as if the $7F escape character
; was printed.
;-----------------------------------------------------------

indent: lda     CUR_X                                   ; Handle code $7F
        cmp     #$02
        bcc     mi_cursor_to_col_1

        ; continued in mi_print_crlf_col_1



;-----------------------------------------------------------
;                    mi_print_crlf_col_1
;
; Print a line feed and carriage return, then move the
; cursor to the second column.
;-----------------------------------------------------------

mi_print_crlf_col_1:
        jsr     print_lfcr

        ; continued in mi_cursor_to_col_1



;-----------------------------------------------------------
;                     mi_cursor_to_col_1
;
; Move the cursor to the second column.
;-----------------------------------------------------------

mi_cursor_to_col_1:
        lda     #$01
        sta     CUR_X
        rts



;-----------------------------------------------------------
;              clear_to_end_then_print_lfcr
;
; Clear the current row of text after the cursor, then
; advance the cursor to the start of the next row.
;-----------------------------------------------------------

clear_to_end_then_print_lfcr:
        jsr     st_clear_to_end_of_text_row_a

        ; continued in print_lfcr



;-----------------------------------------------------------
;                         print_lfcr
;
; Prints a line feed and carriage return, moving the cursor
; to the beginning of the next line.
;-----------------------------------------------------------

print_lfcr:
        inc     CUR_Y                                   ; Advance to the next line

        lda     CUR_Y                                   ; If we have not reached the end of the text window...
        cmp     CUR_Y_MAX
        bcc     mi_cursor_to_col_0                      ; ...move the cursor to the first column.

        tya                                             ; Otherwise, scroll the text area up one row...
        pha
        txa
        pha

        jsr     st_scroll_text_area_up

        pla
        tax
        pla
        tay

        ; continued in mi_cursor_to_col_0



;-----------------------------------------------------------
;                   mi_cursor_to_col_0
;
; Move the cursor to the first column.
;-----------------------------------------------------------

mi_cursor_to_col_0:
        lda     #$00
        sta     CUR_X
        rts



;-----------------------------------------------------------
;                 reduce_text_window_size
;
; Reduces the size of the text window by moving all of the
; edges inward by one unit. Resets the cursor to the
; top-left of the new text window.
;-----------------------------------------------------------

reduce_text_window_size:
        inc     CUR_Y_MIN                               ; Shift top border down by one

        dec     CUR_Y_MAX                               ; Shift bottom border up by one

        inc     CUR_X_OFF                               ; Shift window one to the right

        dec     CUR_X_MAX                               ; Reduce window width by two
        dec     CUR_X_MAX

        lda     CUR_Y_MIN                               ; Move cursor back to top-left corner
        sta     CUR_Y
        bne     mi_cursor_to_col_0                      ; (this branch is always taken since CUR_Y_MIN always >= 1)



;-----------------------------------------------------------
;                mi_print_string_entry_x
;
; Prints an entry from a string table. The address of the
; string table must be located immediately after the JSR
; instruction that calls this method. The x register must
; contain the entry to print.
;-----------------------------------------------------------

mi_print_string_entry_x:
        sec                                             ; w81AD := 0x80  (set the high bit)
        ror     w81AD

        bit     a:zpA2

        ; continued in mi_print_string_entry_x2

;-----------------------------------------------------------
;-----------------------------------------------------------

mi_print_string_entry_x2:
        pla                                             ; Pull the return address from the stack into rts_ptr 
        sta     rts_ptr
        pla
        sta     rts_ptr + 1

        jsr     inc_then_read_ptr                       ; Use the return address to read the location of the string table
        sta     read_ptr
        jsr     inc_then_read_ptr
        sta     read_ptr + 1

        lda     rts_ptr + 1                             ; Put the updated return address back onto the stack
        pha
        lda     rts_ptr
        pha

        txa                                             ; a := x (index of string to print)

        beq     @print_string                           ; If string 0 is requested, skip to printing it

@loop:  jsr     read_then_inc_ptr                       ; Read the next byte in the string table

        asl     a                                       ; If the high bit is not set, keep reading
        bcc     @loop

        dex                                             ; x := x - 1
        bne     @loop                                   ; Keep going until x = 0

@print_string:
        jsr     read_then_inc_ptr                       ; Get the next byte to print

        cmp     #$7F                                    ; If the byte is $7F, then the next byte indicates...
        beq     @skip_ahead                             ; ...how many characters to advance the cursor

        pha

        bit     w81AD                                   ; If the high bit of w81AD is not set...
        bpl     @print_char                             ; ...then print the character

        and     #$7F                                    ; Strip the high bit of the byte

        cmp     #$7C                                    ; If the byte is an escape code...
        bcs     @print_char                             ; ...then print it

        cmp     #$61                                    ; If the character is not a lower case letter...
        bcc     @store                                  ; ...then store it in w81AD
        cmp     #$7B
        bcs     @store

        eor     #$20                                    ; Convert character to upper case, then store in w81AD

@store: sta     w81AD

@print_char:
        jsr     print_char_or_esc                       ; Print the character or escape code

        pla

        bpl     @print_string                           ; If the high bit is not set, then keep going

        lsr     w81AD                                   ; Clear the high bit of w81AD
        rts



@skip_ahead:
        jsr     read_then_inc_ptr
        clc
        adc     CUR_X
        sta     CUR_X
        jmp     @print_string



;-----------------------------------------------------------
;                    mi_print_text_at_x_y
;
; Prints the string located immediately after the JSR 
; instruction calling this method at the location specified
; in the x and y registers.
;-----------------------------------------------------------

mi_print_text_at_x_y:
        stx     CUR_X
        sty     CUR_Y

        ; continued in mi_print_text



;-----------------------------------------------------------
;                       mi_print_text
;
; Prints the string located immediately after the JSR 
; instruction calling this method at the current cursor
; location.
;-----------------------------------------------------------

mi_print_text:
        pla                                             ; Pull the return address from the stack into rts_ptr
        sta     rts_ptr
        pla
        sta     rts_ptr + 1

@loop:  jsr     inc_then_read_ptr                       ; Read the next byte of the string

        beq     @done                                   ; If the next byte is 0, then we are done

        cmp     #$7F                                    ; If the next byte is $7F, then the following byte indicates...
        beq     @skip_ahead                             ; how many characters to advance the cursor

        jsr     print_char_or_esc                       ; Print the character, then look for more
        jmp     @loop

@skip_ahead:
        jsr     inc_then_read_ptr                       ; Read how many characters to advance

        clc                                             ; Advance the cursor by the specified number
        adc     CUR_X
        sta     CUR_X

        jmp     @loop

@done:  lda     rts_ptr + 1                             ; Push the updated return address back onto the stack
        pha
        lda     rts_ptr
        pha

        rts



;-----------------------------------------------------------
;                     mi_print_x_chars
;
; Prints the character in the accumulator a number of times
; equal to the value in the x register.
;-----------------------------------------------------------

mi_print_x_chars:
        jsr     mi_print_char
        dex
        bne     mi_print_x_chars
        rts



.segment "CODE_READ_NEXT"

;-----------------------------------------------------------
;                     inc_then_read_ptr
;
; Increments the rts pointer, then reads the byte located
; at the resulting address.
;-----------------------------------------------------------

inc_then_read_ptr:
        inc     rts_ptr
        bne     @read_byte
        inc     rts_ptr + 1
@read_byte:
rts_ptr         := * + 1
        lda     BASIC_BUF
        rts



;-----------------------------------------------------------
;                     read_then_inc_ptr
;
; Reads the byte located at the address pointed to by the
; read pointer, then increments the read pointer.
;-----------------------------------------------------------

read_then_inc_ptr:
read_ptr        := * + 1
        lda     BASIC_BUF
        inc     read_ptr
        bne     @done
        inc     read_ptr + 1
@done:  rts



.segment "DATA_81AD"

w81AD:
        .byte   $00
