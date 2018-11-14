.include "mi.inc"
.include "st.inc"
.include "hello.inc"

.export cmd_attack
.export cmd_board
.export cmd_cast
.export cmd_east
.export cmd_enter
.export cmd_fire
.export cmd_inform_search
.export cmd_north
.export cmd_pass
.export cmd_quit_save
.export cmd_ready
.export cmd_south
.export cmd_west
.export cmd_xit

.import command_routine_table
.import tile_descriptions
.import blocked_messages
.import r9EEC
.import rA119
.import rA121
.import rA129
.import rA131
.import rA143
.import wA141
.import wA142
.import wA144
.import wA145

r3888                   := $3888
continent_map           := $6400
continent_addresses     := $B000
wBD00                   := $BD00

PROCESSOR_PORT          := $01
POS_X                   := $20
POS_Y                   := $21
zp22                    := $22
zp23                    := $23
zp24                    := $24
zp25                    := $25
zp26                    := $26
zp27                    := $27
zp28                    := $28
zp29                    := $29
zp2C                    := $2C
zp2D                    := $2D
zp36                    := $36
zp37                    := $37
zp38                    := $38
zp39                    := $39
zp3A                    := $3A
zp3C                    := $3C
zp3D                    := $3D
zp3F                    := $3F
zp43                    := $43
zp44                    := $44
zp46                    := $46
zp47                    := $47
zp48                    := $48
zp49                    := $49
zp4C                    := $4C
zp4D                    := $4D
TMP_PTR                 := $60
TMP_PTR2                := $62

.segment "ZZZ"

;-----------------------------------------------------------
;-----------------------------------------------------------

ou_main:
        lda     #$30                                    ; Expose all RAM
        sta     PROCESSOR_PORT

        ldx     #$0D                                    ; Copy 3328 bytes from $D000-$DCFF to $B000-$BCFF
        lda     #$00
        sta     TMP_PTR
        sta     TMP_PTR2
        lda     #$D0
        sta     TMP_PTR + 1
        lda     #$B0
        sta     TMP_PTR2 + 1
        ldy     #$00

@loop_copy:
        lda     (TMP_PTR),y
        sta     (TMP_PTR2),y
        iny
        bne     @loop_copy
        inc     TMP_PTR + 1
        inc     TMP_PTR2 + 1
        dex
        bne     @loop_copy

        lda     #$36                                    ; Enable I/O and KERNAL areas
        sta     PROCESSOR_PORT


        lda     #$C1                                    ; Configure input options (fire = 'A')
        sta     st_joystick_fire_key_equiv
        lda     #$02
        sta     st_key_repeat_rate_10ths

        lda     mi_player_position_x                    ; Copy player location into zero-page variables
        sta     POS_X
        lda     mi_player_position_y
        sta     POS_Y

        lda     #$60                                    ; Set up screen swapping
        sta     BM2_ADDR_MASK
        sta     BM_ADDR_MASK
        jsr     st_copy_screen_2_to_1

        ldx     #$00                                    ; Use the default command table
        stx     mi_command_table_override + 1

        lda     wBD00
        bne     b8CF0
        jsr     s9A10
b8CF0:  jsr     decompress_continent_map

        lda     mi_player_hits                          ; If the player has no hit points...
        ora     mi_player_hits + 1
        beq     no_hits                                 ; ...then they are dead



main_loop:
        ldx     #$FF                                    ; Reset stack
        txs

        jsr     mi_print_text                           ; Prompt for input
        .byte   "|",$0E,$00

        jsr     set_avatar_vehicle_tile                 ; Make sure correct vehicle is displayed for the player

b8D07:  jsr     mi_update_stats                         ; Update the display with player stats

        lda     mi_player_hits                          ; If the player has no hit points...
        ora     mi_player_hits + 1
        beq     no_food_or_hits
        lda     mi_player_food                          ; ...or food...
        ora     mi_player_food + 1
        beq     no_food_or_hits                         ; ...then they are dead

        jsr     s8DD0
        bne     b8D31
        ldy     #$05
        lda     #$50
        jsr     mi_s863C
        jsr     s9A2F
        lda     CUR_X
        cmp     #$02
        bcc     b8D07
        bcs     main_loop


b8D31:  jsr     mi_decode_and_print_command_a
        bcs     b8D45
        lda     command_routine_table,x
        sta     w8D43
        lda     command_routine_table + 1,x
        sta     w8D44
w8D43           := * + 1
w8D44           := * + 2
        jsr     mi_do_nothing
b8D45:  jsr     s9A2F
        jmp     main_loop


no_food_or_hits:
        jsr     mi_player_died                          ; Inform the player they are dead

no_hits:
        ldx     #$0A                                    ; Delay for a time period
@delay: jsr     st_delay_a_squared
        dex
        bpl     @delay

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
        .asciiz "~Attempting resurrection!"
b8DA0:  inc     mi_player_hits
        jsr     update_stats_and_delay
        lda     mi_player_hits
        cmp     #$63
        bcc     b8DA0
b8DAD:  inc     mi_player_food
        jsr     update_stats_and_delay
        lda     mi_player_food
        cmp     #$63
        bcc     b8DAD
        jsr     mi_reset_buffers
        lda     #$0A
        jsr     st_queue_sound
        jmp     main_loop



;-----------------------------------------------------------
;                  update_stats_and_delay
;
; Updates the screen with player stats, then delays for a
; fixed time period.
;
; Input:
;
; Output:
;-----------------------------------------------------------

update_stats_and_delay:
        jsr     mi_update_stats
        lda     #$68
        jsr     st_delay_a_squared
        jmp     st_wait_for_raster



;-----------------------------------------------------------
;-----------------------------------------------------------

s8DD0:  ldx     #$80
b8DD2:  jsr     st_draw_world_and_get_input
        bne     b8DDA
        dex
        bne     b8DD2
b8DDA:  tax
        rts



;-----------------------------------------------------------
;-----------------------------------------------------------

cmd_pass:
        ldy     #$05
        lda     #$50
        jmp     mi_j863A

        .byte   $A9,$00,$85,$4C,$A5,$23,$4A,$66
        .byte   $4C,$4A,$66,$4C,$69,$64,$85,$4D
        .byte   $A4,$22,$60



;-----------------------------------------------------------
;-----------------------------------------------------------

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



;-----------------------------------------------------------
;-----------------------------------------------------------

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
        jsr     get_tile
        cmp     #$03
        beq     b8E61
        jsr     s8E62
        bcc     b8E61
        dec     wA145
        bne     s8E3F
        sec
b8E61:  rts



;-----------------------------------------------------------
;-----------------------------------------------------------

s8E62:  ldx     mi_player_vehicle_count
        beq     b8E97
b8E67:  dex
        lda     mi_player_vehicle_x_coords,x
        cmp     zp22
        bne     b8E94
        lda     mi_player_vehicle_continent_y_coords,x
        and     #$3F
        cmp     zp23
        bne     b8E94
        lda     mi_player_vehicle_types,x
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
        jsr     get_vehicle_location_in_memory
        clc
        rts

b8E94:  txa
        bne     b8E67
b8E97:  sec
        rts



;-----------------------------------------------------------
;-----------------------------------------------------------

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
        lda     mi_player_vehicle_types,x
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



;-----------------------------------------------------------
;-----------------------------------------------------------

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



;-----------------------------------------------------------
;-----------------------------------------------------------

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
        cpx     mi_player_vehicle_count
        bcs     b9022
        lda     mi_player_vehicle_types,x
        cmp     #$20
        bcc     b9022
        cmp     #$5A
        bcs     b9022
        jsr     remove_player_vehicle_x
        ldx     #$00
        stx     mi_player_8267
        stx     zp44
        dex
        stx     mi_player_8268
        clc
        rts

b9022:  sec
        rts



;-----------------------------------------------------------
;-----------------------------------------------------------

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



;-----------------------------------------------------------
;                        cmd_board
;
; Command handler for when the player wishes to board a
; vehicle.
;
; Input:
;
; Output:
;-----------------------------------------------------------

cmd_board:
        lda     mi_player_current_vehicle               ; If the player is already in a vehicle...
        beq     @not_in_vehicle
        jsr     mi_cursor_to_col_1                      ; ...then they have to get out first.
        jsr     mi_print_text
        .asciiz "X-it thy craft first!"
        jmp     mi_play_error_sound_and_reset_buffers

@not_in_vehicle:
        jsr     get_player_position_and_tile            ; Get the tile under the player

        cmp     #$10                                    ; If there is no vehicle currently at the player location...
        bcs     @no_vehicle_found
        cmp     #$08
        bcs     b909D
@no_vehicle_found:
        jsr     mi_cursor_to_col_1                      ; ...then there is nothing for them to board here
        jsr     mi_print_text
        .asciiz "nothing to Board!"
        jmp     mi_play_error_sound_and_reset_buffers



b909D:  and     #$07                                    ; If the tile is a time machine...
        cmp     #$07
        bcc     b90A5

        lda     #$0A                                    ; ...then override the vehicle to be a time machine
b90A5:  sta     mi_player_current_vehicle
        pha

        jsr     remove_vehicle_at_player_location       ; Remove the vehicle from the world map

        jsr     set_avatar_vehicle_tile
        jsr     st_draw_world
        pla
        cmp     #$03
        bcs     b90C4
        jsr     mi_cursor_to_col_1
        jsr     mi_print_text
        .asciiz "Mount "
b90C4:  jsr     print_current_vehicle
        lda     mi_player_current_vehicle
        cmp     #$06
        beq     b90D1
        bcs     b90DB
        rts

b90D1:  lda     #$0F
        sta     st_key_repeat_rate_10ths
        lda     #$05
b90D8:  jmp     j9262

b90DB:  lda     mi_player_gems
        beq     b90F3
        lda     mi_player_gems + 1
        beq     b90F3
        lda     mi_player_gems + 2
        beq     b90F3
        lda     mi_player_gems + 3
        beq     b90F3
        lda     #$06
        bne     b90D8
b90F3:  jsr     mi_store_text_area
        jsr     st_clear_main_viewport
        jsr     st_set_text_window_main
        sta     BM2_ADDR_MASK
        jsr     mi_reduce_text_window_size
        jsr     mi_print_text
        .byte   "||||",$7F
        .byte   $03,"Entering the craft, thou dost|",$7F
        .byte   $03,"remark upon four holes marked:||",$7F
        .byte   $0D,"o  o  o  o|",$7F
        .byte   $0D,"R  G  B  W||",$00

        lda     mi_player_gems
        ora     mi_player_gems + 1
        ora     mi_player_gems + 2
        ora     mi_player_gems + 3
        bne     b91CB
        jsr     mi_print_text
        .byte   $7F
        .byte   $02,"Thou canst not determine how to|",$7F
        .byte   $02,"operate the craft at this time.",$00



;-----------------------------------------------------------
;-----------------------------------------------------------

s91BB:  lda     #$60
        sta     BM2_ADDR_MASK
        jsr     st_swap_bitmaps
        jsr     mi_restore_text_area
        jsr     mi_reset_buffers_and_wait_for_input
        jmp     mi_wait_for_input

b91CB:  lda     mi_player_gems
        beq     b91D7
        ldx     #$59
        lda     #$20
        jsr     s923D
b91D7:  lda     mi_player_gems + 1
        beq     b91E3
        ldx     #$71
        lda     #$50
        jsr     s923D
b91E3:  lda     mi_player_gems + 2
        beq     b91EF
        ldx     #$89
        lda     #$60
        jsr     s923D
b91EF:  lda     mi_player_gems + 3
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



;-----------------------------------------------------------
;-----------------------------------------------------------

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



;-----------------------------------------------------------
;-----------------------------------------------------------

s924F:  jsr     s9255
        jsr     s9255



;-----------------------------------------------------------
;-----------------------------------------------------------

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



;-----------------------------------------------------------
;-----------------------------------------------------------

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
        jmp     main_loop

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
        jmp     main_loop

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
        lda     mi_player_vehicle_types,x
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



;-----------------------------------------------------------
;-----------------------------------------------------------

s942A:  lda     rA143
        cmp     #$35
        bcs     b943C
        jsr     get_tile
        cmp     #$03
        bcs     b943C
        inc     rA143
        rts

b943C:  lda     #$FF
        rts

b943F:  jmp     mi_cmd_invalid



;-----------------------------------------------------------
;-----------------------------------------------------------

cmd_enter:
        ldx     POS_X
        ldy     POS_Y
        stx     mi_player_position_x
        sty     mi_player_position_y
        jsr     get_player_position_and_tile
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
        sta     st_key_repeat_rate_10ths
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
        sta     st_key_repeat_rate_10ths
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
        .asciiz "}A Quest is completed!"
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



;-----------------------------------------------------------
;-----------------------------------------------------------

s95B9:  lda     #$10
        jsr     mi_s87A1
        lda     #$0A
        jsr     st_play_sound_a
        jsr     s95C9
        jsr     mi_s879F



;-----------------------------------------------------------
;-----------------------------------------------------------

s95C9:  lda     #$E6
        jmp     st_delay_a_squared



;-----------------------------------------------------------
;-----------------------------------------------------------

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
        lda     mi_player_vehicle_types,x
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



;-----------------------------------------------------------
;-----------------------------------------------------------

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



;-----------------------------------------------------------
;-----------------------------------------------------------

cmd_ready:
        jsr     s8DD0
        jmp     mi_get_item_to_ready



;-----------------------------------------------------------
;-----------------------------------------------------------

cmd_xit:lda     mi_player_current_vehicle
        bne     b9688
        jsr     mi_print_text
        .byte   " what"
        .byte   $00
        jmp     mi_cmd_invalid

b9688:  jsr     get_player_position_and_tile
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



;-----------------------------------------------------------
;                    get_player_position
;
; Retrieves the players current location on the current
; continent.
;
;
; Input:
;
; Output:
;       x - player X coordinate
;       y - player Y coordinate
;-----------------------------------------------------------

get_player_position:
        ldx     POS_X
        ldy     POS_Y
        clc
        rts



;-----------------------------------------------------------
;                         cmd_north
;
; Command handler for when the player wishes to move north.
;
; Input:
;
; Output:
;-----------------------------------------------------------

cmd_north:
        jsr     get_player_position                     ; Read the players current location

        dey                                             ; Update coordinate to one space to the north

        bcc     b96EC



;-----------------------------------------------------------
;                         cmd_south
;
; Command handler for when the player wishes to move south.
;
; Input:
;
; Output:
;-----------------------------------------------------------

cmd_south:
        jsr     get_player_position                     ; Read the players current location

        iny                                             ; Update coordinate to one space to the south

        bcc     b96EC



;-----------------------------------------------------------
;                         cmd_east
;
; Command handler for when the player wishes to move east.
;
; Input:
;
; Output:
;-----------------------------------------------------------

cmd_east:
        jsr     get_player_position                     ; Read the players current location

        inx                                             ; Update coordinate to one space to the east

        bcc     b96EC



;-----------------------------------------------------------
;                         cmd_west
;
; Command handler for when the player wishes to move west.
;
; Input:
;
; Output:
;-----------------------------------------------------------

cmd_west:
        jsr     get_player_position                     ; Read the players current location

        dex                                             ; Update coordinate to one space to the west

b96EC:  jsr     mi_cursor_to_col_1                      ; Move the cursor to column 1

        stx     zp2C                                    ; Store where we want to move to in temporary locations
        sty     zp2D

        lda     mi_player_current_vehicle               ; If the current vehicle is a shuttle or time machine...
        cmp     #$06
        bcc     @not_space_ship

        jsr     mi_print_text                           ; ...then the player can not move
        .asciiz "Can't travel on land!"

        jmp     @play_blocked_sound

@not_space_ship:
        jsr     get_tile                                ; Get the tile at the target location

        tax
        bne     @not_water                                   

        lda     mi_player_current_vehicle               ; Is the player in a vehicle that than move over water?
        cmp     #$03
        bcs     @move_player
        bcc     @blocked


@not_water:
        ldx     #$01
        cmp     #$03                                    ; If the target tile is mountains...
        beq     @blocked                                ; ...then the player is blocked

        cmp     #$10                                    ; If the target tile has a monster...
        bcs     @monster                                ; ...then the player is blocked

        inx                                             ; If the target tile is forest...
        cmp     #$02
        bne     @not_forest
        lda     mi_player_current_vehicle               ; ...and the vehicle is an air car...
        cmp     #$05
        beq     @blocked                                ; ...then the player is blocked

@not_forest:
        ldx     mi_player_current_vehicle               ; If the vehicle is a raft...
        cpx     #$03
        beq     @raft_or_frigate
        cpx     #$04                                    ; ...or a frigate...
        bne     @move_player
@raft_or_frigate:
        jsr     mi_print_string_entry_x                 ; ...then they can not move on land
        .addr   mi_transport_table
        ldx     #$03
@blocked:
        jsr     mi_print_string_entry_x2                ; Tell the player why they can not go there
        .addr   blocked_messages
@play_blocked_sound:
        lda     #$0E
        jmp     mi_play_sound_and_reset_buffers_a

@monster:
        pha                                             ; Tell the player what is in the way...
        jsr     mi_print_text
        .asciiz "Blocked by a"
        pla

        sec                                             ; x := (tile - 4) / 2
        sbc     #$04
        lsr     a
        tax

        cpx     #$0E                                    ; If the tile is an evil trent...
        beq     @print_n
        cpx     #$10                                    ; ...an orc...
        beq     @print_n
        cpx     #$13                                    ; ...or an evil ranger...
        bne     @no_n
@print_n:
        lda     #'n'                                    ; ...print an 'n'
        jsr     mi_print_char

@no_n:  inc     CUR_X                                   ; Advance the cursor

        cpx     #$14                                    ; If the cursor is too far to the right...
        bne     @print_monster_name
        jsr     mi_print_crlf_col_1                     ; ...then advance to the next line

@print_monster_name:
        jsr     mi_print_string_entry_x2                ; Print the monster name
        .addr   mi_world_monster_table

        lda     #'!'
        jsr     mi_print_char
        jmp     @play_blocked_sound



@move_player:
        ldx     zp2C                                    ; Update the player location with the new coordinates
        ldy     zp2D
        stx     POS_X
        sty     POS_Y

        jsr     s97F6
        ldx     mi_player_current_vehicle
        bne     b97AA
        jsr     mi_increase_high_bytes
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



;-----------------------------------------------------------
;-----------------------------------------------------------

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



;-----------------------------------------------------------
;-----------------------------------------------------------

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

b9815:  inc     mi_player_continent
        lda     #$F6
        sta     POS_X
        bne     b983D
b981E:  dec     mi_player_continent
        lda     #$48
        sta     POS_X
        bne     b983D
b9827:  dec     mi_player_continent
        dec     mi_player_continent
        lda     #$FB
        sta     POS_Y
        bne     b983D
b9833:  inc     mi_player_continent
        inc     mi_player_continent
        lda     #$43
        sta     POS_Y
b983D:  jsr     s9A10



;-----------------------------------------------------------
;-----------------------------------------------------------

decompress_continent_map:
        lda     mi_player_continent                     ; Make sure mi_player_continent is in the range 0-3
        and     #$03
        sta     mi_player_continent

        asl     a                                       ; x := mi_player_continent * 2
        tax

        lda     continent_addresses,x                   ; source (zp36) := continent_addresses + word at (continent_addresses + x)
        adc     #<continent_addresses
        sta     zp36
        lda     continent_addresses + 1,x
        adc     #>continent_addresses
        sta     zp37

        lda     #$00                                    ; target (zp38) := $6400
        sta     zp38
        lda     #$64
        sta     zp39

        ldy     #$00
@copy_loop:
        lda     (zp36),y                                ; If the current source byte is zero...
        beq     @done_decompressing                     ; ...then we are done

        lsr     a                                       ; x := source / 8 (top five bits)
        lsr     a
        lsr     a
        tax
        
        lda     (zp36),y                                ; a : = 2 * (source % 8) (bottom three bits)
        and     #$07
        asl     a

@write_next_byte:
        sta     (zp38),y                                ; *zp38++ := a
        inc     zp38
        bne     @next_x
        inc     zp39

@next_x:
        dex                                             ; Write out x bytes
        bne     @write_next_byte

        inc     zp36                                    ; Advance source pointer
        bne     @copy_loop
        inc     zp37
        bne     @copy_loop


@done_decompressing:
        lda     mi_player_continent                     ; mi_player_continent_mask := mi_player_continent * 64
        lsr     a
        ror     a
        ror     a
        sta     mi_player_continent_mask

        ldx     mi_player_vehicle_count                 ; If the player has vehicles...
        beq     b98AB

@next_vehicle:
        dex                                             ; ...place them on the map

        lda     mi_player_vehicle_continent_y_coords,x  ; If the vehicle is not on the current continent...
        and     #$C0
        cmp     mi_player_continent_mask
        bne     @wrong_continent                        ; ...skip it
        
        jsr     get_vehicle_location_in_memory

        lda     (zp4C),y                                ; Copy the tile in the location into the character data
        sta     mi_player_vehicle_tiles,x

        lda     mi_player_vehicle_types,x               ; Place the vehicle on the map
        sta     (zp4C),y

@wrong_continent:
        txa
        bne     @next_vehicle

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
        lda     mi_player_inventory_vehicles + 10
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
        jsr     get_tile
        cmp     #$02
        beq     b990B
        dec     zp3F
        bne     b98F2
b990B:  lda     #$0F
        jsr     s9CA6
b9910:  lda     #$00
        sta     mi_player_822A
        rts



;-----------------------------------------------------------
;-----------------------------------------------------------

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
b992E:  ldy     mi_player_vehicle_count
        beq     b9950
b9933:  dey
        lda     mi_player_vehicle_types,y
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
        inc     mi_player_inventory_vehicles - 8,x
b994D:  tya
        bne     b9933
b9950:  rts



;-----------------------------------------------------------
;-----------------------------------------------------------

s9951:  lda     mi_player_vehicle_count
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
b99FE:  ldx     mi_player_vehicle_count
        sta     wBD00 - 1,x
b9A04:  rts

r9A05:  .byte   $00,$0A,$14,$1E,$28,$32,$3C,$46
        .byte   $50,$5A,$64



;-----------------------------------------------------------
;-----------------------------------------------------------

s9A10:  ldx     mi_player_vehicle_count
        beq     b9A27
b9A15:  dex
        lda     mi_player_vehicle_types,x
        cmp     #$20
        bcc     b9A24
        cmp     #$5A
        bcs     b9A24
        jsr     remove_player_vehicle_x
b9A24:  txa
        bne     b9A15
b9A27:  stx     mi_player_8267
        dex
        stx     wBD00
        rts



;-----------------------------------------------------------
;-----------------------------------------------------------

s9A2F:  jsr     s9951
        ldx     mi_player_vehicle_count
        beq     b9A4C
b9A37:  dex
        stx     zp44
        lda     mi_player_vehicle_types,x
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
        lda     mi_player_vehicle_types,x
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
        lda     mi_player_vehicle_x_coords,x
        sta     zp22
        lda     POS_X
        bmi     b9A96
        cmp     zp22
        bcc     b9A96
        beq     b9A98
        inc     zp24
        bcs     b9A98
b9A96:  dec     zp24
b9A98:  lda     mi_player_vehicle_continent_y_coords,x
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
        lda     mi_player_vehicle_tiles,x
        sta     (zp4C),y
        lda     zp2C
        sta     mi_player_vehicle_x_coords,x
        lda     zp2D
        ora     mi_player_continent_mask
        sta     mi_player_vehicle_continent_y_coords,x
        jsr     get_vehicle_location_in_memory
        lda     (zp4C),y
        sta     mi_player_vehicle_tiles,x
        lda     mi_player_vehicle_types,x
        sta     (zp4C),y
b9AED:  rts



;-----------------------------------------------------------
;-----------------------------------------------------------

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
b9B06:  jsr     get_tile
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



;-----------------------------------------------------------
;-----------------------------------------------------------

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



;-----------------------------------------------------------
;-----------------------------------------------------------

s9B3E:  ldx     zp44
        lda     mi_player_vehicle_x_coords,x
        sta     zp22
        sec
        sbc     POS_X
        jsr     s9B2B
        sty     zp48
        sta     zp24
        lda     mi_player_vehicle_continent_y_coords,x
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
        lda     mi_player_vehicle_types,x
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
        jsr     get_tile
        cmp     #$03
        beq     b9B8B
        dec     wA145
        bne     b9B93
b9BAF:  jsr     mi_print_tab
        ldx     zp44
        stx     mi_player_8268
        lda     mi_player_vehicle_types,x
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
        sta     st_avatar_tile
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
j9C71:  jsr     set_avatar_vehicle_tile
        jmp     st_draw_world



;-----------------------------------------------------------
;-----------------------------------------------------------

s9C77:  ldx     zp44



;-----------------------------------------------------------
;               get_vehicle_location_in_memory
;
; Retrieves the memory location of the specified vehicle on
; the world map. After calling this method, '(zp4C),y' will
; point to the tile on the world map where the vehicle is
; located.
;
; Input:
;       x - vehicle entry index
;
; Output:
;       y - the x coordinate of the vehicle
;    zp4C - Address of the world map row where the vehicle
;           is located
;-----------------------------------------------------------

get_vehicle_location_in_memory:
        lda     #$00                                    ; zp4C := 0
        sta     zp4C

        lda     mi_player_vehicle_continent_y_coords,x
        and     #$3F
        lsr     a
        ror     zp4C
        lsr     a
        ror     zp4C
        adc     #$64
        sta     zp4D
        ldy     mi_player_vehicle_x_coords,x
        rts



;-----------------------------------------------------------
;-----------------------------------------------------------

s9C90:  cmp     #$08
        bcc     done
        cmp     #$10
        bcc     s9CA6
        rts

        .byte   $48,$20,$D2,$97,$68,$4C,$A6,$9C
        .byte   $48,$20,$E0,$97,$68



;-----------------------------------------------------------
;-----------------------------------------------------------

s9CA6:  cpx     #$40
        bcs     done
        cpy     #$40
        bcs     done
        stx     zp46
        ldx     mi_player_vehicle_count
        cpx     #$50
        bcs     done
        asl     a
        sta     mi_player_vehicle_types,x
        pha
        tya
        ora     mi_player_continent_mask
        sta     mi_player_vehicle_continent_y_coords,x
        lda     zp46
        sta     mi_player_vehicle_x_coords,x
        jsr     get_vehicle_location_in_memory
        lda     (zp4C),y
        sta     mi_player_vehicle_tiles,x
        pla
        sta     (zp4C),y
        inc     mi_player_vehicle_count
        clc
done:   rts



;-----------------------------------------------------------
;              remove_vehicle_at_player_location
;
; Removes the vehicle information from the player data for
; the vehicle at the players current location on the world
; map.
;
; Input:
;
; Output:
;       a - the removed vehicle type
;       x - vehicle entry index
;-----------------------------------------------------------

remove_vehicle_at_player_location:
        ldx     POS_X                                   ; Get the players current location
        ldy     POS_Y

        cpx     #$40                                    ; If the current location is invalid...
        bcs     done
        cpy     #$40
        bcs     done                                    ; ...then we are done

        stx     zp46                                    ; zp46 := player x coordinate

        tya
        ora     mi_player_continent_mask                ; a := mi_player_continent_mask | player y coordinate

        ldx     mi_player_vehicle_count                 ; Find the appropriate vehicle location entry in the player save data
@loop:
        dex
        bmi     done
        cmp     mi_player_vehicle_continent_y_coords,x  ; If the y coordinate/continent does not match...
        bne     @loop
        ldy     mi_player_vehicle_x_coords,x            ; ...and the x coordinate does not match
        cpy     zp46
        bne     @loop                                   ; ...then keep looking

        ; at this point, x has the vehicle entry index

        ; continued in remove_player_vehicle_x



;-----------------------------------------------------------
;                  remove_player_vehicle_x
;
; Removed the given vehicle entry from the player
; information.
;
; Input:
;       x - vehicle entry index
;
; Output:
;       a - the removed vehicle type
;       x - vehicle entry index
;-----------------------------------------------------------

remove_player_vehicle_x:
        lda     mi_player_vehicle_continent_y_coords,x  ; If the vehicle is on the current continent...
        and     #$C0
        cmp     mi_player_continent_mask
        bne     b9D0E

        jsr     get_vehicle_location_in_memory          ; ...restore the original tile on the world map
        lda     mi_player_vehicle_tiles,x
        sta     (zp4C),y

b9D0E:  lda     mi_player_vehicle_types,x               ; zp3A := the removed vehicle type
        sta     zp3A

        stx     zp46                                    ; zp46 := the removed vehicle index

        dec     mi_player_vehicle_count                 ; Reduce the vehicle counter

        bne     @next_vehicle                           ; If no more vehicles are left...
        rts                                             ; ...then we are done

@loop:  lda     mi_player_vehicle_x_coords + 1,x        ; Shift all vehicle entries after the removed vehicle up
        sta     mi_player_vehicle_x_coords,x
        lda     mi_player_vehicle_continent_y_coords + 1,x
        sta     mi_player_vehicle_continent_y_coords,x
        lda     mi_player_vehicle_types + 1,x
        sta     mi_player_vehicle_types,x
        lda     mi_player_vehicle_tiles + 1,x
        sta     mi_player_vehicle_tiles,x

        lda     wBD00 + 1,x
        sta     wBD00,x

        inx
@next_vehicle:
        cpx     mi_player_vehicle_count                 ; If that was not the last vehicle...
        bcc     @loop                                   ; ...keep going

        ldx     zp46                                    ; x := the removed vehicle index
        lda     zp3A                                    ; a := the removed vehicle type

        rts



;-----------------------------------------------------------
;-----------------------------------------------------------

s9D44:  jsr     st_get_random_number
        and     #$3F
        tay
        jsr     st_get_random_number
        and     #$3F
        tax



;-----------------------------------------------------------
;                         get_tile
;
; Gets the tile at the given location.
;
; Input:
;       x - the x coordinate
;       y - the y coordinate
;
; Output:
;       a - the tile at the given coordinate
;-----------------------------------------------------------

get_tile:
        lda     #$00

        cpy     #$40                                    ; if x or y >= 64, then we're done
        bcs     @done
        cpx     #$40
        bcs     @done

        tya                                             ; Cache the y value
        sta     @restore_y + 1

        lsr     a                                       ; zp4C := $6400 + (y << 6)
        sta     zp4D
        lda     #<continent_map
        ror     a
        lsr     zp4D
        ror     a
        sta     zp4C

        lda     zp4D
        adc     #>continent_map
        sta     zp4D

        txa                                             ; Read byte at zp4C + x
        tay
        lda     (zp4C),y

@restore_y:
        ldy     #$00

@done:  lsr     a                                       ; The values in the world map are all shifted one bit, so shift it back
        rts



;-----------------------------------------------------------
;               get_player_position_and_tile
;
; Returns the players current location and which tile is
; currently under the player.
;
; Input:
;
; Output:
;       a - tile under the player
;       x - x coordinate of player
;       y - y coordinate of player
;   wA142 - tile under the player
;-----------------------------------------------------------

get_player_position_and_tile:
        ldx     POS_X
        ldy     POS_Y
        jsr     get_tile
        sta     wA142
        rts



;-----------------------------------------------------------
;-----------------------------------------------------------

cmd_inform_search:
        jsr     mi_print_tab
        jsr     get_player_position_and_tile            ; a := wA142 := tile at player location

        cmp     #$03                                    ; If the tile is mountains...
        beq     @over_mountains                         ; ...treat it the same as plains

        cmp     #$08                                    ; If tile is a vehicle...
        bcc     @cache_tile
        lda     POS_Y                                   ; ...get the tile from the vehicle tile cache instead
        ora     mi_player_continent_mask
        ldx     mi_player_vehicle_count
@loop:  cmp     mi_player_vehicle_continent_y_coords - 1,x
        bne     @next_vehicle
        ldy     mi_player_vehicle_x_coords - 1,x
        cpy     POS_X
        bne     @next_vehicle
        lda     mi_player_vehicle_tiles - 1,x
        lsr     a
        bpl     @cache_tile
@next_vehicle:  dex
        bne     @loop

@over_mountains:
        lda     #$01                                    ; Treat tile as plains
@cache_tile:
        sta     wA142                                   ; Store tile in cache (wA142)

        cmp     #$04                                    ; If the tile is water, plains, or forest...
        bcs     @special_tile
        tax                                             ; ...then inform the player as such
        jsr     mi_print_string_entry_x2
        .addr   tile_descriptions

        ldx     wA142                                   ; x := cached tile

        dex                                             ; If tile is plains...
        bne     @done
        ldx     mi_player_continent                     ; ...append the continent name
        jsr     mi_print_string_entry_x2
        .addr   mi_land_name_table
@done:  rts

@special_tile:
        cmp     #$06                                    ; If the tile is a town...
        bne     b9DDF
        jsr     mi_print_text                           ; ...print prefix for the town name
        .asciiz "the city of "

b9DDF:  lda     mi_player_continent_mask
        ora     POS_Y
        ldx     #$53
b9DE6:  cmp     mi_world_feature_continent_y_coords,x
        bne     b9DF2
        ldy     mi_world_feature_x_coords,x
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



;-----------------------------------------------------------
;                  print_current_vehicle
;
; Prints the name of the players current vehicle.
;
; Input:
;
; Output:
;-----------------------------------------------------------

print_current_vehicle:
        ldx     mi_player_current_vehicle
        jsr     mi_print_string_entry_x2
        .addr   mi_transport_table
        rts



;-----------------------------------------------------------
;                 set_avatar_vehicle_tile
;
; Updates the avatar tile to the appropriate image for the
; vehicle that the player is currently travelling in. If
; the vehicle is invalid, automatically places the player
; on foot.
;
; Input:
;
; Output:
;-----------------------------------------------------------

set_avatar_vehicle_tile:
        lda     mi_player_current_vehicle               ; If vehicle ID >= 11...
        cmp     #$0B
        bcc     @valid_vehicle
        lda     #$00                                    ; ...then it is not valid - put player on foot
        sta     mi_player_current_vehicle

@valid_vehicle:
        cmp     #$07                                    ; If the player is in a time machine...
        bcc     @not_time_machine
        lda     #$0A                                    ; ...update the vehicle ID as such
        sta     mi_player_current_vehicle
        lda     #$07

@not_time_machine:
        ora     #$08                                    ; Convert vehicle ID to the corresponding tile image ID
        asl     a
        sta     st_avatar_tile

        rts
