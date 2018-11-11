.include "kernel.inc"
.include "st.inc"

.export mi_command_decode_table
.export mi_command_table_override
.export mi_get_item_to_ready
.export mi_div_a_by_10
.export mi_selected_item
.export mi_s863C

.export bm_addr_mask_cache

.import mi_print_crlf_col_1
.import mi_print_string_entry_x
.import mi_print_string_entry_x2
.import mi_print_text
.import mi_print_text_at_x_y
.import mi_reset_buffers
.import mi_restore_text_area
.import mi_store_text_area
.import draw_border_and_restore_text_area

.import inc_then_read_ptr

.import mi_player_food

.import rts_ptr

.import armor_table
.import spell_table
.import mi_weapon_table
.import mi_player_equipped_armor
.import mi_player_equipped_spell
.import mi_player_equipped_weapon
.import mi_player_inventory_armor
.import mi_player_inventory_spells
.import mi_player_inventory_weapons

.import w824F
.import w8250
.import w8259

zp26            := $26
zp27            := $27
zp41            := $41
zp42            := $42
zp43            := $43
zp46            := $46

        .setcpu "6502"

.segment        "CODE_ZZZ": absolute

        .byte   $2F,$55,$31,$2E,$50,$4C,$41,$59
        .byte   $45,$52,$2F,$55,$31,$2E,$56,$41
        .byte   $52,$53,$00,$00,$00

bm_addr_mask_cache:
        .byte   $00

mi_selected_item:
        .byte   $00

w81C5:  .byte   $05
w81C6:  .byte   $50

mi_command_table_override:
        .byte   $00,$00

mi_command_decode_table:
        .byte   $40,$2F,$3B,$3A,$20,$41,$42,$43         ; 25 bytes
        .byte   $44,$45,$46,$47,$48,$49,$4B,$4E
        .byte   $4F,$51,$52,$53,$54,$55,$56,$58
        .byte   $5A



.segment "CODE_ZZZ2"

;-----------------------------------------------------------
;-----------------------------------------------------------

mi_div_a_by_10:
        ldy     #$FF
        sec
b85C2:  iny
        sbc     #$0A
        bcs     b85C2
        tya
        rts



;-----------------------------------------------------------
;-----------------------------------------------------------

mi_get_random_number_a:
        sta     zp43
        jsr     st_get_random_number
b85CE:  cmp     zp43
        bcc     b85D6
        sbc     zp43
        bcs     b85CE
b85D6:  cmp     #$00
        sta     zp43
        rts

        .byte   $20,$73,$16,$A5,$56,$60



;-----------------------------------------------------------
;-----------------------------------------------------------

mi_reset_buffers_and_wait_for_input:
        jsr     mi_reset_buffers
mi_wait_for_input:
        ldy     #$3D
        sty     w85FC
b85E9:  jsr     st_scan_input
        nop
        nop
        nop
        cmp     #$00
        bne     b85FB
        jsr     st_delay_a_squared
        dec     w85FC
        bne     b85E9
b85FB:  rts

w85FC:  .byte   $40



.segment "CODE_ZZZ3"

        .byte   $18,$B0



;-----------------------------------------------------------
;                           mi_s863C
;
; Seems to handle reducing food periodically, as well as
; increasing something else related to the player.
;-----------------------------------------------------------

mi_s863C:
        sec                                             ; Set carry flag

        sty     w81C5
        sta     w81C6

        bcc     @check_food_timer                       ; If carry flag is clear...
        lda     #$00                                    ; ...play "step" sound
        jsr     st_queue_sound

@check_food_timer:
        sed                                             ; Put CPU in decimal mode

        sec
        lda     w8259
        sbc     w81C5
        sta     w8259
        bcs     @increase_something

        lda     mi_player_food                          ; If there is no food left...
        ora     mi_player_food + 1
        beq     @increase_something                     ; ...then do not decrease the food supply

        lda     mi_player_food                          ; Otherwise, decrease food
        bne     @decrease_food_low
        dec     mi_player_food + 1
@decrease_food_low:
        dec     mi_player_food

@increase_something:
        clc
        lda     w824F
        adc     w81C6
        sta     w824F
        bcs     @increase_high_bytes

        cld                                             ; Put CPU back in binary mode

        rts


@increase_high_bytes:
        sed
        sec
        ldx     #$00
@loop_increase:
        lda     w8250,x
        adc     #$00
        sta     w8250,x
        inx
        bcs     @loop_increase

        cld                                             ; Put CPU back in binary mode

        rts



.segment "CODE_ZZZ4"

;-----------------------------------------------------------

        .byte   $AE,$EE,$81,$20,$2D,$84,$88,$78
        .byte   $60



.segment "CODE_ZZZ5"

;-----------------------------------------------------------

        .byte   $20,$8E,$84,$7D,$48,$6D,$6D,$6D
        .byte   $6D,$2E,$2E,$2E,$20,$6E,$6F,$20
        .byte   $65,$66,$66,$65,$63,$74,$3F,$00
        .byte   $A9,$08,$D0,$0A




.segment "CODE_ZZZ6"

;-----------------------------------------------------------
;-----------------------------------------------------------

mi_s8788:
        jsr     mi_store_text_area
        lda     #$04
        sta     CUR_Y_MIN
        sta     CUR_X_OFF
        lda     #$10
        sta     CUR_Y_MAX
        lda     #$20
        sta     CUR_X_MAX
        jsr     st_clear_text_window
        jsr     mi_print_crlf_col_1
mi_s879F:
        lda     #$60
mi_s87A1:
        jsr     st_s168B
        jsr     s87C9
        ldx     #$04
        ldy     #$12
        stx     zp26
        sty     zp27
        ldx     #$FA
        jsr     st_s1691
        ldx     zp26
        ldy     #$6D
        jsr     st_s1691
        ldx     #$04
        ldy     zp27
        jsr     st_s1691
        ldx     zp26
        ldy     #$12
        jsr     st_s1691
s87C9:  lda     BM_ADDR_MASK
        eor     BM2_ADDR_MASK
        sta     BM_ADDR_MASK
        rts



;-----------------------------------------------------------
;-----------------------------------------------------------

mi_get_item_to_ready:
        pha
        lda     #$07
        sta     CUR_X
        pla
        ldx     #$03
b87D8:  cmp     r87F5,x
        beq     b87E0
        dex
        bne     b87D8
b87E0:  txa
        asl     a
        tay
        lda     r87FA,y
        pha
        lda     r87F9,y
        pha
        jsr     mi_print_string_entry_x2
        .addr   r882E
        jsr     st_clear_to_end_of_text_row_a
        inc     CUR_X
r87F5:  rts

        .byte   $53,$57,$41
r87F9:
r87FA           := * + 1
        .word   r87F5-1
        .word   j8801-1
        .word   j8810-1
        .word   j881F-1
j8801:  lda     mi_player_equipped_spell
        jsr     s8849
        .byte   $0A
        .addr   mi_player_inventory_spells
        .addr   spell_table
        sta     mi_player_equipped_spell
        rts

j8810:  lda     mi_player_equipped_weapon
        jsr     s8849
        .byte   $0F
        .addr   mi_player_inventory_weapons
        .addr   mi_weapon_table
        sta     mi_player_equipped_weapon
        rts

j881F:  lda     mi_player_equipped_armor
        jsr     s8849
        .byte   $05
        .addr   mi_player_inventory_armor
        .addr   armor_table
        sta     mi_player_equipped_armor
        rts

r882E:  .byte   "nothin"
        .byte   $E7
        .byte   "spell"
        .byte   $BA
        .byte   "weapon"
        .byte   $BA
        .byte   "armour"
        .byte   $BA
s8849:  sta     zp46
        pla
        sta     rts_ptr
        pla
        sta     rts_ptr + 1
        jsr     inc_then_read_ptr
        sta     max_ready_option
        jsr     inc_then_read_ptr
        sta     zp41
        jsr     inc_then_read_ptr
        sta     zp42
        jsr     inc_then_read_ptr
        sta     w8907
        jsr     inc_then_read_ptr
        sta     w8908
        lda     rts_ptr + 1
        pha
        lda     rts_ptr
        pha
        jsr     mi_store_text_area
        jsr     st_set_text_window_main
        ldx     #$0E
        ldy     #$00
        lda     BM2_ADDR_MASK
        sta     bm_addr_mask_cache
        sty     BM2_ADDR_MASK
        jsr     mi_print_text_at_x_y
        .byte   $0E
        .byte   " Ready "
        .byte   $18,$00
        jsr     st_clear_text_window
        ldy     max_ready_option
        ldx     #$01
b889D:  lda     (zp41),y
        beq     b88A2
        inx
b88A2:  dey
        bne     b889D
        stx     zp43
        sec
        lda     #$14
        sbc     zp43
        lsr     a
        sta     CUR_Y
        lda     #$61
        sta     w88BF
        ldy     #$00
b88B6:  tya
        pha
        lda     #$0D
        sta     CUR_X
        jsr     mi_print_text
w88BF:  .byte   "a) "
        .byte   $00
        pla
        jsr     s8902
        tay
        inc     CUR_Y
b88CA:  cpy     max_ready_option
        bcs     b88D9
        inc     w88BF
        iny
        lda     (zp41),y
        bne     b88B6
        beq     b88CA
b88D9:  jsr     mi_restore_text_area
        lda     bm_addr_mask_cache
        sta     BM2_ADDR_MASK
        jsr     st_swap_bitmaps
        jsr     st_read_input
        pha
        jsr     draw_border_and_restore_text_area
        sec
        pla
        sbc     #$41
        beq     s8902
        bmi     b88FF
        cmp     max_ready_option
        bcc     b88FA
        bne     b88FF
b88FA:  tay
        lda     (zp41),y
        bne     b8901
b88FF:  ldy     zp46
b8901:  tya
s8902:  tax
        pha
        jsr     mi_print_string_entry_x
w8907:
w8908           := * + 1
        .addr   $0000
        pla
        rts

max_ready_option:
        .byte   $0A
