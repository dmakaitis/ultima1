.include "milib.inc"
.include "stlib.inc"
.include "diskio.inc"

.import create_character
.import cursor_to_1_1
.import draw_border
.import main_menu

.import w93E7
.import w93E9

.export clear_text_area

.export j92F4
.export s9359
.export s948D

character_roster    := $B000
selected_character  := $C4F8

        .setcpu "6502"

.segment "CODE_ZZZ"

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
b933B:  lda     player_name,y
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

s9359:  lda     #$00
        sta     w85BE
        sta     w81C4
        ldx     #$05
        stx     CUR_X
        ldy     #$03
        sty     CUR_Y
        lda     w93E9
        beq     b9393
        jsr     mi_print_text
        .byte   "Points left to distribute: "



        .byte   $00
        lda     w93E7
        jsr     mi_s8582
b9393:  dec     CUR_X_MAX
        jsr     st_clear_to_end_of_text_row_a
        inc     CUR_X_MAX
        jsr     mi_s83F3
b939D:  inc     w81C4
        inc     CUR_Y
        ldx     #$0A
        stx     CUR_X
        lda     #$20
        ldx     w81C4
        cpx     w93E9
        bne     b93B2
        lda     #$0E
b93B2:  jsr     mi_print_char
        jsr     mi_print_string_entry_x
        .addr   r7842_table
        lda     #$2E
        sta     w85BE
b93BF:  jsr     mi_print_char
        ldx     CUR_X
        cpx     #$1A
        bcc     b93BF
        lda     w81C4
        asl     a
        tax
        lda     player_hits,x
        jsr     mi_s8582
        lda     #$20
        ldx     w81C4
        cpx     w93E9
        bne     b93DF
        lda     #$18
b93DF:  jsr     mi_print_char
        cpx     #$06
        bcc     b939D
        rts




.segment "CODE_ZZZ2"

s947F:  ldx     #$02
        stx     CUR_X
        ldy     #$14
        sty     CUR_Y
        jsr     clear_text_area
        jmp     mi_print_text

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
