.include "milib.inc"
.include "stlib.inc"
.include "diskio.inc"

.export clear_text_area
.export create_character
.export draw_border

.export s948D

.import print_character_roster

.import main_menu

character_roster    := $B000
selected_character  := $C4F8

        .setcpu "6502"

.segment "CODE_ZZZ"

create_character:
        ldx     #$00
b8E23:  txa
        asl     a
        asl     a
        asl     a
        asl     a
        tay
        lda     character_roster,y
        bne     b8E31
        jmp     j8EE6

b8E31:  inx
        cpx     #$04
        bcc     b8E23
        jsr     print_character_roster
        ldx     #$01
        ldy     #$0E
        jsr     mi_print_text_at_x_y
        .byte   " Thou must first remove a chara"



        .byte   "cter.~ Enter a character number"



        .byte   " (1-4) or~ space bar to return "



        .byte   "to main menu.||"

        .byte   $7F,$0D
        .byte   "Thy choice: "

        .byte   $00
b8EBB:  jsr     st_read_input
        cmp     #$20
        bne     b8EC5
        jmp     main_menu

b8EC5:  cmp     #$31
        bcc     b8EBB
        cmp     #$35
        bcs     b8EBB
        sec
        sbc     #$31
        tax
        stx     selected_character
        asl     a
        asl     a
        asl     a
        asl     a
        tax
        lda     #$00
        sta     character_roster,x
        ldx     #$01
        jsr     save_file
        ldx     selected_character
j8EE6:  stx     selected_character
        jsr     st_set_text_window_full
        jsr     draw_border
        ldy     #$00
        ldx     #$08
        jsr     mi_print_text_at_x_y
        .byte   $0E
        .byte   " Character Generation "


        .byte   $18
        .byte   "~"
        .byte   $00
        jsr     clear_text_area
        lda     #$E4
        sta     w8F2B
        lda     #$81
        sta     w8F2C
        lda     #$F7
        sta     w8F28
        lda     #$93
        sta     w8F29
b8F27:
w8F28           := * + 1
w8F29           := * + 2
        lda     $FFFF
w8F2B           := * + 1
w8F2C           := * + 2
        sta     $FFFF
        inc     w8F28
        bne     b8F35
        inc     w8F29
b8F35:  inc     w8F2B
        bne     b8F3D
        inc     w8F2C
b8F3D:  lda     w8F28
        cmp     #$7F
        bne     b8F27
        lda     w8F29
        cmp     #$94
        bne     b8F27
        jsr     s9359
        lda     #$1E
        sta     w93E7
        ldx     #$01
        stx     w93E9
        ldy     #$0F
        jsr     mi_print_text_at_x_y
        .byte   " Move cursor with up and down a"



        .byte   "rrows,~ increase and decrease a"



        .byte   "ttributes~ with left and right "



        .byte   "arrows.~ Press RETURN when fini"



        .byte   "shed,~ or space bar to go back "



        .byte   "to main menu."

        .byte   $00
b9006:  jsr     s9359
        lda     #$63
        sta     CUR_X
        jsr     st_read_input
        tay
        lda     w93E9
        asl     a
        tax
        cpy     #$20
        bne     b901D
        jmp     main_menu

b901D:  cpy     #$3A
        bne     b9030
        lda     player_hits,x
        cmp     #$0A
        beq     b9006
        dec     player_hits,x
        inc     w93E7
        bne     b9006
b9030:  cpy     #$3B
        bne     L9048
        lda     w93E7
        beq     b9006
        lda     player_hits,x
        cmp     #$19
        bcs     b9006
        inc     player_hits,x
        dec     w93E7
        bpl     b9006
L9048:  cpy     #$2F
        bne     b905D
        inc     w93E9
        lda     w93E9
        cmp     #$07
        bcc     b9006
        lda     #$01
        sta     w93E9
        beq     b9006
b905D:  cpy     #$40
        bne     b906D
        dec     w93E9
        bne     b9006
        lda     #$06
        sta     w93E9
        bne     b9006
b906D:  cpy     #$0D
        bne     b9006
        ldy     w93E7
        beq     b907C
        jsr     mi_s8772
        jmp     b9006

b907C:  sty     w93E9
        jsr     s9359
        jsr     clear_text_area
        ldy     #$12
        ldx     #$0B
        jsr     mi_print_text_at_x_y
        .byte   "a) Human|"

        .byte   $7F,$0B
        .byte   "b) Elf|"
        .byte   $7F,$0B
        .byte   "c) Dwarf|"

        .byte   $7F,$0B
        .byte   "d) Bobbit"

        .byte   $00
        ldy     #$10
        ldx     #$02
        jsr     mi_print_text_at_x_y
        .byte   "Select thy race: "


        .byte   $00
b90CE:  jsr     st_read_input
        cmp     #$41
        bcc     b90CE
        cmp     #$45
        bcs     b90CE
        sec
        sbc     #$40
        sta     player_race
        ldy     #$0C
        ldx     #$0D
        jsr     mi_print_text_at_x_y
        .byte   "Race  "
        .byte   $00
        ldx     player_race
        jsr     mi_print_string_entry_x
        .addr   race_name_table
        jsr     clear_text_area
        lda     player_race
        cmp     #$01
        bne     b910A
        lda     player_intelligence
        clc
        adc     #$05
        sta     player_intelligence
        bne     b913A
b910A:  cmp     #$02
        bne     b9119
        lda     player_agility
        clc
        adc     #$05
        sta     player_agility
        bne     b913A
b9119:  cmp     #$03
        bne     b9128
        lda     player_strength
        clc
        adc     #$05
        sta     player_strength
        bne     b913A
b9128:  lda     player_wisdom
        clc
        adc     #$0A
        sta     player_wisdom
        lda     player_strength
        sec
        sbc     #$05
        sta     player_strength
b913A:  jsr     s9359
        ldy     #$12
        ldx     #$0B
        jsr     mi_print_text_at_x_y
        .byte   "a) Male|"
        .byte   $7F,$0B
        .byte   "b) Female"

        .byte   $00
        ldy     #$10
        ldx     #$02
        jsr     mi_print_text_at_x_y
        .byte   "Select thy sex: "

        .byte   $00
b9170:  jsr     st_read_input
        cmp     #$41
        bcc     b9170
        cmp     #$43
        bcs     b9170
        sec
        sbc     #$41
        sta     player_sex
        ldy     #$0D
        ldx     #$0E
        jsr     mi_print_text_at_x_y
        .byte   "Sex  "
        .byte   $00
        ldx     player_sex
        jsr     mi_print_string_entry_x
        .addr   sex_table
        jsr     clear_text_area
        ldy     #$12
        ldx     #$0B
        jsr     mi_print_text_at_x_y
        .byte   "a) Fighter|"

        .byte   $7F,$0B
        .byte   "b) Cleric|"

        .byte   $7F,$0B
        .byte   "c) Wizard|"

        .byte   $7F,$0B
        .byte   "d) Thief"
        .byte   $00
        ldy     #$10
        ldx     #$02
        jsr     mi_print_text_at_x_y
        .byte   "Select thy class: "


        .byte   $00
b91E8:  jsr     st_read_input
        cmp     #$41
        bcc     b91E8
        cmp     #$45
        bcs     b91E8
        sec
        sbc     #$40
        sta     player_class
        ldy     #$0E
        ldx     #$0C
        jsr     mi_print_text_at_x_y
        .byte   "Class  "
        .byte   $00
        ldx     player_class
        jsr     mi_print_string_entry_x
        .addr   class_name_table
        lda     player_class
        cmp     #$01
        bne     b922B
        lda     player_strength
        clc
        adc     #$0A
        sta     player_strength
        lda     player_agility
        clc
        adc     #$0A
        sta     player_agility
        bne     b9252
b922B:  cmp     #$02
        bne     b923A
        lda     player_wisdom
        clc
        adc     #$0A
        sta     player_wisdom
        bne     b9252
b923A:  cmp     #$03
        bne     b9249
        lda     player_intelligence
        clc
        adc     #$0A
        sta     player_intelligence
        bne     b9252
b9249:  lda     player_agility
        clc
        adc     #$0A
        sta     player_agility
b9252:  jsr     s9359
        jsr     st_get_random_number_
        sta     w8264
        jsr     st_get_random_number_
        sta     w8265
        ldy     #$10
        ldx     #$02
        jsr     mi_print_text_at_x_y
        .byte   "Enter thy name: "

        .byte   $00
        jsr     clear_text_area
        lda     #$00
        sta     w93EA
b9281:  jsr     st_read_input
        ldx     w93EA
        cmp     #$0D
        bne     b92A1
        txa
        beq     b9281
        dec     CUR_Y
        jsr     clear_text_area
        lda     #$0B
        sta     CUR_X
        lda     #$03
        sta     CUR_Y
        jsr     mi_s8BA1
        jmp     j92F4

b92A1:  cmp     #$3A
        beq     b92A9
        cmp     #$14
        bne     b92B9
b92A9:  dex
        bmi     b9281
        stx     w93EA
        lda     #$00
        sta     player_name,x
        dec     CUR_X
        jmp     b9281

b92B9:  cpx     #$00
        bne     b92D1
        cmp     #$41
        bcc     b9281
        cmp     #$5B
        bcs     b9281
b92C5:  sta     player_name,x
        inc     w93EA
        jsr     mi_print_char
        jmp     b9281

b92D1:  cpx     #$0D
        bcs     b9281
        cmp     #$20
        bcc     b9281
        cmp     #$40
        beq     b9281
        cmp     #$2F
        beq     b9281
        cmp     #$41
        bcc     b92C5
        cmp     #$5B
        bcs     b92C5
        ldy     player_sex,x
        cpy     #$20
        beq     b92C5
        ora     #$20
        bne     b92C5
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

w93E7:  .byte   $00,$00
w93E9:  .byte   $00
w93EA:  .byte   $00
sex_table:
        .byte   "mal"
        .byte   $E5
        .byte   "femal"
        .byte   $E5
        .byte   $CA,$01,$00,$00,$FF,$FF,$27,$21
        .byte   $00,$00,$00,$00,$00,$01,$01,$00
        .byte   $01,$01,$00,$00,$00,$00,$01,$02
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$01,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$01,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$FF,$FF,$FF,$FF
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$96,$00,$0A,$00,$0A,$00,$0A
        .byte   $00,$0A,$00,$0A,$00,$0A,$00,$64
        .byte   $00,$01,$00,$01,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$95
        .byte   $C8,$00,$00,$00,$E8,$03,$E8,$03
        .byte   $00,$FF,$EF,$BE,$00,$00,$00,$00
        .byte   $00,$00
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

draw_border:
        lda     #$10
        jsr     mi_print_char
        ldx     #$26
        lda     #$04
        jsr     mi_print_x_chars
        lda     #$12
        jsr     st_print_char
b94E8:  inc     CUR_Y
        jsr     mi_cursor_to_col_0
        lda     #$0A
        jsr     st_print_char
        lda     #$27
        sta     CUR_X
        lda     #$08
        jsr     st_print_char
        jsr     st_scan_and_buffer_input
        lda     CUR_Y
        eor     #$16
        bne     b94E8
        sta     CUR_X
        inc     CUR_Y
        lda     #$14
        jsr     mi_print_char
        ldx     #$26
        lda     #$02
        jsr     mi_print_x_chars
        lda     #$16
        jsr     st_print_char
cursor_to_1_1:
        ldx     #$01
        stx     CUR_X
        stx     CUR_Y
        rts
