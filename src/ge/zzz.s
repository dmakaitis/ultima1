.include "milib.inc"
.include "stlib.inc"
.include "diskio.inc"

.import create_character
.import cursor_to_1_1
.import draw_border
.import main_menu

.export clear_text_area_below_cursor

.export save_character
.export wait_for_user

character_roster    := $B000
selected_character  := $C4F8

        .setcpu "6502"

.segment "CODE_ZZZ"

;-----------------------------------------------------------
;                     save_character
;
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



.segment "CODE_ZZZ2"

;-----------------------------------------------------------
;                clear_and_print_text_at_2_20
;
;-----------------------------------------------------------

clear_and_print_text_at_2_20:
        ldx     #$02
        stx     CUR_X
        ldy     #$14
        sty     CUR_Y
        jsr     clear_text_area_below_cursor
        jmp     mi_print_text




;-----------------------------------------------------------
;                      wait_for_user
;
;-----------------------------------------------------------

wait_for_user:
        ldx     #$02
        ldy     #$15
        jsr     mi_print_text_at_x_y

        .byte   "Press Space to continue: ",$00

        jsr     st_read_input
        jsr     mi_cursor_to_col_1

        lda     #$14
        sta     CUR_Y
        bne     clear_text_area_below_cursor

        jsr     st_set_text_window_full
        jsr     cursor_to_1_1

        ; continued in clear_text_area_below_cursor



;-----------------------------------------------------------
;                clear_text_area_below_cursor
;
;-----------------------------------------------------------

clear_text_area_below_cursor:
        jsr     mi_store_text_area

        dec     CUR_X_MAX

@loop:  jsr     st_clear_to_end_of_text_row_a

        jsr     mi_cursor_to_col_1
        inc     CUR_Y

        ldy     CUR_Y
        iny
        cpy     CUR_Y_MAX
        bcc     @loop

        jmp     mi_restore_text_area
