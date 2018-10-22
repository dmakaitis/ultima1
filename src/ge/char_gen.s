;-------------------------------------------------------------------------------
;
; char_gen.s
;
;
;-------------------------------------------------------------------------------

.include "milib.inc"
.include "stlib.inc"

.export character_generation

.import clear_text_area
.import draw_border
.import main_menu

.import j92F4

selected_character  := $C4F8

        .setcpu "6502"

.segment "CODE_CHAR_GEN"

;-----------------------------------------------------------
;                    create_character
;
;-----------------------------------------------------------

character_generation:
        stx     selected_character
        jsr     st_set_text_window_full
        jsr     draw_border

        ldy     #$00
        ldx     #$08
        jsr     mi_print_text_at_x_y
        
        .byte   $0E," Character Generation ",$18,"~",$00
        
        jsr     clear_text_area



        lda     #<(player_save_data + 2)                ; Copy the new character template into the player save location in memory
        sta     @dest
        lda     #>(player_save_data + 2)
        sta     @dest + 1
        
        lda     #<(new_char_template + 2)
        sta     @source
        lda     #>(new_char_template + 2)
        sta     @source + 1

@loop:
@source         := * + 1
        lda     $FFFF
@dest           := * + 1
        sta     $FFFF

        inc     @source                                 ; Increment the source address
        bne     @inc_dest
        inc     @source + 1

@inc_dest:
        inc     @dest                                   ; Increment the destination address
        bne     @check_done
        inc     @dest + 1

@check_done:
        lda     @source                                 ; Keep going until we've copied $8a bytes
        cmp     #<(new_char_template + $8a)
        bne     @loop
        lda     @source + 1
        cmp     #>(new_char_template + $8a)
        bne     @loop



        jsr     s9359
        lda     #$1E
        sta     points_to_distribute
        ldx     #$01
        stx     w93E9
        ldy     #$0F
        jsr     mi_print_text_at_x_y
        
        .byte   " Move cursor with up and down arrows,~"
        .byte   " increase and decrease attributes~"
        .byte   " with left and right arrows.~"
        .byte   " Press RETURN when finished,~"
        .byte   " or space bar to go back to main menu.",$00

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
        inc     points_to_distribute
        bne     b9006
b9030:  cpy     #$3B
        bne     L9048
        lda     points_to_distribute
        beq     b9006
        lda     player_hits,x
        cmp     #$19
        bcs     b9006
        inc     player_hits,x
        dec     points_to_distribute
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
        ldy     points_to_distribute
        beq     b907C
        jsr     mi_play_sound_spell_and_read_input
        jmp     b9006

b907C:  sty     w93E9
        jsr     s9359
        jsr     clear_text_area
        ldy     #$12
        ldx     #$0B
        jsr     mi_print_text_at_x_y

        .byte   "a) Human|",$7F
        .byte   $0B,"b) Elf|",$7F
        .byte   $0B,"c) Dwarf|",$7F
        .byte   $0B,"d) Bobbit",$00

        ldy     #$10
        ldx     #$02
        jsr     mi_print_text_at_x_y
        
        .byte   "Select thy race: ",$00

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
        
        .byte   "Race  ",$00

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
        
        .byte   "a) Male|",$7F
        .byte   $0B,"b) Female",$00

        ldy     #$10
        ldx     #$02
        jsr     mi_print_text_at_x_y
        
        .byte   "Select thy sex: ",$00

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
        
        .byte   "Sex  ",$00

        ldx     player_sex
        jsr     mi_print_string_entry_x
        .addr   sex_table
        jsr     clear_text_area
        ldy     #$12
        ldx     #$0B
        jsr     mi_print_text_at_x_y
        
        .byte   "a) Fighter|",$7F
        .byte   $0B,"b) Cleric|",$7F
        .byte   $0B,"c) Wizard|",$7F
        .byte   $0B,"d) Thief",$00

        ldy     #$10
        ldx     #$02
        jsr     mi_print_text_at_x_y
        
        .byte   "Select thy class: ",$00

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

        .byte   "Class  ",$00

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

        .byte   "Enter thy name: ",$00
        
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
        jsr     mi_print_player_name
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



.segment "CODE_S9359"

;-----------------------------------------------------------
;                         s9359
;
;-----------------------------------------------------------

s9359:  lda     #$00
        sta     w85BE
        sta     w81C4

        ldx     #$05                                    ; Move the cursor to (5, 3)
        stx     CUR_X
        ldy     #$03
        sty     CUR_Y

        lda     w93E9
        beq     b9393

        jsr     mi_print_text
        
        .byte   "Points left to distribute: ",$00

        lda     points_to_distribute
        jsr     mi_print_short_int

b9393:  dec     CUR_X_MAX
        jsr     st_clear_to_end_of_text_row_a
        inc     CUR_X_MAX
        jsr     mi_print_crlf_col_1
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
        jsr     mi_print_short_int
        lda     #$20
        ldx     w81C4
        cpx     w93E9
        bne     b93DF
        lda     #$18
b93DF:  jsr     mi_print_char
        cpx     #$06
        bcc     b939D
        rts









.segment "DATA_CHAR_GEN"

points_to_distribute:
        .byte   $00,$00
w93E9:  .byte   $00
w93EA:  .byte   $00



sex_table:
        .byte   "mal",$E5
        .byte   "femal",$E5



new_char_template:
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
