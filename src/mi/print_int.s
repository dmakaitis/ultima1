;-------------------------------------------------------------------------------
;
; print_int.s
;
; Routines for printing numbers to the screen.
;
;-------------------------------------------------------------------------------

.export mi_print_short_int
.export mi_to_decimal_a_x

.export mi_number_padding

.export print_long_int

.import mi_print_char
.import mi_print_digit

dec_lo          := $3C
dec_mid         := $3D
dec_hi          := $3E
hex_lo          := $3F
hex_hi          := $40

        .setcpu "6502"

.segment "CODE_PRINT_INT"

;-----------------------------------------------------------
;                     mi_to_decimal_a_x
;
; Converts a 16-bit hexadecimal number to decimal. The high
; byte of the number should be in the accumulator, and the
; low byte should be in the x register. The resulting
; decimal value will be stored in zero page memory at
; $3C-$3E, low byte first, and each decimal digit encoded
; into four bits in the output (in BCD format).
;-----------------------------------------------------------

mi_to_decimal_a_x:
        stx     hex_lo                                  ; Store the hexadecimal number to convert
        sta     hex_hi

        ldx     #$00                                    ; Clear the decimal number buffer
        stx     dec_lo
        stx     dec_mid
        stx     dec_hi

        stx     dec_addend_hi                           ; Set the decimal addend to 1
        stx     dec_addend_mid
        inx
        stx     dec_addend_lo

        sed                                             ; Put the CPU in decimal mode

@loop:  lsr     hex_hi                                  ; Shift all bits in the number to convert to the right
        ror     hex_lo                                  ; putting the lowest bit into the carry flag

        bcc     @increase_adder                         ; If the carry flag is clear, increase the decimal addend

        clc                                             ; Add the addend value to the decimal buffer
        lda     dec_lo
        adc     dec_addend_lo
        sta     dec_lo
        lda     dec_mid
        adc     dec_addend_mid
        sta     dec_mid
        lda     dec_hi
        adc     dec_addend_hi
        sta     dec_hi

@increase_adder:
        clc                                             ; Multiply the addend value by two
        lda     dec_addend_lo
        adc     dec_addend_lo
        sta     dec_addend_lo
        lda     dec_addend_mid
        adc     dec_addend_mid
        sta     dec_addend_mid
        lda     dec_addend_hi
        adc     dec_addend_hi
        sta     dec_addend_hi

        lda     hex_lo                                  ; Are there any non-zero bits left to convert?
        ora     hex_hi
        bne     @loop

        cld                                             ; Put the CPU back into normal mode

        rts



;-----------------------------------------------------------

dec_addend_lo:                                          ; Decimal addend storage
        .byte   $01
dec_addend_mid:
        .byte   $00
dec_addend_hi:
        .byte   $00



;-----------------------------------------------------------
;                      print_long_int
;
; Prints a 16-bit integer to the screen at the current
; cursor position. The high byte of the value should be in
; the accumulator, and the low byte should be in the x
; register.
;-----------------------------------------------------------

print_long_int:
        jsr     mi_to_decimal_a_x                       ; Convert the number to decimal

        inx                                             ; x will either contain 1 or 2, depending on number size
        bne     print_int                               ; branch always taken...



;-----------------------------------------------------------
;                     mi_print_short_int
;
; Prints an 8-bit integer to the screen at the current
; cursor position. The value to print should be in the
; accumulator.
;-----------------------------------------------------------

mi_print_short_int:
        tax                                             ; Move the number into the x register and...
        lda     #$00                                    ; ...put zero into the accumulator

        jsr     mi_to_decimal_a_x                       ; Now we can treat this like a 16-bit number

print_int:
        sta     last_digit_printed                      ; last_digit_printed := 0 (accumulator always contains zero at this point)
        jmp     @check_if_last_digit                    ; (x always contains 1 or 2 at this point)

@print_high_nibble:
        lda     dec_lo,x
        lsr     a
        lsr     a
        lsr     a
        lsr     a
        jsr     @print_digit

@check_if_last_digit:
        txa                                             ; if x != 0, then the number always starts in the low
        bne     @print_low_nibble                       ; nibble of the last decimal byte

        inc     last_digit_printed                      ; Ensure that we will always print the final digit (might be zero)

@print_low_nibble:
        lda     dec_lo,x                                ; Get the current byte
        jsr     @print_digit

        dex                                             ; If there are still bytes, print the high nibble of the next byte
        bpl     @print_high_nibble

@done:  rts



@print_digit:
        and     #$0F                                    ; Mask out the high nibble
        bne     @update_and_print                       ; If the digit is not zero, always print it

        cmp     last_digit_printed                      ; Have we already printed a digit?
        bne     @print

        lda     mi_number_padding                       ; Do we need to pad the number?
        beq     @done

        jmp     mi_print_char

@update_and_print:
        sta     last_digit_printed                      ; Print the digit

@print: jmp     mi_print_digit                          ; Go back for the next digit



last_digit_printed:
        .byte   $00

mi_number_padding:
        .byte   $00