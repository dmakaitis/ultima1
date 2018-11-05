;-------------------------------------------------------------------------------
;
; createchar.s
;
; Selects the slow in which to create a new character before sending the user
; to the character generation screen.
;
;-------------------------------------------------------------------------------

.include "mi.inc"
.include "st.inc"
.include "hello.inc"

.export create_character

.import character_generation
.import main_menu
.import print_character_roster

character_roster    := $B000

        .setcpu "6502"

.segment "CODE_NEW_CHARACTER"

;-----------------------------------------------------------
;                    create_character
;
; Selects the slow in which to create a new character
; before sending the user to the character generation
; screen. If there is already an empty slot, the first
; empty slot will be selected. Otherwise, the player will
; be prompted to select a character to delete, and the
; newly empty slot will be selected.
;-----------------------------------------------------------

create_character:
        ldx     #$00                                    ; Start with the first slot

b8E23:  txa                                             ; See if the current slot is empty
        asl     a
        asl     a
        asl     a
        asl     a
        tay
        lda     character_roster,y

        bne     b8E31                                   ; If it is, then we have at least one empty slot for a new character
        jmp     character_generation                    ; Go to the character generation screen with the first empty slot selected

b8E31:  inx                                             ; If the slot is not empty, keep going until we have checked all four
        cpx     #$04
        bcc     b8E23

        jsr     print_character_roster                  ; Since no slots are empty, prompt the user to delete a character

        ldx     #$01
        ldy     #$0E
        jsr     mi_print_text_at_x_y

        .byte   " Thou must first remove a character.~"
        .byte   " Enter a character number (1-4) or~"
        .byte   " space bar to return to main menu.||",$7F

        .byte   $0D,"Thy choice: ",$00

b8EBB:  jsr     st_read_input

        cmp     #$20                                    ; If the user entered a ' ', go back to the main menu
        bne     @validate_input
        jmp     main_menu

@validate_input:
        cmp     #$31                                    ; Make sure the user entered a value from '1' to '4'
        bcc     b8EBB
        cmp     #$35
        bcs     b8EBB

        sec                                             ; Store the selected character
        sbc     #$31
        tax
        stx     selected_character

        asl     a                                       ; Delete the selected character in the roster
        asl     a
        asl     a
        asl     a
        tax
        lda     #$00
        sta     character_roster,x

        ldx     #$01                                    ; Save the updated roster
        jsr     save_file

        ldx     selected_character                      ; Load the deleted character slot into x

        ; continued in character_generation
        