;-------------------------------------------------------------------------------
;
; selectchar.s
;
; Prompts the user to select a character and waits for the user response.
;
;-------------------------------------------------------------------------------

.include "mi.inc"
.include "st.inc"

.export select_character

.import main_menu
.import print_character_roster

character_roster    := $B000
selected_character  := $C4F8

        .setcpu "6502"

.segment "CODE_CHAR_SELECT"

;-----------------------------------------------------------
;                   select_character
;
; Prompts the user to select a character and waits for the
; user response.
;-----------------------------------------------------------

select_character:
        jsr     print_character_roster

        ldx     #$05
        ldy     #$0E
        jsr     mi_print_text_at_x_y

        .byte   "Select a character (1-4) or~",$7F
        .byte   $04,"space bar to return to menu.||",$7F
        .byte   $0D,"Thy choice: ",$00

@wait_for_input:
		jsr     st_read_input

        cmp     #$20									; If the user pressed ' ' then go back to the main menu
        bne     @validate_input
        jmp     main_menu

@validate_input:
		cmp     #$31									; If the input is not in the range '1' to '4', keep waiting
        bcc     @wait_for_input
        cmp     #$35
        bcs     @wait_for_input

        sec												; Store the selected character index
        sbc     #$31
        sta     selected_character

        asl     a										; If there is no character in that slot, keep waiting for user input
        asl     a
        asl     a
        asl     a
        tax
        lda     character_roster,x
        beq     @wait_for_input

        rts
