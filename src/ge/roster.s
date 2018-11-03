;-------------------------------------------------------------------------------
;
; roster.s
;
; Displays the roster of characters the user may choose to play with.
;
;-------------------------------------------------------------------------------

.include "st.inc"

.export print_character_roster

character_roster    := $B000

        .setcpu "6502"

.segment "CODE_ROSTER"

;-----------------------------------------------------------
;                   print_character_roster
;
; Displays the roster of characters for the user. Each
; character will be printed with a number in front of it
; identifying each character with an ID from 1 to 4.
;-----------------------------------------------------------

print_character_roster:
        jsr     st_clear_main_viewport

        lda     #$00
        sta     character_index

@loop:  lda     #$0D                                    ; Move cursor to column 13
        sta     CUR_X

        lda     character_index                         ; Move cursor to row 8 + character_index
        clc
        adc     #$08
        sta     CUR_Y

        lda     character_index                         ; Print character number
        clc
        adc     #$31
        jsr     st_print_char
        inc     CUR_X

        lda     #$2E                                    ; Print '.'
        jsr     st_print_char
        inc     CUR_X

        lda     #$20                                    ; Print ' '
        jsr     st_print_char
        inc     CUR_X

        lda     #$0C                                    ; Character names have at most 12 characters
        sta     name_counter

        lda     character_index                         ; Calculate the index of the current character name in roster
        asl     a                                       ; (each name starts at 16 byte intervals)
        asl     a
        asl     a
        asl     a
        tax

        lda     character_roster,x                      ; If there is no name in this slot, skip it
        beq     @next

        inx                                             ; Skip to the third byte in the slot
        inx
        inx

@loop_name:
        lda     character_roster,x                      ; If the current character is 0x00, then we're done
        beq     @next

        jsr     st_print_char                           ; Print the current character in the character's name
        inc     CUR_X

        inx                                             ; Advance to the next character

        dec     name_counter                            ; If we haven't printed 12 characters yet, keep going
        bpl     @loop_name

@next:  inc     character_index                         ; Loop through all four characters
        lda     character_index
        cmp     #$04
        bcc     @loop
        rts



character_index:
        .byte   $00
name_counter:
        .byte   $00
