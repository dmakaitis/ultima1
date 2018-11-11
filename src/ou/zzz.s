.include "mi.inc"
.include "st.inc"
.include "hello.inc"

r3888           := $3888
rB000           := $B000
rB001           := $B001
wBCFF           := $BCFF
wBD00           := $BD00
rBD01           := $BD01

PROCESSOR_PORT  := $01
POS_X           := $20
POS_Y           := $21
zp22            := $22
zp23            := $23
zp24            := $24
zp25            := $25
zp26            := $0026
zp27            := $0027
zp28            := $0028
zp29            := $0029
zp2C            := $002C
zp2D            := $002D
zp36            := $0036
zp37            := $0037
zp38            := $0038
zp39            := $0039
zp3A            := $003A
zp3C            := $003C
zp3D            := $003D
zp3F            := $003F
zp43            := $0043
zp44            := $0044
zp46            := $0046
zp47            := $0047
zp48            := $0048
zp49            := $0049
zp4C            := $004C
zp4D            := $004D
TMP_PTR         := $60
TMP_PTR2        := $62

.segment "ZZZ"

        lda     #$30
        sta     PROCESSOR_PORT
        ldx     #$0D
        lda     #$00
        sta     TMP_PTR
        sta     TMP_PTR2
        lda     #$D0
        sta     TMP_PTR + 1
        lda     #$B0
        sta     TMP_PTR2 + 1
        ldy     #$00
b8CB4:  lda     (TMP_PTR),y
        sta     (TMP_PTR2),y
        iny
        bne     b8CB4
        inc     TMP_PTR + 1
        inc     TMP_PTR2 + 1
        dex
        bne     b8CB4
        lda     #$36
        sta     PROCESSOR_PORT
        lda     #$C1
        sta     st_w1632
        lda     #$02
        sta     st_w1637
        lda     mi_player_position_x
        sta     POS_X
        lda     mi_player_position_y
        sta     POS_Y
        lda     #$60
        sta     BM2_ADDR_MASK
        sta     BM_ADDR_MASK
        jsr     st_copy_screen_2_to_1
        ldx     #$00
        stx     mi_command_table_override + 1
        lda     wBD00
        bne     b8CF0
        jsr     s9A10
b8CF0:  jsr     s9840
        lda     mi_player_hits
        ora     mi_player_hits + 1
        beq     b8D4E
b8CFB:  ldx     #$FF
        txs
        jsr     mi_print_text
        .byte   "|"
        .byte   $0E,$00
        jsr     s9E0B
b8D07:  jsr     mi_update_stats
        lda     mi_player_hits
        ora     mi_player_hits + 1
        beq     b8D4B
        lda     mi_player_food
        ora     mi_player_food + 1
        beq     b8D4B
        jsr     s8DD0
        bne     b8D31
        ldy     #$05
        lda     #$50
        jsr     mi_s863C
        jsr     s9A2F
        lda     CUR_X
        cmp     #$02
        bcc     b8D07
        bcs     b8CFB
b8D31:  jsr     mi_decode_and_print_command_a
        bcs     b8D45
        lda     command_routine_table,x
        sta     w8D43
        lda     command_routine_table_hi,x
        sta     w8D44
w8D43           := * + 1
w8D44           := * + 2
        jsr     mi_do_nothing
b8D45:  jsr     s9A2F
        jmp     b8CFB

b8D4B:  jsr     mi_player_died
b8D4E:  ldx     #$0A
b8D50:  jsr     st_delay_a_squared
        dex
        bpl     b8D50
        jsr     s97E0
        stx     POS_X
        sty     POS_Y
        jsr     s9A10
        lda     #$00
        ldx     mi_player_current_vehicle
        beq     b8D72
        sta     mi_player_current_vehicle
        ldy     mi_player_inventory_vehicles,x
        beq     b8D72
        dec     mi_player_inventory_vehicles,x
b8D72:  ldx     #$0F
b8D74:  sta     mi_player_inventory_weapons,x
        dex
        bne     b8D74
        sta     mi_player_equipped_armor
        sta     mi_player_equipped_weapon
        sta     mi_player_equipped_spell
        jsr     mi_print_text
        .byte   "~Attempting resurrection!"



        .byte   $00
b8DA0:  inc     mi_player_hits
        jsr     s8DC5
        lda     mi_player_hits
        cmp     #$63
        bcc     b8DA0
b8DAD:  inc     mi_player_food
        jsr     s8DC5
        lda     mi_player_food
        cmp     #$63
        bcc     b8DAD
        jsr     mi_reset_buffers
        lda     #$0A
        jsr     st_queue_sound
        jmp     b8CFB

s8DC5:  jsr     mi_update_stats
        lda     #$68
        jsr     st_delay_a_squared
        jmp     st_wait_for_raster

s8DD0:  ldx     #$80
b8DD2:  jsr     st_draw_world_and_get_input
        bne     b8DDA
        dex
        bne     b8DD2
b8DDA:  tax
        rts

cmd_pass:
        ldy     #$05
        lda     #$50
        jmp     mi_j863A

        .byte   $A9,$00,$85,$4C,$A5,$23,$4A,$66
        .byte   $4C,$4A,$66,$4C,$69,$64,$85,$4D
        .byte   $A4,$22,$60
s8DF6:  jsr     mi_print_text
        .byte   ": "
        .byte   $00
        jsr     s8DD0
        ldx     #$03
b8E01:  cmp     mi_command_decode_table,x
        bne     b8E35
        stx     zp24
        jsr     mi_print_string_entry_x2
        .addr   mi_command_table
        ldx     POS_X
        ldy     POS_Y
        stx     zp22
        sty     zp23
        ldx     #$00
        ldy     #$00
        dec     zp24
        bmi     b8E2C
        dec     zp24
        bmi     b8E2F
        dec     zp24
        bmi     b8E32
        dex
b8E26:  stx     zp24
        sty     zp25
        clc
        rts

b8E2C:  dey
        bne     b8E26
b8E2F:  iny
        bne     b8E26
b8E32:  inx
        bne     b8E26
b8E35:  dex
        bpl     b8E01
        jsr     mi_print_first_string_entry
        rol     r3888
        rts

s8E3F:  lda     zp22
        clc
        adc     zp24
        sta     zp22
        tax
        lda     zp23
        clc
        adc     zp25
        sta     zp23
        tay
        jsr     s9D50
        cmp     #$03
        beq     b8E61
        jsr     s8E62
        bcc     b8E61
        dec     wA145
        bne     s8E3F
        sec
b8E61:  rts

s8E62:  ldx     mi_player_826b
        beq     b8E97
b8E67:  dex
        lda     mi_player_826c,x
        cmp     zp22
        bne     b8E94
        lda     mi_player_82bc,x
        and     #$3F
        cmp     zp23
        bne     b8E94
        lda     mi_player_830c,x
        cmp     #$20
        bcc     b8E94
        cmp     #$5A
        bcs     b8E94
        lsr     a
        lsr     a
        adc     #$FE
        sta     mi_player_8267
        stx     zp44
        stx     mi_player_8268
        jsr     s9C79
        clc
        rts

b8E94:  txa
        bne     b8E67
b8E97:  sec
        rts

cmd_attack:
        jsr     mi_print_text
        .byte   "with "
        .byte   $00
        ldx     mi_player_equipped_weapon
        jsr     mi_print_string_entry_x2
        .addr   mi_weapon_abbr_table
        ldx     mi_player_equipped_weapon
        lda     rA131,x
        bne     b8EB5
        jmp     mi_cmd_invalid

b8EB5:  sta     wA145
        jsr     s8DF6
        bcc     b8EC9
        rts

b8EBE:  jsr     mi_print_text
        .byte   "~Miss!"
        .byte   $00
        rts

b8EC9:  lda     #$06
        jsr     st_queue_sound
        jsr     s8E3F
        bcs     b8EBE
        lda     #$5E
        sta     (zp4C),y
        jsr     st_draw_world
        jsr     s9C77
        lda     mi_player_830c,x
        sta     (zp4C),y
        lda     mi_player_agility
        clc
        adc     #$80
        sta     zp43
        jsr     st_get_random_number
        cmp     zp43
        bcc     b8EFF
        jsr     mi_print_text
        .byte   "~Missed"
        .byte   $00
        jmp     s8FE7

b8EFF:  lda     mi_player_equipped_weapon
        asl     a
        asl     a
        asl     a
        adc     mi_player_strength
        jsr     mi_get_random_number_a
        lsr     a
        clc
        adc     #$01
j8F0F:  sta     mi_w81C1
        lda     #$00
        sta     mi_number_padding
        ldx     zp44
        lda     wBD00,x
        sec
        sbc     mi_w81C1
        beq     b8F51
        bcc     b8F51
        sta     wBD00,x
        jsr     mi_print_text
        .byte   "~Hit"
        .byte   $00
        jsr     s8FE7
        lda     CUR_X
        cmp     #$15
        bcc     b8F3B
        jsr     mi_print_crlf_col_1
b8F3B:  lda     mi_w81C1
        jsr     mi_print_short_int
        jsr     mi_print_text
        .byte   " damage"
        .byte   $00
s8F4C:  lda     #$02
        jmp     st_play_sound_a

b8F51:  jsr     mi_print_text
        .byte   "~Killed"
        .byte   $00
        jsr     s8FE7
        jsr     s8F4C
        ldx     mi_player_8267
        ldy     mi_r7A51,x
        lda     r9A05,y
        lsr     a
        cmp     #$02
        bcc     b8F73
        jsr     mi_get_random_number_a
b8F73:  adc     mi_player_experience
        sta     mi_player_experience
        bcc     b8F7E
        inc     mi_player_experience + 1
b8F7E:  tya
        asl     a
        asl     a
        jsr     mi_get_random_number_a
        clc
        adc     #$0A
        pha
        tax
        lda     #$00
        jsr     mi_to_decimal_a_x
        lda     zp3C
        and     #$0F
        beq     b8FA0
        jsr     s8FD4_txt
        .byte   "copper! "
        .byte   $00
b8FA0:  lda     zp3C
        lsr     a
        lsr     a
        lsr     a
        lsr     a
        beq     b8FB4
        jsr     s8FD4_txt
        .byte   "silver! "
        .byte   $00
b8FB4:  lda     zp3D
        beq     b8FC1
        jsr     s8FD4_txt
        .byte   "gold!"
        .byte   $00
b8FC1:  pla
        clc
        adc     mi_player_money
        sta     mi_player_money
        bcc     b8FCE
        inc     mi_player_money + 1
b8FCE:  jsr     s9024
        jmp     j8FFF

s8FD4_txt:
        pha
        lda     CUR_X
        cmp     #$15
        bcc     b8FDE
        jsr     mi_print_crlf_col_1
b8FDE:  pla
        jsr     mi_print_digit
        inc     CUR_X
        jmp     mi_print_text

s8FE7:  jsr     mi_print_text
        .byte   " the "
        .byte   $00
        ldx     mi_player_8267
        jsr     mi_print_string_entry_x2
        .addr   mi_world_monster_table
        jsr     mi_print_text
        .byte   "! "
        .byte   $00
        rts

j8FFF:  ldx     mi_player_8268
        cpx     mi_player_826b
        bcs     b9022
        lda     mi_player_830c,x
        cmp     #$20
        bcc     b9022
        cmp     #$5A
        bcs     b9022
        jsr     s9CFC
        ldx     #$00
        stx     mi_player_8267
        stx     zp44
        dex
        stx     mi_player_8268
        clc
        rts

b9022:  sec
        rts

s9024:  lda     mi_player_experience
        cmp     #$10
        lda     mi_player_experience + 1
        sbc     #$27
        bcc     b903A
        lda     #$0F
        sta     mi_player_experience
        lda     #$27
        sta     mi_player_experience + 1
b903A:  lda     mi_player_money
        cmp     #$10
        lda     mi_player_money + 1
        sbc     #$27
        bcc     b9050
        lda     #$0F
        sta     mi_player_money
        lda     #$27
        sta     mi_player_money + 1
b9050:  jmp     mi_update_stats

cmd_board:
        lda     mi_player_current_vehicle
        beq     b9077
        jsr     mi_cursor_to_col_1
        jsr     mi_print_text
        .byte   "X-it thy craft first!"


        .byte   $00
        jmp     mi_play_error_sound_and_reset_buffers

b9077:  jsr     s9D77
        cmp     #$10
        bcs     b9082
        cmp     #$08
        bcs     b909D
b9082:  jsr     mi_cursor_to_col_1
        jsr     mi_print_text
        .byte   "nothing to Board!"


        .byte   $00
        jmp     mi_play_error_sound_and_reset_buffers

b909D:  and     #$07
        cmp     #$07
        bcc     b90A5
        lda     #$0A
b90A5:  sta     mi_player_current_vehicle
        pha
        jsr     s9CD8
        jsr     s9E0B
        jsr     st_draw_world
        pla
        cmp     #$03
        bcs     b90C4
        jsr     mi_cursor_to_col_1
        jsr     mi_print_text
        .byte   "Mount "
        .byte   $00
b90C4:  jsr     print_current_vehicle
        lda     mi_player_current_vehicle
        cmp     #$06
        beq     b90D1
        bcs     b90DB
        rts

b90D1:  lda     #$0F
        sta     st_w1637
        lda     #$05
L90D8:  jmp     j9262

b90DB:  lda     mi_player_81EA
        beq     b90F3
        lda     mi_player_81EB
        beq     b90F3
        lda     mi_player_81EC
        beq     b90F3
        lda     mi_player_81ED
        beq     b90F3
        lda     #$06
        bne     L90D8
b90F3:  jsr     mi_store_text_area
        jsr     st_clear_main_viewport
        jsr     st_set_text_window_main
        sta     BM2_ADDR_MASK
        jsr     mi_reduce_text_window_size
        jsr     mi_print_text
        .byte   "||||"
        .byte   $7F,$03
        .byte   "Entering the craft, thou dost|"



        .byte   $7F,$03
        .byte   "remark upon four holes marked:|"



        .byte   "|"
        .byte   $7F,$0D
        .byte   "o  o  o  o|"

        .byte   $7F,$0D
        .byte   "R  G  B  W||"

        .byte   $00
        lda     mi_player_81EA
        ora     mi_player_81EB
        ora     mi_player_81EC
        ora     mi_player_81ED
        bne     b91CB
        jsr     mi_print_text
        .byte   $7F,$02
        .byte   "Thou canst not determine how to"



        .byte   "|"
        .byte   $7F,$02
        .byte   "operate the craft at this time."



        .byte   $00
s91BB:  lda     #$60
        sta     BM2_ADDR_MASK
        jsr     st_swap_bitmaps
        jsr     mi_restore_text_area
        jsr     mi_reset_buffers_and_wait_for_input
        jmp     mi_wait_for_input

b91CB:  lda     mi_player_81EA
        beq     b91D7
        ldx     #$59
        lda     #$20
        jsr     s923D
b91D7:  lda     mi_player_81EB
        beq     b91E3
        ldx     #$71
        lda     #$50
        jsr     s923D
b91E3:  lda     mi_player_81EC
        beq     b91EF
        ldx     #$89
        lda     #$60
        jsr     s923D
b91EF:  lda     mi_player_81ED
        beq     b91FB
        ldx     #$A1
        lda     #$10
        jsr     s923D
b91FB:  jsr     mi_print_text
        .byte   $7F,$05
        .byte   "Thou hast not all the gems|"



        .byte   $7F,$04
        .byte   "needed to operate thy craft!"



        .byte   $00
        jmp     s91BB

s923D:  stx     zp46
        inx
        inx
        inx
        inx
        stx     zp47
        ldy     #$39
        sty     zp27
        jsr     st_s168B
        jsr     s924F
s924F:  jsr     s9255
        jsr     s9255
s9255:  ldx     zp46
        stx     zp26
        ldx     zp47
        inc     zp27
        ldy     zp27
        jmp     st_s1691

j9262:  ldx     POS_X
        ldy     POS_Y
        stx     mi_player_position_x
        sty     mi_player_position_y
        pha
        lda     #$30
        sta     PROCESSOR_PORT
        ldx     #$0D
        lda     #$00
        sta     TMP_PTR
        sta     TMP_PTR2
        lda     #$B0
        sta     TMP_PTR + 1
        lda     #$D0
        sta     TMP_PTR2 + 1
        ldy     #$00
b9283:  lda     (TMP_PTR),y
        sta     (TMP_PTR2),y
        iny
        bne     b9283
        inc     TMP_PTR + 1
        inc     TMP_PTR2 + 1
        dex
        bne     b9283
        lda     #$36
        sta     PROCESSOR_PORT
        pla
        jmp     mi_load_module_a

cmd_cast:
        jsr     mi_print_equipped_spell
        ldx     mi_player_equipped_spell
        bne     b92A4
        jmp     j93BA

b92A4:  lda     mi_player_inventory_spells,x
        bne     b92CB
        jsr     mi_print_text
        .byte   "~You've used up that spell!"



        .byte   $00
        jmp     mi_spell_failed

b92CB:  cpx     #$03
        beq     b92F9
        cpx     #$0A
        beq     b92F9
        dec     mi_player_inventory_spells,x
        jsr     mi_print_text
        .byte   "~Failed, dungeon spell only!"



        .byte   $00
        jmp     mi_spell_failed

b92F9:  jsr     s8DF6
        bcc     b9301
        jmp     b8CFB

b9301:  lda     #$0A
        jsr     st_queue_sound
        ldx     mi_player_equipped_spell
        dec     mi_player_inventory_spells,x
        cpx     #$0A
        ldx     #$00
        bcc     b9313
        inx
b9313:  jsr     mi_print_string_entry_x2
        .addr   r9394
        ldx     #$03
        stx     wA145
        dex
        cpx     mi_player_class
        beq     b934F
        lda     #$80
        clc
        adc     mi_player_wisdom
        sta     zp43
        jsr     st_get_random_number
        cmp     zp43
        bcc     b934F
        jsr     mi_print_text
        .byte   "Failed!"
        .byte   $00
j933D:  jsr     mi_spell_failed
        jmp     b8CFB

b9343:  jsr     mi_print_text
        .byte   "Miss!"
        .byte   $00
        jmp     j933D

b934F:  jsr     s8E3F
        bcs     b9343
        lda     #$5C
        sta     (zp4C),y
        jsr     st_draw_world
        jsr     s9C77
        lda     mi_player_830c,x
        sta     (zp4C),y
        lda     mi_player_equipped_spell
        cmp     #$03
        beq     b936F
        lda     #$FF
        jmp     j8F0F

b936F:  lda     mi_player_intelligence
        jsr     mi_get_random_number_a
        inc     zp43
        lda     zp43
        ldx     mi_player_equipped_weapon
        cpx     #$08
        bcc     b9391
        cpx     #$0C
        bcs     b9391
        asl     a
        cpx     #$09
        beq     b9391
        clc
        adc     zp43
        cpx     #$08
        bne     b9391
        lsr     a
b9391:  jmp     j8F0F

r9394:  .byte   "~"
        .byte   $22
        .byte   "DELCIO-ERE-UI!"

        .byte   $22,$A0
        .byte   "~"
        .byte   $22
        .byte   "INTERFICIO-NUNC!"

        .byte   $22,$A0
j93BA:  jsr     mi_print_text
        .byte   "~"
        .byte   $22
        .byte   "POTENTIS-LAUDIS!"

        .byte   $22,$00
        lda     #$0A
        jsr     st_queue_sound
        ldy     #$0F
        lda     mi_player_hits + 1
        bne     b93F4
        cpy     mi_player_hits
        bcc     b93F4
        beq     b93F4
        sty     mi_player_hits
b93E7:  jsr     mi_print_text
        .byte   " Shazam!"
        .byte   $00
        rts

b93F4:  lda     mi_player_food + 1
        bne     b9405
        cpy     mi_player_food
        bcc     b9405
        beq     b9405
        sty     mi_player_food
        bne     b93E7
b9405:  jsr     st_get_random_number
        and     #$03
        bne     b9427
        jsr     j8FFF
        bcs     b9427
        jsr     mi_print_text
        .byte   "~Monster removed!"


        .byte   $00
        rts

b9427:  jmp     mi_no_effect

s942A:  lda     rA143
        cmp     #$35
        bcs     b943C
        jsr     s9D50
        cmp     #$03
        bcs     b943C
        inc     rA143
        rts

b943C:  lda     #$FF
        rts

b943F:  jmp     mi_cmd_invalid

cmd_enter:
        ldx     POS_X
        ldy     POS_Y
        stx     mi_player_position_x
        sty     mi_player_position_y
        jsr     s9D77
        cmp     #$04
        bcc     b943F
        cmp     #$08
        bcs     b943F
        jsr     mi_print_text
        .byte   "ing..."
        .byte   $00
        jsr     cmd_inform_search
        lda     wA142
        cmp     #$05
        bne     b9479
        lda     mi_player_8262
        ldx     #$07
b9470:  cmp     rA119,x
        beq     b94BE
        dex
        bpl     b9470
        rts

b9479:  cmp     #$04
        bne     b9486
        lda     #$01
        sta     st_w1637
        lda     #$04
        bne     b94BB
b9486:  cmp     #$06
        bne     b94B9
        jsr     s9916
        ldx     POS_X
        ldy     POS_Y
        dey
        jsr     s942A
        sta     mi_player_8226
        iny
        dex
        jsr     s942A
        sta     mi_player_8227
        inx
        inx
        jsr     s942A
        sta     mi_player_8228
        dex
        iny
        jsr     s942A
        sta     mi_player_8229
        lda     #$01
        sta     st_w1637
        lda     #$03
        bne     b94BB
b94B9:  lda     #$02
b94BB:  jmp     j9262

b94BE:  stx     wA141
        jsr     mi_s8788
        ldx     wA141
        jsr     mi_print_string_entry_x2
        .addr   r9EEC
        jsr     mi_restore_text_area
        jsr     mi_reset_buffers
        ldx     wA141
        ldy     rA129,x
        bmi     b9503
        lda     mi_player_821E,y
        beq     b9503
        bmi     b9503
        lda     #$FF
        sta     mi_player_821E,y
        jsr     mi_print_text
        .byte   "}A Quest is completed!"


        .byte   $00
        jsr     s95B9
b9503:  ldx     wA141
        lda     rA121,x
        bne     b9568
        cpx     #$04
        bne     j955C
        cpx     mi_player_8263
        beq     b9520
        ldx     #$00
b9516:  inx
        lda     mi_player_inventory_weapons,x
        beq     b9526
        cpx     #$0F
        bcc     b9516
b9520:  jsr     mi_no_effect
        jmp     j955C

b9526:  lda     #$01
        sta     mi_player_inventory_weapons,x
        stx     zp46
        jsr     mi_print_text
        .byte   "~You find a"

        .byte   $00
        ldx     zp46
        cpx     #$03
        beq     b9546
        cpx     #$08
        bne     b954B
b9546:  lda     #$6E
        jsr     mi_print_char
b954B:  inc     CUR_X
        ldx     zp46
        jsr     mi_print_string_entry_x2
        .addr   mi_weapon_table
        lda     #$21
        jsr     mi_print_char
j9559:  jsr     s95B9
j955C:  lda     wA141
        sta     mi_player_8263
        jmp     mi_reset_buffers_and_wait_for_input

b9565:  jmp     b9520

b9568:  cpx     mi_player_8263
        beq     b9565
        sta     zp46
        asl     a
        tax
        lda     mi_player_hits,x
        sta     zp47
        sec
        lda     #$63
        sbc     mi_player_hits,x
        bcc     b9565
        adc     #$08
        jsr     mi_div_a_by_10
        adc     mi_player_hits,x
        cmp     #$63
        bcc     b958C
        lda     #$63
b958C:  sta     mi_player_hits,x
        sec
        sbc     zp47
        beq     b9565
        pha
        jsr     mi_print_text
        .byte   "}Thou dost gain "

        .byte   $00
        pla
        jsr     mi_print_digit
        inc     CUR_X
        ldx     zp46
        jsr     mi_print_string_entry_x2
        .addr   mi_attribute_table
        jmp     j9559

s95B9:  lda     #$10
        jsr     mi_s87A1
        lda     #$0A
        jsr     st_play_sound_a
        jsr     s95C9
        jsr     mi_s879F
s95C9:  lda     #$E6
        jmp     st_delay_a_squared

cmd_fire:
        ldx     mi_player_current_vehicle
        cpx     #$04
        bne     b95E3
        jsr     mi_print_text
        .byte   "cannons"
        .byte   $00
        jmp     j95FC

b95E3:  cpx     #$05
        beq     b95F2
        jsr     mi_print_text
        .byte   "what"
        .byte   $00
        jmp     mi_cmd_invalid

b95F2:  jsr     mi_print_text
        .byte   "lasers"
        .byte   $00
j95FC:  jsr     s8DF6
        bcc     b960D
        rts

b9602:  jsr     mi_print_text
        .byte   "~Miss!"
        .byte   $00
        rts

b960D:  lda     #$0C
        jsr     st_queue_sound
        lda     #$03
        sta     wA145
        jsr     s8E3F
        bcs     b9602
        lda     #$5E
        sta     (zp4C),y
        jsr     st_draw_world
        jsr     s9C77
        lda     mi_player_830c,x
        sta     (zp4C),y
        jsr     st_get_random_number
        cmp     #$33
        bcs     b9640
        jsr     mi_print_text
        .byte   "~Missed"
        .byte   $00
        jmp     s8FE7

b9640:  ldx     mi_player_current_vehicle
        lda     r9A05,x
        jsr     mi_get_random_number_a
        adc     #$1E
        jmp     j8F0F

cmd_quit_save:
        ldx     POS_X
        ldy     POS_Y
        stx     mi_player_position_x
        sty     mi_player_position_y
        jsr     mi_store_text_area
b965B:  jsr     save_selected_character
        jsr     mi_check_drive_status
        bcs     b965B
        jsr     mi_print_text
        .byte   " saved."
        .byte   $00
        jmp     st_clear_to_end_of_text_row_a

cmd_ready:
        jsr     s8DD0
        jmp     mi_get_item_to_ready

cmd_xit:lda     mi_player_current_vehicle
        bne     b9688
        jsr     mi_print_text
        .byte   " what"
        .byte   $00
        jmp     mi_cmd_invalid

b9688:  jsr     s9D77
        cmp     #$03
        bcc     b96B6
b968F:  jsr     mi_cursor_to_col_1
        jsr     mi_print_text
        .byte   "Thou canst not leave it here!"



        .byte   $00
        jmp     mi_play_error_sound_and_reset_buffers

b96B6:  ldx     POS_X
        ldy     POS_Y
        lda     mi_player_current_vehicle
        cmp     #$07
        bcc     b96C3
        lda     #$07
b96C3:  ora     #$08
        jsr     s9CA6
        bcs     b968F
        lda     #$00
        sta     mi_player_current_vehicle
        rts

get_player_position:
        ldx     POS_X
        ldy     POS_Y
        clc
        rts

cmd_north:
        jsr     get_player_position
        dey
        bcc     b96EC
cmd_south:
        jsr     get_player_position
        iny
        bcc     b96EC
cmd_east:
        jsr     get_player_position
        inx
        bcc     b96EC
cmd_west:
        jsr     get_player_position
        dex
b96EC:  jsr     mi_cursor_to_col_1
        stx     zp2C
        sty     zp2D
        lda     mi_player_current_vehicle
        cmp     #$06
        bcc     b9716
        jsr     mi_print_text
        .byte   "Can't travel on land!"


        .byte   $00
        jmp     j9752

b9716:  jsr     s9D50
        tax
        bne     b9725
        lda     mi_player_current_vehicle
        cmp     #$03
        bcs     b9795
        bcc     b974D
b9725:  ldx     #$01
        cmp     #$03
        beq     b974D
        cmp     #$10
        bcs     b9757
        inx
        cmp     #$02
        bne     b973B
        lda     mi_player_current_vehicle
        cmp     #$05
        beq     b974D
b973B:  ldx     mi_player_current_vehicle
        cpx     #$03
        beq     b9746
        cpx     #$04
        bne     b9795
b9746:  jsr     mi_print_string_entry_x
        .addr   mi_transport_table
        ldx     #$03
b974D:  jsr     mi_print_string_entry_x2
        .addr   r9E95
j9752:  lda     #$0E
        jmp     mi_play_sound_and_reset_buffers_a

b9757:  pha
        jsr     mi_print_text
        .byte   "Blocked by a"

        .byte   $00
        pla
        sec
        sbc     #$04
        lsr     a
        tax
        cpx     #$0E
        beq     b977A
        cpx     #$10
        beq     b977A
        cpx     #$13
        bne     b977F
b977A:  lda     #$6E
        jsr     mi_print_char
b977F:  inc     CUR_X
        cpx     #$14
        bne     b9788
        jsr     mi_print_crlf_col_1
b9788:  jsr     mi_print_string_entry_x2
        .addr   mi_world_monster_table
        lda     #$21
        jsr     mi_print_char
        jmp     j9752

b9795:  ldx     zp2C
        ldy     zp2D
        stx     POS_X
        sty     POS_Y
        jsr     s97F6
        ldx     mi_player_current_vehicle
        bne     b97AA
        jsr     mi_s8678
        ldx     #$00
b97AA:  ldy     r97BD,x
        lda     r97C7,x
        ldx     mi_player_current_vehicle
        cpx     #$03
        bcs     b97BA
        jmp     mi_s863C

b97BA:  jmp     mi_j863A

r97BD:  .byte   $50,$43,$36,$29,$21,$14,$07,$00
        .byte   $00,$00
r97C7:  .byte   $00,$86,$71,$57,$43,$29,$14,$00
        .byte   $00,$00,$00,$A9,$00,$85,$3F,$20
        .byte   $44,$9D,$F0,$04,$C6,$3F,$D0,$F7
        .byte   $60
s97E0:  lda     #$00
        sta     zp3F
b97E4:  jsr     s9D44
        beq     b97F1
        cmp     #$08
        bcs     b97F1
        cmp     #$03
        bne     b97F5
b97F1:  dec     zp3F
        bne     b97E4
b97F5:  rts

s97F6:  lda     POS_X
        bmi     b9800
        cmp     #$4A
        bcc     b9806
        bcs     b9815
b9800:  cmp     #$F6
        bcs     b9806
        bcc     b981E
b9806:  lda     POS_Y
        bmi     b9810
        cmp     #$4A
        bcc     b9814
        bcs     b9827
b9810:  cmp     #$F6
        bcc     b9833
b9814:  rts

b9815:  inc     mi_player_81E4
        lda     #$F6
        sta     POS_X
        bne     b983D
b981E:  dec     mi_player_81E4
        lda     #$48
        sta     POS_X
        bne     b983D
b9827:  dec     mi_player_81E4
        dec     mi_player_81E4
        lda     #$FB
        sta     POS_Y
        bne     b983D
b9833:  inc     mi_player_81E4
        inc     mi_player_81E4
        lda     #$43
        sta     POS_Y
b983D:  jsr     s9A10
s9840:  lda     mi_player_81E4
        and     #$03
        sta     mi_player_81E4
        asl     a
        tax
        lda     rB000,x
        adc     #$00
        sta     zp36
        lda     rB001,x
        adc     #$B0
        sta     zp37
        lda     #$00
        sta     zp38
        lda     #$64
        sta     zp39
        ldy     #$00
b9862:  lda     (zp36),y
        beq     b9882
        lsr     a
        lsr     a
        lsr     a
        tax
        lda     (zp36),y
        and     #$07
        asl     a
b986F:  sta     (zp38),y
        inc     zp38
        bne     b9877
        inc     zp39
b9877:  dex
        bne     b986F
        inc     zp36
        bne     b9862
        inc     zp37
        bne     b9862
b9882:  lda     mi_player_81E4
        lsr     a
        ror     a
        ror     a
        sta     mi_player_81E5
        ldx     mi_player_826b
        beq     b98AB
b9890:  dex
        lda     mi_player_82bc,x
        and     #$C0
        cmp     mi_player_81E5
        bne     b98A8
        jsr     s9C79
        lda     (zp4C),y
        sta     mi_player_835c,x
        lda     mi_player_830c,x
        sta     (zp4C),y
b98A8:  txa
        bne     b9890
b98AB:  stx     zp3F
        ldx     POS_X
        ldy     POS_Y
        dey
        lda     mi_player_8226
        jsr     s9C90
        ldx     POS_X
        ldy     POS_Y
        dex
        lda     mi_player_8227
        jsr     s9C90
        ldx     POS_X
        ldy     POS_Y
        inx
        lda     mi_player_8228
        jsr     s9C90
        ldx     POS_X
        ldy     POS_Y
        iny
        lda     mi_player_8229
        jsr     s9C90
        ldx     #$03
        lda     #$FF
b98DD:  sta     mi_player_8226,x
        dex
        bpl     b98DD
        jsr     s9916
        lda     mi_player_822A
        beq     b9910
        lda     mi_player_821D
        cmp     #$07
        bcs     b9910
b98F2:  jsr     st_get_random_number
        and     #$07
        tay
        iny
        jsr     st_get_random_number
        and     #$07
        tax
        inx
        jsr     s9D50
        cmp     #$02
        beq     b990B
        dec     zp3F
        bne     b98F2
b990B:  lda     #$0F
        jsr     s9CA6
b9910:  lda     #$00
        sta     mi_player_822A
        rts

s9916:  lda     #$00
        ldx     #$0A
b991A:  sta     mi_player_inventory_vehicles,x
        dex
        bne     b991A
        sta     rA143
        ldx     mi_player_current_vehicle
        beq     b992E
        inc     mi_player_inventory_vehicles,x
        inc     rA143
b992E:  ldy     mi_player_826b
        beq     b9950
L9933:  dey
        lda     mi_player_830c,y
        cmp     #$20
        bcs     b994D
        cmp     #$12
        bcc     b994D
        inc     rA143
        lsr     a
        cmp     #$0F
        bcc     b9949
        lda     #$12
b9949:  tax
        inc     mi_player_820B,x
b994D:  tya
        bne     L9933
b9950:  rts

s9951:  lda     mi_player_826b
        cmp     #$41
        bcs     b9987
        jsr     st_get_random_number
        cmp     #$0C
        bcc     b996A
        and     #$3F
        cmp     mi_player_experience + 1
        bcs     b9987
        and     #$07
        bne     b9987
b996A:  sta     zp36
        jsr     st_get_random_number
        and     #$07
        beq     b9987
        asl     a
        sta     zp22
b9976:  lda     #$0F
        jsr     mi_get_random_number_a
        tax
        lda     mi_r7A57,x
        cmp     zp22
        bcc     b9988
        dec     zp36
        bne     b9976
b9987:  rts

b9988:  ldy     #$00
        cpx     #$04
        bcc     b9996
        ldy     #$02
        cpx     #$09
        bcc     b9996
        ldy     #$01
b9996:  sty     zp23
        stx     mi_player_8267
        txa
        asl     a
        adc     #$10
        sta     zp22
        lda     POS_X
        sbc     #$09
        bpl     b99A9
        lda     #$00
b99A9:  sta     zp26
        lda     POS_X
        adc     #$09
        sta     zp28
        lda     POS_Y
        sbc     #$04
        bpl     b99B9
        lda     #$00
b99B9:  sta     zp27
        lda     POS_Y
        adc     #$04
        sta     zp29
b99C1:  jsr     s9D44
        cmp     zp23
        bne     b99C1
        cpx     zp26
        bcc     b99DD
        cpx     zp28
        bcs     b99DD
        cpy     zp27
        bcc     b99DD
        cpy     zp29
        bcs     b99DD
        dec     zp3A
        bne     b99C1
        rts

b99DD:  lda     zp22
        jsr     s9CA6
        bcs     b9A04
        lda     mi_player_experience + 1
        ldx     mi_player_8267
        ldy     mi_r7A57,x
        adc     r9A05,y
        lsr     a
        cmp     #$05
        bcc     b99FE
        pha
        jsr     mi_get_random_number_a
        pla
        sec
        adc     zp43
        ror     a
b99FE:  ldx     mi_player_826b
        sta     wBCFF,x
b9A04:  rts

r9A05:  .byte   $00,$0A,$14,$1E,$28,$32,$3C,$46
        .byte   $50,$5A,$64
s9A10:  ldx     mi_player_826b
        beq     b9A27
b9A15:  dex
        lda     mi_player_830c,x
        cmp     #$20
        bcc     b9A24
        cmp     #$5A
        bcs     b9A24
        jsr     s9CFC
b9A24:  txa
        bne     b9A15
b9A27:  stx     mi_player_8267
        dex
        stx     wBD00
        rts

s9A2F:  jsr     s9951
        ldx     mi_player_826b
        beq     b9A4C
b9A37:  dex
        stx     zp44
        lda     mi_player_830c,x
        cmp     #$20
        bcc     b9A48
        cmp     #$5A
        bcs     b9A48
        jsr     s9B3E
b9A48:  ldx     zp44
        bne     b9A37
b9A4C:  rts

r9A4D:  .byte   $00,$80,$AA,$00,$80,$C0,$E6,$E6
        .byte   $E6,$E6,$E6
j9A58:  jsr     st_get_random_number
        ldx     mi_player_current_vehicle
        cmp     r9A4D,x
        bcc     b9A4C
        ldx     zp44
        lda     mi_player_830c,x
        ldy     #$00
        cmp     #$30
        bcc     b9A7A
        ldy     #$01
        cmp     #$38
        beq     b9A78
        cmp     #$40
        bne     b9A7A
b9A78:  ldy     #$02
b9A7A:  sty     wA144
        lda     #$00
        sta     zp24
        sta     zp25
        lda     mi_player_826c,x
        sta     zp22
        lda     POS_X
        bmi     b9A96
        cmp     zp22
        bcc     b9A96
        beq     L9A98
        inc     zp24
        bcs     L9A98
b9A96:  dec     zp24
L9A98:  lda     mi_player_82bc,x
        and     #$3F
b9A9D:  sta     zp23
        lda     POS_Y
        bmi     b9AAD
        cmp     zp23
        bcc     b9AAD
        beq     b9AAF
        inc     zp25
        bcs     b9AAF
b9AAD:  dec     zp25
b9AAF:  jsr     st_get_random_number
        bmi     b9AB9
        jsr     s9AEE
        bcc     b9ACB
b9AB9:  ldx     zp22
        lda     zp23
        clc
        adc     zp25
        tay
        jsr     b9AF6
        bcc     b9ACB
        jsr     s9AEE
        bcs     b9AED
b9ACB:  jsr     s9C77
        lda     mi_player_835c,x
        sta     (zp4C),y
        lda     zp2C
        sta     mi_player_826c,x
        lda     zp2D
        ora     mi_player_81E5
        sta     mi_player_82bc,x
        jsr     s9C79
        lda     (zp4C),y
        sta     mi_player_835c,x
        lda     mi_player_830c,x
        sta     (zp4C),y
b9AED:  rts

s9AEE:  ldy     zp23
        lda     zp22
        clc
        adc     zp24
        tax
b9AF6:  cpx     #$40
        bcs     b9B23
        cpy     #$40
        bcs     b9B23
        cpx     POS_X
        bne     b9B06
        cpy     POS_Y
        beq     b9B23
b9B06:  jsr     s9D50
        cmp     #$08
        bcs     b9B13
        cmp     #$04
        bcc     b9B13
        lda     #$01
b9B13:  cmp     wA144
        beq     b9B25
        cmp     #$02
        bne     b9B23
        lda     wA144
        cmp     #$01
        beq     b9B25
b9B23:  sec
        rts

b9B25:  stx     zp2C
        sty     zp2D
        clc
        rts

s9B2B:  tay
        beq     b9B3D
        bmi     b9B33
        ldy     #$01
        rts

b9B33:  ldy     #$FF
        sta     w9B3C
        lda     #$00
        sec
w9B3C           := * + 1
        sbc     #$00
b9B3D:  rts

s9B3E:  ldx     zp44
        lda     mi_player_826c,x
        sta     zp22
        sec
        sbc     POS_X
        jsr     s9B2B
        sty     zp48
        sta     zp24
        lda     mi_player_82bc,x
        and     #$3F
        sta     zp23
        sec
        sbc     POS_Y
        jsr     s9B2B
        sty     zp49
        sta     zp25
        tay
        lda     zp24
        beq     b9B70
        cpy     #$00
        beq     b9B6F
        cpy     zp24
        bne     b9B8B
        iny
b9B6F           := * + 1
        cmp     #$A8
b9B70:  cpy     #$02
        bcc     b9BAF
        cpy     #$04
        bcs     b9B8B
        lda     mi_player_830c,x
        cmp     #$28
        beq     b9B8E
        cmp     #$2C
        beq     b9B8E
        cmp     #$38
        beq     b9B8E
        cmp     #$58
        beq     b9B8E
b9B8B:  jmp     j9A58

b9B8E:  lda     #$02
        sta     wA145
b9B93:  sec
        lda     zp22
        sbc     zp48
        tax
        sec
        lda     zp23
        sbc     zp49
        tay
        stx     zp22
        sty     zp23
        jsr     s9D50
        cmp     #$03
        beq     b9B8B
        dec     wA145
        bne     b9B93
b9BAF:  jsr     mi_print_tab
        ldx     zp44
        stx     mi_player_8268
        lda     mi_player_830c,x
        lsr     a
        lsr     a
        adc     #$FE
        sta     mi_player_8267
        tax
        jsr     mi_print_string_entry_x
        .addr   mi_world_monster_table
        jsr     mi_print_text
        .byte   " attacks! "

        .byte   $00
        lda     #$04
        jsr     st_queue_sound
        lda     #$5E
        sta     st_w1639
        jsr     st_draw_world
        lda     mi_player_stamina
        lsr     a
        sta     zp43
        lda     mi_player_equipped_armor
        asl     a
        asl     a
        asl     a
        adc     zp43
        sta     zp43
        sec
        lda     #$C8
        sbc     zp43
        sta     zp43
        jsr     st_get_random_number
        cmp     zp43
        bcc     b9C17
        lda     CUR_X
        cmp     #$17
        bcc     b9C09
        jsr     mi_print_crlf_col_1
b9C09:  jsr     mi_print_text
        .byte   "Missed!"
        .byte   $00
        jmp     j9C71

b9C17:  lda     CUR_X
        cmp     #$1A
        bcc     b9C20
        jsr     mi_print_crlf_col_1
b9C20:  jsr     mi_print_text
        .byte   "Hit! "
        .byte   $00
        lda     CUR_X
        cmp     #$15
        bcc     b9C32
        jsr     mi_print_crlf_col_1
b9C32:  ldx     mi_player_8267
        lda     mi_r7A51,x
        asl     a
        jsr     mi_get_random_number_a
        clc
        adc     #$01
        sta     mi_w81C1
        jsr     mi_print_short_int
        jsr     mi_print_text
        .byte   " damage"
        .byte   $00
        lda     mi_player_hits
        sec
        sbc     mi_w81C1
        sta     mi_player_hits
        lda     mi_player_hits + 1
        sbc     #$00
        bpl     b9C66
        lda     #$00
        sta     mi_player_hits
b9C66:  sta     mi_player_hits + 1
        jsr     mi_update_stats
        lda     #$02
        jsr     st_play_sound_a
j9C71:  jsr     s9E0B
        jmp     st_draw_world

s9C77:  ldx     zp44
s9C79:  lda     #$00
        sta     zp4C
        lda     mi_player_82bc,x
        and     #$3F
        lsr     a
        ror     zp4C
        lsr     a
        ror     zp4C
        adc     #$64
        sta     zp4D
        ldy     mi_player_826c,x
        rts

s9C90:  cmp     #$08
        bcc     b9CD7
        cmp     #$10
        bcc     s9CA6
        rts

        .byte   $48,$20,$D2,$97,$68,$4C,$A6,$9C
        .byte   $48,$20,$E0,$97,$68
s9CA6:  cpx     #$40
        bcs     b9CD7
        cpy     #$40
        bcs     b9CD7
        stx     zp46
        ldx     mi_player_826b
        cpx     #$50
        bcs     b9CD7
        asl     a
        sta     mi_player_830c,x
        pha
        tya
        ora     mi_player_81E5
        sta     mi_player_82bc,x
        lda     zp46
        sta     mi_player_826c,x
        jsr     s9C79
        lda     (zp4C),y
        sta     mi_player_835c,x
        pla
        sta     (zp4C),y
        inc     mi_player_826b
        clc
b9CD7:  rts

s9CD8:  ldx     POS_X
        ldy     POS_Y
        cpx     #$40
        bcs     b9CD7
        cpy     #$40
        bcs     b9CD7
        stx     zp46
        tya
        ora     mi_player_81E5
        ldx     mi_player_826b
b9CED:  dex
        bmi     b9CD7
        cmp     mi_player_82bc,x
        bne     b9CED
        ldy     mi_player_826c,x
        cpy     zp46
        bne     b9CED
s9CFC:  lda     mi_player_82bc,x
        and     #$C0
        cmp     mi_player_81E5
        bne     b9D0E
        jsr     s9C79
        lda     mi_player_835c,x
        sta     (zp4C),y
b9D0E:  lda     mi_player_830c,x
        sta     zp3A
        stx     zp46
        dec     mi_player_826b
        bne     b9D3A
        rts

b9D1B:  lda     mi_player_826d,x
        sta     mi_player_826c,x
        lda     mi_player_82bd,x
        sta     mi_player_82bc,x
        lda     mi_player_830d,x
        sta     mi_player_830c,x
        lda     mi_player_835d,x
        sta     mi_player_835c,x
        lda     rBD01,x
        sta     wBD00,x
        inx
b9D3A:  cpx     mi_player_826b
        bcc     b9D1B
        ldx     zp46
        lda     zp3A
        rts

s9D44:  jsr     st_get_random_number
        and     #$3F
        tay
        jsr     st_get_random_number
        and     #$3F
        tax
s9D50:  lda     #$00
        cpy     #$40
        bcs     b9D75
        cpx     #$40
        bcs     b9D75
        tya
        sta     w9D74
        lsr     a
        sta     zp4D
        lda     #$00
        ror     a
        lsr     zp4D
        ror     a
        sta     zp4C
        lda     zp4D
        adc     #$64
        sta     zp4D
        txa
        tay
        lda     (zp4C),y
w9D74           := * + 1
        ldy     #$00
b9D75:  lsr     a
        rts

s9D77:  ldx     POS_X
        ldy     POS_Y
        jsr     s9D50
        sta     wA142
        rts

cmd_inform_search:
        jsr     mi_print_tab
        jsr     s9D77
        cmp     #$03
        beq     b9DAD
        cmp     #$08
        bcc     b9DAF
        lda     POS_Y
        ora     mi_player_81E5
        ldx     mi_player_826b
b9D98:  cmp     mi_player_82bb,x
        bne     b9DAA
        ldy     mi_player_826b,x
        cpy     POS_X
        bne     b9DAA
        lda     mi_player_835b,x
        lsr     a
        bpl     b9DAF
b9DAA:  dex
        bne     b9D98
b9DAD:  lda     #$01
b9DAF:  sta     wA142
        cmp     #$04
        bcs     b9DCB
        tax
        jsr     mi_print_string_entry_x2
        .addr   r9E5B_str
        ldx     wA142
        dex
        bne     b9DCA
        ldx     mi_player_81E4
        jsr     mi_print_string_entry_x2
        .addr   mi_land_name_table
b9DCA:  rts

b9DCB:  cmp     #$06
        bne     b9DDF
        jsr     mi_print_text
        .byte   "the city of "

        .byte   $00
b9DDF:  lda     mi_player_81E5
        ora     POS_Y
        ldx     #$53
b9DE6:  cmp     mi_r7C18,x
        bne     b9DF2
        ldy     mi_r7C6C,x
        cpy     POS_X
        beq     b9DF9
b9DF2:  dex
        bpl     b9DE6
        stx     mi_player_8262
        rts

b9DF9:  stx     mi_player_8262
        jsr     mi_print_string_entry_x2
        .addr   mi_world_feature_table
        rts

print_current_vehicle:
        ldx     mi_player_current_vehicle
        jsr     mi_print_string_entry_x2
        .addr   mi_transport_table
        rts

s9E0B:  lda     mi_player_current_vehicle
        cmp     #$0B
        bcc     b9E17
        lda     #$00
        sta     mi_player_current_vehicle
b9E17:  cmp     #$07
        bcc     b9E22
        lda     #$0A
        sta     mi_player_current_vehicle
        lda     #$07
b9E22:  ora     #$08
        asl     a
        sta     st_w1639
        rts

command_routine_table:
command_routine_table_hi:= * + 1
        .addr   cmd_north
        .addr   cmd_south
        .addr   cmd_east
        .addr   cmd_west
        .addr   cmd_pass
        .addr   cmd_attack
        .addr   cmd_board
        .addr   cmd_cast
        .addr   mi_cmd_invalid
        .addr   cmd_enter
        .addr   cmd_fire
        .addr   mi_cmd_invalid
        .addr   mi_cmd_invalid
        .addr   cmd_inform_search
        .addr   mi_cmd_invalid
        .addr   mi_cmd_noise
        .addr   mi_cmd_invalid
        .addr   cmd_quit_save
        .addr   cmd_ready
        .addr   mi_cmd_invalid
        .addr   mi_cmd_invalid
        .addr   mi_cmd_invalid
        .addr   mi_cmd_invalid
        .addr   cmd_xit
        .addr   mi_cmd_ztats
r9E5B_str:
        .byte   "You are at se"

        .byte   $E1
        .byte   "You are in the lands~of"


        .byte   $A0
        .byte   "You are in the wood"


        .byte   $F3
r9E95:  .byte   "You can't walk on water"


        .byte   $A1
        .byte   "Mountains are impassable"


        .byte   $A1
        .byte   "Aircars can't pass woods"


        .byte   $A1
        .byte   "s like water"

        .byte   $A1
r9EEC:  .byte   $7E,$7E,$7E,$7F,$07,$54,$68,$65
        .byte   $20,$73,$69,$67,$6E,$20,$72,$65
        .byte   $61,$64,$73,$3A,$7E,$7E,$7F,$04
        .byte   $22,$47,$4F,$20,$45,$41,$53,$54
        .byte   $20,$54,$4F,$20,$47,$4F,$20,$45
        .byte   $41,$53,$54,$21,$A2,$7E,$7E,$7E
        .byte   $7F,$05,$54,$68,$65,$20,$67,$72
        .byte   $61,$76,$65,$20,$69,$73,$20,$6D
        .byte   $61,$72,$6B,$65,$64,$3A,$7E,$7E
        .byte   $7F,$09,$22,$56,$41,$45,$20,$56
        .byte   $49,$43,$54,$49,$53,$A2,$7E,$7E
        .byte   $7E,$7F,$07,$54,$68,$65,$20,$73
        .byte   $69,$67,$6E,$20,$72,$65,$61,$64
        .byte   $73,$3A,$7E,$7E,$7F,$06,$22,$4F
        .byte   $4D,$4E,$49,$41,$20,$4D,$55,$54
        .byte   $41,$4E,$54,$55,$52,$21,$A2,$7E
        .byte   $7E,$7F,$07,$54,$68,$65,$20,$73
        .byte   $69,$67,$6E,$20,$72,$65,$61,$64
        .byte   $73,$3A,$7E,$7E,$7F,$07,$22,$55
        .byte   $4C,$54,$49,$4D,$41,$20,$54,$48
        .byte   $55,$4C,$45,$21,$22,$7E,$7E,$7F
        .byte   $02,$54,$68,$65,$20,$73,$6B,$79
        .byte   $20,$67,$72,$6F,$77,$73,$20,$64
        .byte   $61,$72,$6B,$2C,$20,$61,$6E,$64
        .byte   $20,$61,$7E,$7F,$02,$73,$74,$72
        .byte   $6F,$6E,$67,$20,$6D,$61,$67,$69
        .byte   $63,$20,$65,$6E,$67,$75,$6C,$66
        .byte   $73,$20,$79,$6F,$75,$A1,$7E,$7E
        .byte   $7E,$7F,$08,$41,$20,$73,$69,$67
        .byte   $6E,$20,$72,$65,$61,$64,$73,$3A
        .byte   $7E,$7E,$7F,$02,$22,$46,$4F,$52
        .byte   $54,$45,$53,$20,$46,$4F,$52,$54
        .byte   $55,$4E,$41,$20,$41,$44,$49,$55
        .byte   $56,$41,$54,$21,$A2,$7F,$08,$4F
        .byte   $6E,$20,$61,$20,$70,$65,$64,$65
        .byte   $73,$74,$61,$6C,$2C,$7E,$7F,$05
        .byte   $74,$68,$65,$73,$65,$20,$77,$6F
        .byte   $72,$64,$73,$20,$61,$70,$70,$65
        .byte   $61,$72,$3A,$7E,$7E,$7F,$03,$22
        .byte   $4D,$59,$20,$4E,$41,$4D,$45,$20
        .byte   $49,$53,$20,$4F,$5A,$59,$4D,$41
        .byte   $4E,$44,$49,$41,$53,$2C,$7E,$7F
        .byte   $08,$4B,$49,$4E,$47,$20,$4F,$46
        .byte   $20,$4B,$49,$4E,$47,$53,$3A,$7E
        .byte   $7F,$06,$4C,$4F,$4F,$4B,$20,$4F
        .byte   $4E,$20,$4D,$59,$20,$57,$4F,$52
        .byte   $4B,$53,$2C,$7E,$7F,$03,$59,$45
        .byte   $20,$4D,$49,$47,$48,$54,$59,$2C
        .byte   $20,$41,$4E,$44,$20,$44,$45,$53
        .byte   $50,$41,$49,$52,$21,$22,$7E,$7E
        .byte   $7F,$03,$4E,$6F,$74,$68,$69,$6E
        .byte   $67,$20,$62,$65,$73,$69,$64,$65
        .byte   $20,$72,$65,$6D,$61,$69,$6E,$73
        .byte   $2E,$7E,$7F,$02,$59,$6F,$75,$20
        .byte   $66,$65,$65,$6C,$20,$61,$20,$73
        .byte   $74,$72,$61,$6E,$67,$65,$20,$66
        .byte   $6F,$72,$63,$65,$A1,$7E,$7E,$7E
        .byte   $7E,$7F,$03,$59,$6F,$75,$20,$66
        .byte   $65,$65,$6C,$20,$61,$20,$73,$74
        .byte   $72,$6F,$6E,$67,$20,$6D,$61,$67
        .byte   $69,$63,$7E,$7F,$07,$73,$75,$72
        .byte   $72,$6F,$75,$6E,$64,$69,$6E,$67
        .byte   $20,$79,$6F,$75,$A1,$7E,$7E,$7E
        .byte   $7F,$04,$59,$6F,$75,$20,$68,$65
        .byte   $61,$72,$20,$73,$6F,$6D,$65,$6F
        .byte   $6E,$65,$20,$73,$61,$79,$2C,$7E
        .byte   $7E,$20,$22,$54,$55,$52,$52,$49
        .byte   $53,$2D,$53,$43,$49,$45,$4E,$54
        .byte   $49,$41,$2D,$4D,$41,$47,$4E,$4F
        .byte   $50,$45,$52,$45,$A2
rA119:  .byte   $42,$41,$2D,$2C,$18,$17,$03,$02
rA121:  .byte   $00,$03,$04,$03,$00,$05,$02,$06
rA129:  .byte   $FF,$06,$FF,$04,$FF,$02,$FF,$00
rA131:  .byte   $01,$01,$01,$01,$00,$01,$01,$03
        .byte   $00,$00,$00,$01,$03,$01,$03,$03
wA141:  .byte   $00
wA142:  .byte   $00
rA143:  .byte   $DE
wA144:  .byte   $02
wA145:  .byte   $4E,$06,$AB,$09,$19
