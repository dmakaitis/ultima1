.include "c64.inc"

.include "milib.inc"
.include "stlib.inc"
.include "diskio.inc"

PROCESSOR_PORT  := $0001

r81E3           := $81E3
r81E7           := $81E7

wB000           := $B000
rB010           := $B010
rB020           := $B020
rB030           := $B030

wC4F8           := $C4F8

        .setcpu "6502"

.segment "CODE_ZZZ"

        ldx     #$11
        jsr     load_file_cached
j8CA3:  jsr     st_set_text_window_full
        lda     #$00
        sta     BM2_ADDR_MASK
        sta     BM_ADDR_MASK
        jsr     draw_border
        jsr     clear_text_area
        ldy     #$06
        ldx     #$0C
        jsr     mi_print_text_at_x_y
        .byte   $1B,$1B,$1B
        .byte   " Ultima I "

        .byte   $1B,$1B,$1B
        .byte   "||"
        .byte   $7F,$0E
        .byte   "from darkest|"

        .byte   $7F,$0E
        .byte   "dungeons, to|"

        .byte   $7F,$0D
        .byte   "deepest space!|||"


        .byte   $7F,$07
        .byte   "a) Generate new character|"



        .byte   $7F,$07
        .byte   "b) Continue previous game||"



        .byte   $7F,$0D
        .byte   "Thy choice: "

        .byte   $00
        jsr     st_swap_bitmaps
b8D47:  jsr     st_read_input
        pha
        jsr     clear_text_area
        pla
        cmp     #$41
        bne     b8D56
        jmp     b8E21

b8D56:  cmp     #$42
        bne     b8D47
        lda     #$62
        jsr     st_print_char
        lda     wB000
        ora     rB010
        ora     rB020
        ora     rB030
        beq     b8DA9
        jsr     s9520
        lda     wC4F8
        clc
        adc     #$12
        tax
        jsr     load_file_cached
        bcs     b8D8A
        lda     player_save_data
        cmp     #$CA
        bne     b8D8A
        lda     r81E3
        cmp     #$01
        beq     b8DDD
b8D8A:  jsr     mi_store_text_area
        ldx     #$02
        ldy     #$14
        jsr     mi_print_text_at_x_y
        .byte   "Disk error."

        .byte   $00
        jsr     mi_restore_text_area
        jsr     s948D
        jmp     j8CA3

b8DA9:  jsr     mi_store_text_area
        ldx     #$02
        ldy     #$15
        jsr     mi_print_text_at_x_y
        .byte   "Thou must first create a charac"



        .byte   "ter."
        .byte   $00
        jsr     mi_restore_text_area
        jmp     b8D47

b8DDD:  ldy     #$00
        lda     #$30
        sta     PROCESSOR_PORT
        ldx     #$0D
b8DE5:
w8DE7           := * + 2
        lda     d000_ram_init_data,y
w8DEA           := * + 2
        sta     VIC_SPR0_X,y
        iny
        bne     b8DE5
        inc     w8DE7
        inc     w8DEA
        dex
        bne     b8DE5
        stx     CIA2_PRA
        lda     #$36
        sta     PROCESSOR_PORT
        lda     r81E7
        sta     sound_enabled_flag
        lda     #$60
        sta     BM_ADDR_MASK
        jsr     mi_s84C0
        jsr     st_set_text_window_command
        jsr     st_scroll_text_area_up
        jsr     mi_s8689
        lda     #$60
        sta     BM2_ADDR_MASK
        jsr     st_swap_bitmaps
        jsr     st_copy_screen_2_to_1
        jmp     j8C5E

b8E21:  ldx     #$00
b8E23:  txa
        asl     a
        asl     a
        asl     a
        asl     a
        tay
        lda     wB000,y
        bne     b8E31
        jmp     j8EE6

b8E31:  inx
        cpx     #$04
        bcc     b8E23
        jsr     s9598
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
        jmp     j8CA3

b8EC5:  cmp     #$31
        bcc     b8EBB
        cmp     #$35
        bcs     b8EBB
        sec
        sbc     #$31
        tax
        stx     wC4F8
        asl     a
        asl     a
        asl     a
        asl     a
        tax
        lda     #$00
        sta     wB000,x
        ldx     #$01
        jsr     save_file
        ldx     wC4F8
j8EE6:  stx     wC4F8
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
        jmp     j8CA3

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
        jmp     b8E21

b9329:  lda     wC4F8
        asl     a
        asl     a
        asl     a
        asl     a
        tax
        lda     #$FF
        sta     wB000,x
        ldy     #$00
        inx
        inx
        inx
b933B:  lda     player_name,y
        sta     wB000,x
        inx
        iny
        cpy     #$0D
        bcc     b933B
        ldx     #$01
        jsr     save_file
        lda     wC4F8
        clc
        adc     #$02
        tax
        jsr     save_file
        jmp     j8CA3

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
        .byte   "Press Space to continue: "



        .byte   $00
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

s9520:  jsr     s9598
        ldx     #$05
        ldy     #$0E
        jsr     mi_print_text_at_x_y
        .byte   "Select a character (1-4) or~"



        .byte   $7F,$04
        .byte   "space bar to return to menu.||"



        .byte   $7F,$0D
        .byte   "Thy choice: "

        .byte   $00
b9575:  jsr     st_read_input
        cmp     #$20
        bne     b957F
        jmp     j8CA3

b957F:  cmp     #$31
        bcc     b9575
        cmp     #$35
        bcs     b9575
        sec
        sbc     #$31
        sta     wC4F8
        asl     a
        asl     a
        asl     a
        asl     a
        tax
        lda     wB000,x
        beq     b9575
        rts

s9598:  jsr     st_clear_main_viewport
        lda     #$00
        sta     w95F5
b95A0:  lda     #$0D
        sta     CUR_X
        lda     w95F5
        clc
        adc     #$08
        sta     CUR_Y
        lda     w95F5
        clc
        adc     #$31
        jsr     st_print_char
        inc     CUR_X
        lda     #$2E
        jsr     st_print_char
        inc     CUR_X
        lda     #$20
        jsr     st_print_char
        inc     CUR_X
        lda     #$0C
        sta     w95F6
        lda     w95F5
        asl     a
        asl     a
        asl     a
        asl     a
        tax
        lda     wB000,x
        beq     b95EA
        inx
        inx
        inx
b95DA:  lda     wB000,x
        beq     b95EA
        jsr     st_print_char
        inc     CUR_X
        inx
        dec     w95F6
        bpl     b95DA
b95EA:  inc     w95F5
        lda     w95F5
        cmp     #$04
        bcc     b95A0
        rts

w95F5:  .byte   $00
w95F6:  .byte   $00
d000_ram_init_data:
        .byte   $08,$00,$E7,$02,$58,$06,$B6,$09
        .byte   $F8,$F8,$30,$1A,$21,$78,$19,$D8
        .byte   $09,$0A,$19,$30,$1A,$31,$60,$11
        .byte   $0D,$11,$48,$09,$12,$09,$68,$09
        .byte   $2A,$09,$28,$22,$31,$58,$19,$48
        .byte   $23,$1A,$09,$58,$09,$1A,$0D,$0A
        .byte   $09,$20,$1A,$0B,$0A,$09,$0B,$29
        .byte   $A8,$19,$0F,$0B,$2A,$09,$50,$09
        .byte   $22,$09,$20,$12,$3B,$21,$90,$31
        .byte   $3A,$09,$50,$09,$22,$09,$18,$22
        .byte   $13,$0F,$1B,$31,$70,$41,$22,$0B
        .byte   $12,$09,$50,$09,$12,$11,$18,$2A
        .byte   $0B,$09,$0B,$12,$41,$58,$51,$1A
        .byte   $0B,$09,$0A,$1B,$40,$19,$28,$11
        .byte   $3A,$81,$18,$61,$12,$23,$0A,$09
        .byte   $88,$11,$2A,$91,$18,$61,$12,$0B
        .byte   $12,$19,$80,$19,$1A,$A1,$10,$59
        .byte   $2A,$21,$88,$C1,$28,$31,$0B,$3A
        .byte   $29,$80,$C9,$28,$29,$0B,$12,$0B
        .byte   $1A,$49,$70,$C9,$20,$29,$23,$22
        .byte   $49,$68,$F9,$29,$23,$0A,$13,$41
        .byte   $20,$11,$38,$F9,$31,$0B,$0F,$1B
        .byte   $39,$0E,$20,$21,$28,$69,$18,$C1
        .byte   $13,$41,$20,$29,$28,$61,$28,$39
        .byte   $0B,$81,$13,$39,$18,$31,$28,$11
        .byte   $0A,$49,$30,$31,$13,$19,$12,$59
        .byte   $13,$79,$28,$09,$22,$39,$30,$21
        .byte   $2B,$09,$0A,$0B,$22,$49,$0B,$11
        .byte   $0B,$61,$20,$0A,$09,$22,$49,$20
        .byte   $0C,$23,$1A,$23,$0A,$61,$5B,$0A
        .byte   $21,$20,$3A,$51,$0B,$10,$0B,$18
        .byte   $22,$13,$12,$09,$0E,$1A,$39,$0B
        .byte   $22,$0B,$0A,$13,$1A,$21,$20,$42
        .byte   $49,$13,$30,$6A,$31,$13,$0F,$0B
        .byte   $1A,$0B,$1A,$29,$18,$52,$39,$13
        .byte   $40,$6A,$29,$13,$4A,$21,$20,$5A
        .byte   $29,$58,$62,$39,$13,$0A,$0B,$2A
        .byte   $29,$20,$4A,$21,$78,$12,$09,$3A
        .byte   $49,$23,$22,$29,$20,$32,$29,$88
        .byte   $0A,$21,$22,$69,$13,$1A,$29,$28
        .byte   $2A,$0E,$A8,$B9,$13,$1A,$19,$F8
        .byte   $10,$C1,$13,$1A,$11,$A8,$1B,$40
        .byte   $C9,$0B,$2A,$09,$A0,$13,$0F,$13
        .byte   $38,$D1,$0A,$11,$12,$09,$A8,$0B
        .byte   $09,$0B,$40,$09,$0C,$E1,$50,$09
        .byte   $12,$11,$98,$0E,$11,$22,$A1,$58
        .byte   $2A,$0B,$12,$11,$90,$12,$08,$22
        .byte   $91,$28,$12,$20,$0A,$13,$12,$13
        .byte   $12,$09,$0B,$70,$12,$20,$2A,$89
        .byte   $0E,$18,$1A,$18,$1B,$42,$13,$11
        .byte   $50,$09,$1A,$08,$42,$91,$22,$20
        .byte   $0B,$0F,$0B,$12,$13,$2A,$0B,$19
        .byte   $48,$11,$12,$10,$11,$2A,$89,$22
        .byte   $28,$0B,$1A,$13,$12,$0B,$1A,$0B
        .byte   $19,$48,$19,$4A,$89,$22,$11,$20
        .byte   $0B,$12,$13,$1A,$0B,$12,$13,$19
        .byte   $0A,$38,$31,$2A,$81,$32,$21,$18
        .byte   $13,$32,$0B,$12,$0B,$21,$12,$28
        .byte   $41,$1A,$79,$52,$11,$20,$0B,$12
        .byte   $2B,$12,$13,$21,$12,$08,$12,$C9
        .byte   $6A,$09,$20,$12,$09,$0B,$3A,$13
        .byte   $19,$12,$10,$12,$C1,$12,$13,$12
        .byte   $10,$22,$11,$20,$09,$1B,$12,$1B
        .byte   $09,$12,$0B,$21,$12,$08,$12,$C9
        .byte   $0A,$0B,$0F,$09,$0A,$18,$12,$11
        .byte   $28,$09,$0B,$1A,$13,$09,$13,$09
        .byte   $13,$21,$12,$10,$1A,$C1,$0B,$11
        .byte   $28,$19,$28,$1B,$0A,$13,$19,$1B
        .byte   $31,$12,$08,$22,$B1,$1B,$09,$70
        .byte   $09,$22,$61,$12,$10,$11,$0A,$A9
        .byte   $13,$08,$13,$70,$11,$12,$71,$22
        .byte   $A9,$08,$13,$10,$0B,$09,$70,$A1
        .byte   $1A,$A1,$20,$13,$09,$70,$F9,$79
        .byte   $08,$0B,$11,$70,$49,$1A,$91,$13
        .byte   $71,$90,$21,$13,$09,$18,$1A,$81
        .byte   $13,$99,$70,$21,$0B,$38,$12,$71
        .byte   $13,$A1,$68,$21,$0A,$0B,$38,$12
        .byte   $51,$1B,$09,$0B,$A9,$68,$19,$12
        .byte   $0B,$11,$18,$11,$1A,$39,$1B,$0F
        .byte   $1B,$A1,$40,$13,$18,$29,$1A,$09
        .byte   $1B,$09,$0E,$2A,$39,$0B,$31,$38
        .byte   $59,$38,$11,$0B,$18,$31,$2A,$0B
        .byte   $19,$32,$19,$88,$51,$30,$19,$0B
        .byte   $18,$39,$1A,$09,$1B,$32,$A0,$0E
        .byte   $51,$0A,$20,$11,$0E,$09,$0B,$20
        .byte   $59,$0B,$32,$88,$69,$42,$19,$0B
        .byte   $20,$81,$60,$23,$71,$5A,$09,$13
        .byte   $20,$71,$68,$13,$11,$0B,$79,$52
        .byte   $13,$20,$61,$70,$23,$31,$33,$41
        .byte   $3A,$13,$28,$39,$90,$0B,$0F,$29
        .byte   $13,$09,$13,$20,$3B,$21,$22,$13
        .byte   $30,$11,$B8,$0B,$11,$28,$1B,$58
        .byte   $23,$11,$0A,$F8,$F8,$50,$00,$F8
        .byte   $F8,$F8,$F8,$40,$22,$09,$70,$22
        .byte   $40,$2B,$78,$11,$18,$19,$18,$32
        .byte   $19,$48,$42,$28,$12,$0B,$0F,$12
        .byte   $13,$0A,$11,$0B,$48,$49,$10,$22
        .byte   $0B,$1A,$21,$18,$29,$3A,$28,$0A
        .byte   $1B,$2A,$1B,$09,$38,$49,$18,$1A
        .byte   $13,$22,$49,$4A,$20,$09,$0A,$0B
        .byte   $1A,$0B,$12,$09,$0B,$0A,$0B,$0A
        .byte   $09,$30,$49,$18,$0A,$09,$12,$13
        .byte   $22,$39,$52,$20,$2A,$13,$0A,$1B
        .byte   $22,$20,$11,$0A,$41,$18,$21,$1B
        .byte   $1A,$41,$4A,$20,$22,$13,$12,$0B
        .byte   $1A,$0B,$12,$18,$11,$1A,$39,$18
        .byte   $19,$13,$0F,$09,$1A,$41,$3A,$09
        .byte   $0E,$20,$09,$13,$0A,$0B,$1A,$0B
        .byte   $12,$13,$0A,$20,$23,$12,$31,$18
        .byte   $21,$1B,$12,$59,$2A,$09,$28,$09
        .byte   $0A,$0B,$2A,$0B,$0A,$13,$30,$0B
        .byte   $18,$1A,$21,$20,$21,$13,$12,$69
        .byte   $22,$09,$30,$22,$23,$0A,$0B,$60
        .byte   $12,$21,$28,$21,$0B,$0A,$79,$12
        .byte   $11,$30,$09,$42,$13,$50,$0B,$12
        .byte   $21,$30,$A9,$0A,$11,$30,$11,$3A
        .byte   $09,$13,$48,$0B,$0A,$29,$38,$B1
        .byte   $40,$13,$12,$1B,$12,$09,$0B,$20
        .byte   $0A,$20,$1B,$21,$40,$A9,$48,$23
        .byte   $08,$13,$0A,$13,$20,$12,$20,$09
        .byte   $13,$11,$50,$99,$80,$1B,$28,$12
        .byte   $18,$0E,$09,$0B,$0A,$11,$50,$59
        .byte   $18,$29,$C0,$09,$2A,$09,$12,$11
        .byte   $50,$51,$20,$29,$28,$0B,$88,$19
        .byte   $3A,$09,$60,$49,$28,$19,$28,$1B
        .byte   $30,$12,$30,$39,$2A,$09,$60,$49
        .byte   $28,$11,$0B,$28,$0B,$0F,$40,$1A
        .byte   $20,$41,$22,$70,$49,$20,$1B,$28
        .byte   $1B,$40,$22,$10,$41,$22,$70,$51
        .byte   $20,$0B,$38,$0B,$58,$22,$49,$12
        .byte   $78,$61,$0C,$98,$0A,$18,$1A,$41
        .byte   $0A,$80,$61,$13,$90,$1A,$18,$0A
        .byte   $49,$50,$11,$20,$61,$0B,$98,$09
        .byte   $22,$08,$12,$41,$50,$11,$20,$61
        .byte   $0B,$A0,$11,$12,$09,$12,$41,$48
        .byte   $09,$0D,$09,$20,$59,$13,$A8,$09
        .byte   $12,$11,$0A,$29,$0B,$09,$50,$11
        .byte   $30,$51,$0B,$12,$A8,$09,$12,$39
        .byte   $0B,$09,$30,$13,$10,$11,$38,$09
        .byte   $08,$29,$1B,$1A,$58,$12,$09,$38
        .byte   $41,$1B,$28,$0B,$0F,$09,$70,$29
        .byte   $13,$2A,$30,$09,$0E,$08,$1A,$09
        .byte   $38,$39,$0B,$0F,$09,$28,$0B,$11
        .byte   $48,$09,$28,$29,$13,$32,$18,$09
        .byte   $0C,$09,$10,$1A,$09,$40,$29,$13
        .byte   $09,$20,$13,$09,$48,$21,$18,$31
        .byte   $13,$22,$18,$21,$0A,$18,$0A,$09
        .byte   $48,$29,$0B,$09,$18,$1B,$09,$40
        .byte   $29,$18,$29,$0A,$13,$1A,$20,$19
        .byte   $12,$08,$0A,$08,$12,$50,$11,$1B
        .byte   $09,$18,$0B,$19,$38,$39,$10,$21
        .byte   $0A,$13,$2A,$18,$19,$0A,$10,$0A
        .byte   $09,$1A,$48,$09,$13,$11,$20,$0B
        .byte   $19,$38,$69,$42,$09,$18,$11,$22
        .byte   $09,$1A,$48,$13,$09,$30,$13,$09
        .byte   $0B,$30,$79,$0A,$11,$2A,$20,$09
        .byte   $42,$48,$0B,$09,$38,$19,$13,$20
        .byte   $0B,$79,$0A,$09,$0E,$2A,$30,$32
        .byte   $98,$21,$0B,$20,$0B,$79,$0A,$09
        .byte   $32,$30,$2A,$A0,$19,$13,$18,$09
        .byte   $0B,$0F,$81,$32,$38,$22,$98,$19
        .byte   $13,$20,$0A,$13,$0A,$29,$1B,$39
        .byte   $2A,$09,$40,$12,$50,$21,$30,$19
        .byte   $0B,$28,$2A,$21,$12,$0B,$41,$1A
        .byte   $19,$78,$49,$28,$19,$0B,$28,$09
        .byte   $2A,$19,$12,$13,$41,$0A,$29,$60
        .byte   $69,$18,$19,$0B,$30,$32,$09,$12
        .byte   $23,$71,$38,$91,$08,$0E,$19,$0B
        .byte   $30,$09,$52,$0B,$0F,$F9,$69,$13
        .byte   $30,$12,$1B,$2A,$1B,$F9,$69,$0B
        .byte   $30,$09,$12,$09,$13,$2A,$1B,$F9
        .byte   $61,$0B,$38,$09,$12,$0B,$1A,$09
        .byte   $0A,$13,$09,$13,$F9,$59,$0B,$40
        .byte   $09,$13,$0A,$21,$0B,$19,$33,$B1
        .byte   $10,$69,$0B,$48,$0B,$0A,$59,$0B
        .byte   $0A,$1B,$A9,$0B,$08,$69,$0B,$48
        .byte   $0B,$61,$0B,$0A,$0F,$0A,$13,$71
        .byte   $12,$19,$13,$08,$51,$0A,$11,$13
        .byte   $50,$51,$13,$0A,$0B,$12,$0B,$71
        .byte   $1A,$09,$13,$20,$41,$12,$11,$0B
        .byte   $60,$49,$0B,$1A,$13,$69,$12,$23
        .byte   $10,$13,$08,$39,$1A,$11,$0B,$68
        .byte   $41,$13,$1A,$13,$61,$12,$0B,$0F
        .byte   $09,$23,$09,$08,$39,$22,$09,$0B
        .byte   $68,$41,$0B,$2A,$13,$51,$22,$19
        .byte   $0B,$19,$08,$19,$18,$2A,$11,$68
        .byte   $19,$0E,$10,$11,$1B,$22,$1B,$41
        .byte   $2A,$70,$2A,$09,$18,$11,$48,$11
        .byte   $18,$11,$13,$32,$0B,$12,$39,$1A
        .byte   $80,$32,$10,$09,$12,$09,$68,$11
        .byte   $0B,$4A,$11,$10,$0E,$11,$22,$80
        .byte   $2A,$18,$22,$09,$58,$19,$0B,$1A
        .byte   $19,$1A,$11,$18,$09,$32,$78,$2A
        .byte   $18,$09,$22,$11,$40,$21,$12,$31
        .byte   $1A,$09,$18,$42,$68,$09,$22,$0B
        .byte   $18,$09,$0A,$0D,$1A,$09,$38,$71
        .byte   $12,$20,$1A,$09,$22,$09,$58,$19
        .byte   $12,$13,$18,$09,$2A,$09,$30,$89
        .byte   $18,$1A,$11,$1A,$11,$50,$11,$0E
        .byte   $11,$13,$28,$19,$0A,$09,$38,$69
        .byte   $30,$1A,$08,$19,$0A,$19,$48,$0B
        .byte   $21,$13,$48,$11,$40,$41,$50,$12
        .byte   $18,$21,$58,$33,$F8,$F8,$38,$00
        .byte   $F8,$F8,$20,$33,$38,$41,$50,$12
        .byte   $18,$21,$58,$33,$30,$13,$11,$0A
        .byte   $09,$13,$28,$69,$30,$1A,$08,$19
        .byte   $0A,$19,$48,$0B,$21,$13,$28,$0B
        .byte   $2A,$09,$0B,$28,$89,$18,$1A,$11
        .byte   $1A,$11,$50,$11,$0E,$11,$13,$20
        .byte   $0B,$0A,$0D,$1A,$09,$0B,$30,$71
        .byte   $12,$20,$1A,$09,$22,$09,$58,$19
        .byte   $12,$13,$18,$0B,$22,$11,$0B,$38
        .byte   $21,$12,$31,$1A,$09,$18,$42,$68
        .byte   $09,$22,$0B,$18,$0B,$1A,$09,$0B
        .byte   $08,$0B,$40,$19,$0B,$1A,$19,$1A
        .byte   $11,$18,$09,$32,$78,$2A,$18,$0B
        .byte   $12,$09,$13,$58,$11,$0B,$4A,$11
        .byte   $10,$0E,$11,$22,$80,$2A,$18,$2B
        .byte   $60,$11,$13,$32,$0B,$12,$39,$1A
        .byte   $80,$32,$80,$0E,$10,$11,$1B,$22
        .byte   $1B,$41,$2A,$70,$2A,$09,$80,$29
        .byte   $0B,$2A,$13,$51,$22,$19,$0B,$19
        .byte   $08,$19,$18,$2A,$11,$88,$21,$13
        .byte   $1A,$13,$61,$12,$0B,$0F,$09,$23
        .byte   $09,$08,$39,$22,$09,$0B,$98,$11
        .byte   $0B,$1A,$13,$69,$12,$23,$10,$13
        .byte   $08,$39,$1A,$11,$0B,$A0,$13,$0A
        .byte   $0B,$12,$0B,$71,$1A,$09,$13,$20
        .byte   $41,$12,$11,$0B,$40,$0B,$60,$0B
        .byte   $0A,$0F,$0A,$13,$71,$12,$19,$13
        .byte   $08,$51,$0A,$11,$13,$40,$0B,$0A
        .byte   $58,$0B,$0A,$1B,$A9,$0B,$08,$69
        .byte   $0B,$40,$09,$13,$0A,$20,$0B,$18
        .byte   $33,$B1,$10,$69,$0B,$38,$09,$12
        .byte   $0B,$1A,$08,$0A,$13,$08,$13,$F9
        .byte   $59,$0B,$30,$09,$12,$09,$13,$2A
        .byte   $1B,$F9,$61,$0B,$30,$12,$1B,$2A
        .byte   $1B,$F9,$69,$0B,$28,$09,$52,$0B
        .byte   $0F,$F9,$69,$13,$28,$32,$09,$12
        .byte   $23,$F9,$41,$08,$0E,$19,$0B,$28
        .byte   $09,$2A,$19,$12,$13,$41,$0A,$F1
        .byte   $18,$19,$0B,$28,$2A,$21,$12,$0B
        .byte   $41,$1A,$E9,$18,$19,$0B,$28,$0A
        .byte   $13,$0A,$29,$1B,$39,$2A,$49,$12
        .byte   $89,$18,$19,$0B,$28,$09,$0B,$0F
        .byte   $81,$32,$39,$22,$81,$18,$19,$13
        .byte   $28,$0B,$79,$0A,$09,$32,$31,$2A
        .byte   $81,$20,$19,$13,$20,$0B,$79,$0A
        .byte   $09,$0E,$2A,$31,$32,$79,$20,$21
        .byte   $0B,$28,$79,$0A,$11,$2A,$29,$42
        .byte   $49,$0B,$21,$20,$19,$13,$30,$69
        .byte   $42,$31,$22,$09,$1A,$49,$13,$21
        .byte   $18,$13,$09,$0B,$38,$39,$10,$21
        .byte   $0A,$13,$2A,$31,$0A,$10,$0A,$09
        .byte   $1A,$51,$13,$19,$18,$0B,$19,$40
        .byte   $29,$18,$29,$0A,$13,$1A,$39,$12
        .byte   $08,$0A,$08,$12,$61,$1B,$09,$18
        .byte   $0B,$19,$48,$21,$18,$31,$13,$22
        .byte   $39,$0A,$18,$0A,$79,$0B,$09,$18
        .byte   $1B,$09,$50,$09,$28,$29,$13,$32
        .byte   $21,$0C,$09,$10,$1A,$71,$13,$09
        .byte   $20,$13,$09,$78,$29,$13,$2A,$20
        .byte   $19,$0E,$08,$1A,$79,$0B,$0F,$09
        .byte   $28,$0B,$11,$58,$09,$08,$29,$1B
        .byte   $1A,$58,$12,$81,$1B,$28,$0B,$0F
        .byte   $09,$10,$23,$20,$51,$0B,$12,$68
        .byte   $49,$12,$39,$0B,$09,$30,$13,$10
        .byte   $0B,$0D,$09,$23,$59,$13,$88,$29
        .byte   $12,$11,$0A,$29,$0B,$09,$50,$13
        .byte   $09,$23,$61,$0B,$90,$21,$12,$09
        .byte   $12,$41,$50,$21,$13,$61,$0B,$98
        .byte   $09,$22,$08,$12,$41,$58,$89,$13
        .byte   $90,$1A,$18,$0A,$49,$60,$81,$0C
        .byte   $98,$0A,$18,$1A,$41,$0A,$68,$69
        .byte   $20,$0B,$38,$0B,$58,$22,$49,$12
        .byte   $68,$59,$20,$1B,$28,$1B,$40,$22
        .byte   $51,$22,$68,$49,$28,$11,$0B,$28
        .byte   $0B,$0F,$40,$1A,$61,$22,$68,$49
        .byte   $28,$19,$70,$12,$31,$10,$29,$2A
        .byte   $09,$58,$51,$20,$29,$58,$49,$20
        .byte   $11,$3A,$09,$58,$59,$18,$29,$50
        .byte   $49,$30,$2A,$09,$12,$11,$50,$99
        .byte   $50,$31,$1B,$28,$12,$18,$0E,$09
        .byte   $0B,$0A,$11,$48,$A9,$48,$23,$09
        .byte   $13,$0A,$13,$20,$12,$20,$09,$13
        .byte   $11,$40,$B1,$40,$13,$12,$1B,$12
        .byte   $09,$0B,$20,$0A,$20,$1B,$21,$30
        .byte   $A9,$0A,$11,$30,$11,$3A,$09,$13
        .byte   $48,$0B,$0A,$29,$28,$21,$0B,$0A
        .byte   $79,$12,$11,$30,$09,$42,$13,$50
        .byte   $0B,$12,$21,$20,$21,$13,$12,$69
        .byte   $22,$09,$30,$22,$23,$0A,$0B,$60
        .byte   $12,$21,$20,$21,$1B,$12,$59,$2A
        .byte   $09,$28,$09,$0A,$0B,$2A,$0B,$0A
        .byte   $13,$30,$0B,$18,$1A,$21,$20,$19
        .byte   $13,$0F,$09,$1A,$41,$3A,$09,$0E
        .byte   $20,$09,$13,$0A,$0B,$1A,$0B,$12
        .byte   $13,$0A,$20,$23,$12,$31,$18,$21
        .byte   $1B,$1A,$41,$4A,$20,$22,$13,$12
        .byte   $0B,$1A,$0B,$12,$20,$0B,$1A,$39
        .byte   $18,$0A,$09,$12,$13,$22,$39,$52
        .byte   $20,$2A,$13,$0A,$1B,$22,$18,$13
        .byte   $09,$0A,$41,$18,$1A,$13,$22,$49
        .byte   $4A,$20,$09,$0A,$0B,$1A,$0B,$12
        .byte   $09,$0B,$0A,$0B,$0A,$2B,$59,$18
        .byte   $22,$0B,$1A,$21,$18,$29,$3A,$28
        .byte   $0A,$1B,$2A,$2B,$79,$20,$32,$19
        .byte   $48,$42,$28,$12,$0B,$0F,$12,$13
        .byte   $0A,$11,$0B,$38,$59,$28,$22,$09
        .byte   $70,$22,$40,$2B,$70,$19,$18,$19
        .byte   $F8,$F8,$F8,$F8,$28,$00,$F8,$F8
        .byte   $28,$19,$0A,$09,$D8,$19,$78,$21
        .byte   $1A,$30,$09,$2A,$09,$68,$09,$12
        .byte   $09,$48,$11,$0D,$11,$60,$31,$1A
        .byte   $28,$09,$0A,$0D,$1A,$09,$58,$09
        .byte   $1A,$23,$48,$19,$58,$31,$22,$28
        .byte   $09,$22,$09,$50,$09,$2A,$0B,$0F
        .byte   $19,$A8,$29,$0B,$09,$0A,$0B,$1A
        .byte   $18,$09,$22,$09,$50,$09,$3A,$31
        .byte   $90,$21,$3B,$12,$18,$11,$12,$09
        .byte   $50,$09,$12,$0B,$22,$41,$70,$31
        .byte   $1B,$0F,$13,$22,$28,$19,$40,$1B
        .byte   $0A,$09,$0B,$1A,$51,$58,$41,$12
        .byte   $0B,$09,$0B,$2A,$80,$09,$0A,$23
        .byte   $12,$61,$18,$81,$3A,$11,$78,$19
        .byte   $12,$0B,$12,$61,$18,$12,$81,$2A
        .byte   $11,$80,$21,$2A,$59,$10,$09,$12
        .byte   $89,$1A,$19,$78,$29,$3A,$0B,$31
        .byte   $28,$1A,$A9,$68,$49,$1A,$0B,$12
        .byte   $0B,$29,$28,$22,$A9,$60,$49,$22
        .byte   $23,$29,$20,$09,$2A,$99,$38,$11
        .byte   $20,$41,$13,$0A,$23,$49,$52,$69
        .byte   $50,$21,$20,$0E,$39,$1B,$0F,$0B
        .byte   $51,$5A,$49,$68,$29,$20,$41,$13
        .byte   $71,$4A,$09,$18,$19,$78,$31,$18
        .byte   $39,$13,$81,$0B,$0A,$11,$22,$B0
        .byte   $79,$13,$59,$12,$19,$13,$1A,$09
        .byte   $12,$60,$19,$40,$61,$0B,$11,$0B
        .byte   $49,$22,$0B,$0A,$09,$2B,$22,$60
        .byte   $09,$12,$40,$21,$0A,$5B,$61,$0A
        .byte   $23,$1A,$23,$0C,$58,$11,$1A,$38
        .byte   $21,$1A,$13,$0A,$0B,$22,$0B,$39
        .byte   $1A,$0E,$09,$12,$13,$22,$18,$0B
        .byte   $10,$0B,$09,$38,$11,$22,$38,$29
        .byte   $1A,$0B,$1A,$0B,$0F,$13,$31,$6A
        .byte   $30,$13,$11,$28,$11,$32,$38,$21
        .byte   $4A,$13,$29,$6A,$40,$13,$28,$11
        .byte   $3A,$38,$29,$2A,$0B,$0A,$13,$39
        .byte   $62,$78,$09,$42,$38,$29,$22,$23
        .byte   $49,$3A,$09,$12,$80,$19,$32,$38
        .byte   $29,$1A,$13,$69,$22,$21,$0A,$90
        .byte   $21,$12,$48,$19,$1A,$13,$B9,$A8
        .byte   $0E,$0A,$50,$11,$1A,$13,$39,$40
        .byte   $21,$F8,$38,$09,$2A,$0B,$21,$80
        .byte   $19,$50,$1B,$A8,$09,$12,$11,$0A
        .byte   $88,$41,$40,$13,$0F,$13,$B0,$19
        .byte   $80,$49,$0C,$09,$40,$0B,$09,$0B
        .byte   $F8,$50,$29,$22,$11,$0E,$98,$11
        .byte   $12,$09,$30,$12,$98,$21,$22,$08
        .byte   $12,$90,$11,$12,$0B,$2A,$20,$1A
        .byte   $18,$0E,$09,$68,$19,$2A,$20,$12
        .byte   $70,$0B,$09,$12,$13,$12,$13,$0A
        .byte   $28,$22,$19,$68,$11,$42,$08,$1A
        .byte   $09,$50,$11,$13,$42,$1B,$28,$22
        .byte   $09,$70,$11,$2A,$11,$10,$12,$11
        .byte   $48,$19,$0B,$2A,$13,$12,$0B,$0F
        .byte   $0B,$20,$11,$22,$70,$19,$4A,$19
        .byte   $48,$19,$0B,$1A,$0B,$12,$13,$1A
        .byte   $0B,$18,$21,$32,$50,$31,$2A,$31
        .byte   $38,$0A,$19,$13,$12,$0B,$1A,$13
        .byte   $12,$0B,$18,$11,$52,$79,$1A,$41
        .byte   $28,$12,$21,$0B,$12,$0B,$32,$13
        .byte   $18,$09,$6A,$C9,$12,$08,$12,$21
        .byte   $13,$12,$2B,$12,$0B,$20,$11,$22
        .byte   $10,$12,$13,$12,$C1,$12,$10,$12
        .byte   $19,$13,$3A,$0B,$09,$12,$28,$11
        .byte   $12,$18,$0A,$09,$0F,$0B,$0A,$C9
        .byte   $12,$08,$12,$21,$0B,$12,$09,$1B
        .byte   $12,$1B,$09,$28,$19,$28,$11,$0B
        .byte   $C1,$1A,$10,$12,$21,$13,$09,$13
        .byte   $09,$13,$1A,$0B,$09,$68,$09,$1B
        .byte   $B1,$22,$08,$12,$31,$1B,$19,$13
        .byte   $0A,$1B,$68,$13,$08,$13,$69,$30
        .byte   $11,$0A,$20,$12,$61,$22,$09,$70
        .byte   $09,$0B,$10,$13,$08,$49,$60,$22
        .byte   $71,$12,$11,$70,$09,$13,$20,$49
        .byte   $58,$1A,$A1,$70,$11,$0B,$08,$59
        .byte   $60,$B9,$90,$51,$20,$13,$11,$30
        .byte   $51,$1A,$49,$70,$71,$20,$09,$13
        .byte   $21,$20,$41,$1A,$18,$09,$13,$21
        .byte   $70,$71,$18,$19,$13,$21,$20,$31
        .byte   $12,$38,$0B,$21,$70,$71,$20,$19
        .byte   $0B,$09,$1B,$09,$18,$31,$12,$38
        .byte   $0B,$0A,$21,$20,$13,$40,$61,$28
        .byte   $19,$1B,$0F,$1B,$10,$29,$1A,$11
        .byte   $18,$11,$0B,$12,$19,$20,$0B,$11
        .byte   $38,$59,$38,$31,$0B,$09,$20,$11
        .byte   $2A,$0E,$09,$1B,$09,$1A,$29,$18
        .byte   $0B,$19,$30,$51,$A0,$32,$19,$0B
        .byte   $2A,$31,$18,$0B,$09,$0E,$11,$20
        .byte   $0A,$51,$0E,$A0,$32,$1B,$09,$1A
        .byte   $39,$18,$0B,$19,$42,$61,$90,$32
        .byte   $0B,$59,$20,$13,$09,$5A,$71,$23
        .byte   $60,$81,$28,$13,$52,$79,$0B,$11
        .byte   $13,$68,$71,$30,$13,$3A,$41,$33
        .byte   $31,$23,$70,$61,$30,$13,$22,$21
        .byte   $3B,$20,$13,$09,$13,$29,$0F,$0B
        .byte   $90,$39,$50,$0A,$11,$23,$58,$1B
        .byte   $28,$11,$0B,$B8,$11,$F8,$F8,$20
        .byte   $00,$F2,$E9,$EE,$F4,$8D,$A0,$E1
        .byte   $A5
