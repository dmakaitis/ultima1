.include "milib.inc"
.include "stlib.inc"
.include "diskio.inc"

.import create_character
.import cursor_to_1_1
.import draw_border
.import main_menu

.export clear_text_area

.export j92F4
.export s948D

character_roster    := $B000
selected_character  := $C4F8

        .setcpu "6502"

.segment "CODE_ZZZ"

;-----------------------------------------------------------
;                         j92F4
;
;-----------------------------------------------------------

j92F4:  jsr     s947F
        .byte   "~ Save this character? (Y-N) "



        .byte   $00
        jsr     clear_text_area
        jsr     st_read_input
        jsr     st_print_char
        cmp     #$59
        beq     b9329
        cmp     #$4E
        bne     j92F4
        jmp     create_character

b9329:  lda     selected_character
        asl     a
        asl     a
        asl     a
        asl     a
        tax
        lda     #$FF
        sta     character_roster,x
        ldy     #$00
        inx
        inx
        inx
b933B:  lda     mi_player_name,y
        sta     character_roster,x
        inx
        iny
        cpy     #$0D
        bcc     b933B
        ldx     #$01
        jsr     save_file
        lda     selected_character
        clc
        adc     #$02
        tax
        jsr     save_file
        jmp     main_menu



.segment "CODE_ZZZ2"

;-----------------------------------------------------------
;                         s947F
;
;-----------------------------------------------------------

s947F:  ldx     #$02
        stx     CUR_X
        ldy     #$14
        sty     CUR_Y
        jsr     clear_text_area
        jmp     mi_print_text




;-----------------------------------------------------------
;                         s948D
;
;-----------------------------------------------------------

s948D:  ldx     #$02
        ldy     #$15
        jsr     mi_print_text_at_x_y

        .byte   "Press Space to continue: ",$00

        jsr     st_read_input
        jsr     mi_cursor_to_col_1

        lda     #$14
        sta     CUR_Y
        bne     clear_text_area

        jsr     st_set_text_window_full
        jsr     cursor_to_1_1
clear_text_area:
        jsr     mi_store_text_area
        dec     CUR_X_MAX
b94C5:  jsr     st_clear_to_end_of_text_row_a
        jsr     mi_cursor_to_col_1
        inc     CUR_Y
        ldy     CUR_Y
        iny
        cpy     CUR_Y_MAX
        bcc     b94C5
        jmp     mi_restore_text_area
