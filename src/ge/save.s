;-------------------------------------------------------------------------------
;
; save_character.s
;
; Saves the newly created character and updates the character roster.
;
;-------------------------------------------------------------------------------

.include "mi.inc"
.include "st.inc"
.include "hello.inc"

.export save_character

.import clear_and_print_text_at_2_20
.import clear_text_area_below_cursor
.import create_character
.import main_menu

character_roster    := $B000

        .setcpu "6502"

.segment "CODE_SAVE"

;-----------------------------------------------------------
;                     save_character
;
; Saves the newly created character and updates the
; character roster.
;-----------------------------------------------------------

save_character:
        jsr     clear_and_print_text_at_2_20

        .byte   "~ Save this character? (Y-N) ",$00

        jsr     clear_text_area_below_cursor

        jsr     st_read_input
        jsr     st_print_char

        cmp     #$59                                    ; Did the user type 'Y'?
        beq     @confirmed

        cmp     #$4E                                    ; Did the user type 'N'?
        bne     save_character

        jmp     create_character                        ; If we decide not to save, start over...

@confirmed:
        lda     selected_character                      ; x := selected_character * 16
        asl     a
        asl     a
        asl     a
        asl     a
        tax

        lda     #$FF                                    ; Mark the roster slot as taken
        sta     character_roster,x

        ldy     #$00                                    ; y := 0

        inx                                             ; x += 3
        inx
        inx

@loop:  lda     mi_player_name,y                        ; Copy the character name into the roster
        sta     character_roster,x
        inx
        iny
        cpy     #$0D                                    ; Copy 13 characters                     
        bcc     @loop

        ldx     #$01                                    ; Save the character roster
        jsr     save_file

        lda     selected_character                      ; Save the character
        clc
        adc     #$02
        tax
        jsr     save_file

        jmp     main_menu                               ; Return to the main menu
