.include "kernel.inc"
.include "st.inc"

.export mi_play_error_sound_and_reset_buffers
.export mi_print_short_int
.export mi_restore_text_area
.export mi_store_text_area

.export mi_clear_screen_and_draw_border
.export mi_display_stats

.export mi_current_attribute
.export mi_w85BE

.export draw_border
.export reset_buffers

.import mi_cursor_to_col_0
.import mi_print_char
.import mi_print_text
.import mi_print_x_chars

.import clear_to_end_then_print_lfcr
.import print_digit

.import mi_player_experience
.import mi_player_food
.import mi_player_hits
.import mi_player_money

dec_lo          := $3C
dec_mid         := $3D
dec_hi          := $3E
hex_lo          := $3F
hex_hi          := $40

        .setcpu "6502"

.segment "CODE_ZZZ"

text_area_cache:
        .byte   $00,$28,$00,$18,$00,$00

.segment "CODE_ZZZ2"

        .byte   $2F,$55,$31,$2E,$50,$4C,$41,$59
        .byte   $45,$52,$2F,$55,$31,$2E,$56,$41
        .byte   $52,$53,$00,$00,$00,$00

mi_current_attribute:
        .byte   $00

        .byte   $05,$50,$00,$00,$40,$2F,$3B,$3A
        .byte   $20,$41,$42,$43,$44,$45,$46,$47
        .byte   $48,$49,$4B,$4E,$4F,$51,$52,$53
        .byte   $54,$55,$56,$58,$5A



.segment "CODE_ZZZ3"

        .byte   $48,$4A,$4A,$4A,$4A,$20,$CD,$83
        .byte   $68



.segment "CODE_ZZZ4"

;-----------------------------------------------------------
;
;-----------------------------------------------------------

mi_clear_screen_and_draw_border:
        jsr     st_set_text_window_full
        jsr     st_clear_text_window

;-----------------------------------------------------------

draw_border:
        jsr     st_set_text_window_full
        lda     #$10
        jsr     mi_print_char
        ldx     #$26
        lda     #$04
        jsr     mi_print_x_chars
        lda     #$12
        jsr     st_print_char

@loop:  inc     CUR_Y
        jsr     mi_cursor_to_col_0
        lda     #$0A
        jsr     st_print_char
        lda     #$27
        sta     CUR_X
        lda     #$08
        jsr     st_print_char
        jsr     st_scan_and_buffer_input
        lda     CUR_Y
        eor     #$12
        bne     @loop

        sta     CUR_X
        inc     CUR_Y
        lda     #$04
        jsr     mi_print_char
        ldx     #$26
        lda     #$06
        jsr     mi_print_x_chars
        lda     #$04
        jsr     st_print_char
        lda     #$1E
        sta     CUR_X
        lda     #$02
        jsr     st_print_char
        lda     #$0C
b8516:  inc     CUR_Y
        jsr     st_print_char
        ldx     CUR_Y
        cpx     #$17
        bcc     b8516
        rts



;-----------------------------------------------------------
;
;-----------------------------------------------------------

to_decimal_a_x:
        stx     hex_lo
        sta     hex_hi
        ldx     #$00
        stx     dec_lo
        stx     dec_mid
        stx     dec_hi
        stx     dec_cnt_hi
        stx     dec_cnt_mid
        inx
        stx     dec_cnt_lo
        sed
b8539:  lsr     hex_hi
        ror     hex_lo
        bcc     b8555
        clc
        lda     dec_lo
        adc     dec_cnt_lo
        sta     dec_lo
        lda     dec_mid
        adc     dec_cnt_mid
        sta     dec_mid
        lda     dec_hi
        adc     dec_cnt_hi
        sta     dec_hi
b8555:  clc
        lda     dec_cnt_lo
        adc     dec_cnt_lo
        sta     dec_cnt_lo
        lda     dec_cnt_mid
        adc     dec_cnt_mid
        sta     dec_cnt_mid
        lda     dec_cnt_hi
        adc     dec_cnt_hi
        sta     dec_cnt_hi
        lda     hex_lo
        ora     hex_hi
        bne     b8539
        cld
        rts

dec_cnt_lo:
        .byte   $01
dec_cnt_mid:
        .byte   $00
dec_cnt_hi:
        .byte   $00



;-----------------------------------------------------------
;
;-----------------------------------------------------------

print_long_int:
        jsr     to_decimal_a_x
        inx
        bne     b8588

;-----------------------------------------------------------

mi_print_short_int:
        tax
        lda     #$00
        jsr     to_decimal_a_x
b8588:  sta     w85BD
        jmp     j8597

b858E:  lda     dec_lo,x
        lsr     a
        lsr     a
        lsr     a
        lsr     a
        jsr     s85A6
j8597:  txa
        bne     b859D
        inc     w85BD
b859D:  lda     dec_lo,x
        jsr     s85A6
        dex
        bpl     b858E
b85A5:  rts



;-----------------------------------------------------------
;
;-----------------------------------------------------------

s85A6:  and     #$0F
        bne     b85B7
        cmp     w85BD
        bne     b85BA
        lda     mi_w85BE
        beq     b85A5
        jmp     mi_print_char

b85B7:  sta     w85BD
b85BA:  jmp     print_digit



;-----------------------------------------------------------

w85BD:  .byte   $00
mi_w85BE:
        .byte   $00,$A0,$FF,$38,$C8,$E9,$0A,$B0
        .byte   $FB,$98,$60,$85,$43,$20,$70,$16
        .byte   $C5,$43,$90,$04,$E5,$43,$B0,$F8
        .byte   $C9,$00,$85,$43,$60,$20,$73,$16
        .byte   $A5,$56,$60,$20,$77,$87,$A0,$3D
        .byte   $8C,$FC,$85,$20,$D5,$1E,$EA,$EA
        .byte   $EA,$C9,$00,$D0,$08,$20,$A0,$16
        .byte   $CE,$FC,$85,$D0,$EE,$60,$40,$A2
        .byte   $18,$DD,$C9,$81,$F0,$10,$CA,$10
        .byte   $F8,$20,$8E,$84,$48,$75,$68,$3F
        .byte   $00,$20,$72,$87,$38,$60,$8A,$48
        .byte   $C9,$04,$B0,$16,$AD,$C8,$81,$F0
        .byte   $11,$8D,$2C,$86,$AD,$C7,$81,$8D
        .byte   $2B,$86,$20,$2D,$84,$7F,$79,$4C
        .byte   $35,$86,$20,$2D,$84,$7F,$79,$68
        .byte   $0A,$AA,$18,$60,$18,$B0,$38,$8C
        .byte   $C5,$81,$8D,$C6,$81,$90,$05,$A9
        .byte   $00,$20,$85,$16,$F8,$38,$AD,$59
        .byte   $82,$ED,$C5,$81,$8D,$59,$82,$B0
        .byte   $13,$AD,$5A,$82,$0D,$5B,$82,$F0
        .byte   $0B,$AD,$5A,$82,$D0,$03,$CE,$5B
        .byte   $82,$CE,$5A,$82,$18,$AD,$4F,$82
        .byte   $6D,$C6,$81,$8D,$4F,$82,$B0,$02
        .byte   $D8,$60,$F8,$38,$A2,$00,$BD,$50
        .byte   $82,$69,$00,$9D,$50,$82,$E8,$B0
        .byte   $F5,$D8,$60



;-----------------------------------------------------------
;
;-----------------------------------------------------------

mi_display_stats:
        jsr     mi_store_text_area
        jsr     st_set_text_window_stats
        jsr     mi_print_text

        .byte   "Hits |Food |Exp. |Coin ",$00

        jmp     j86C9



s86AD:  cmp     #$01
        bcs     b86BB
        cpx     #$64
        bcs     b86BB
        pha
        lda     #$FF
        sta     CHAR_REV
        pla
b86BB:  jsr     print_long_int
        jsr     clear_to_end_then_print_lfcr
        lda     #$00
        sta     CHAR_REV
        rts


        jsr     mi_store_text_area



j86C9:  jsr     st_set_text_window_stats

        sta     mi_w85BE

        lda     #$24
        sta     CUR_X_OFF
        lda     #$04
        sta     CUR_X_MAX
        lda     mi_player_hits + 1
        ldx     mi_player_hits
        jsr     s86AD
        lda     mi_player_food + 1
        ldx     mi_player_food
        jsr     s86AD
        lda     mi_player_experience + 1
        ldx     mi_player_experience
        jsr     print_long_int
        jsr     clear_to_end_then_print_lfcr
        lda     mi_player_money + 1
        ldx     mi_player_money
        jsr     print_long_int
        jsr     st_clear_to_end_of_text_row_a
mi_restore_text_area:
        ldx     #$05
b8703:  lda     text_area_cache,x
        sta     CUR_X_OFF,x
        dex
        bpl     b8703
        rts



;-----------------------------------------------------------
;
;-----------------------------------------------------------

mi_store_text_area:
        ldx     #$05
b870E:  lda     CUR_X_OFF,x
        sta     text_area_cache,x
        dex
        bpl     b870E
        rts



;-----------------------------------------------------------

        .byte   $AE,$EE,$81,$20,$2D,$84,$88,$78
        .byte   $60,$A5,$33,$0A,$0A,$0A,$AA,$A4
        .byte   $32,$F0,$23,$88,$BD,$00,$12,$18
        .byte   $79,$B0,$15,$85,$36,$BD,$C0,$12
        .byte   $45,$5C,$79,$D8,$15,$85,$37,$A0
        .byte   $07,$A9,$00,$11,$36,$D0,$07,$88
        .byte   $10,$F9,$C6,$32,$D0,$D9,$60,$20
        .byte   $8E,$84,$7D,$48,$6D,$6D,$6D,$6D
        .byte   $2E,$2E,$2E,$20,$6E,$6F,$20,$65
        .byte   $66,$66,$65,$63,$74,$3F,$00,$A9
        .byte   $08,$D0,$0A,$20,$20,$87,$A9,$3F
        .byte   $20,$67,$16



;-----------------------------------------------------------
;
;-----------------------------------------------------------

mi_play_error_sound_and_reset_buffers:
        lda     #$10
        jsr     st_play_sound_a
reset_buffers:
        nop
        nop
        nop
        jsr     KERNEL_GETIN
        cmp     #$00
        bne     reset_buffers
        lda     #$00
        sta     SOUND_BUFFER_SIZE
        sta     INPUT_BUFFER_SIZE
        rts



;-----------------------------------------------------------

        .byte   $20,$0C,$87,$A9,$04,$85,$30,$85
        .byte   $2E,$A9,$10,$85,$31,$A9,$20,$85
        .byte   $2F,$20,$52,$16,$20,$F3,$83,$A9
        .byte   $60,$20,$8B,$16,$20,$C9,$87,$A2
        .byte   $04,$A0,$12,$86,$26,$84,$27,$A2
        .byte   $FA,$20,$91,$16,$A6,$26,$A0,$6D
        .byte   $20,$91,$16,$A2,$04,$A4,$27,$20
        .byte   $91,$16,$A6,$26,$A0,$12,$20,$91
        .byte   $16,$A5,$5C,$45,$5D,$85,$5C,$60
        .byte   $48,$A9,$07,$85,$32,$68,$A2,$03
        .byte   $DD,$F5,$87,$F0,$03,$CA,$D0,$F8
        .byte   $8A,$0A,$A8,$B9,$FA,$87,$48,$B9
        .byte   $F9,$87,$48,$20,$2D,$84,$2E,$88
        .byte   $20,$4F,$16,$E6,$32,$60,$53,$57
        .byte   $41,$F4,$87,$00,$88,$0F,$88,$1E
        .byte   $88,$AD,$EE,$81,$20,$49,$88,$0A
        .byte   $08,$82,$88,$78,$8D,$EE,$81,$60
        .byte   $AD,$EF,$81,$20,$49,$88,$0F,$F8
        .byte   $81,$7C,$77,$8D,$EF,$81,$60,$AD
        .byte   $F0,$81,$20,$49,$88,$05,$F2,$81
        .byte   $D4,$78,$8D,$F0,$81,$60,$6E,$6F
        .byte   $74,$68,$69,$6E,$E7,$73,$70,$65
        .byte   $6C,$6C,$BA,$77,$65,$61,$70,$6F
        .byte   $6E,$BA,$61,$72,$6D,$6F,$75,$72
        .byte   $BA,$85,$46,$68,$8D,$B5,$83,$68
        .byte   $8D,$B6,$83,$20,$AC,$83,$8D,$0B
        .byte   $89,$20,$AC,$83,$85,$41,$20,$AC
        .byte   $83,$85,$42,$20,$AC,$83,$8D,$07
        .byte   $89,$20,$AC,$83,$8D,$08,$89,$AD
        .byte   $B6,$83,$48,$AD,$B5,$83,$48,$20
        .byte   $0C,$87,$20,$5E,$16,$A2,$0E,$A0
        .byte   $00,$A5,$5D,$8D,$C3,$81,$84,$5D
        .byte   $20,$8A,$84,$0E,$20,$52,$65,$61
        .byte   $64,$79,$20,$18,$00,$20,$52,$16
        .byte   $AC,$0B,$89,$A2,$01,$B1,$41,$F0
        .byte   $01,$E8,$88,$D0,$F8,$86,$43,$38
        .byte   $A9,$14,$E5,$43,$4A,$85,$33,$A9
        .byte   $61,$8D,$BF,$88,$A0,$00,$98,$48
        .byte   $A9,$0D,$85,$32,$20,$8E,$84,$61
        .byte   $29,$20,$00,$68,$20,$02,$89,$A8
        .byte   $E6,$33,$CC,$0B,$89,$B0,$0A,$EE
        .byte   $BF,$88,$C8,$B1,$41,$D0,$DF,$F0
        .byte   $F1,$20,$01,$87,$AD,$C3,$81,$85
        .byte   $5D,$20,$64,$16,$20,$76,$16,$48
        .byte   $20,$D6,$8A,$38,$68,$E9,$41,$F0
        .byte   $11,$30,$0C,$CD,$0B,$89,$90,$02
        .byte   $D0,$05,$A8,$B1,$41,$D0,$02,$A4
        .byte   $46,$98,$AA,$48,$20,$26,$84,$00
        .byte   $00,$68,$60,$0A,$20,$61,$16,$20
        .byte   $0C,$87,$20,$5E,$16,$20,$16,$84
        .byte   $A2,$0C,$A0,$00,$8C,$BE,$85,$A5
        .byte   $5D,$8D,$C3,$81,$84,$5D,$20,$8A
        .byte   $84,$0E,$20,$49,$6E,$76,$65,$6E
        .byte   $74,$6F,$72,$79,$20,$18,$7C,$7C
        .byte   $50,$6C,$61,$79,$65,$72,$3A,$20
        .byte   $00,$20,$A1,$8B,$20,$8E,$84,$7C
        .byte   $41,$20,$6C,$65,$76,$65,$6C,$20
        .byte   $00,$AE,$5C,$82,$AD,$5D,$82,$20
        .byte   $22,$85,$A5,$3D,$4A,$4A,$4A,$4A
        .byte   $18,$69,$01,$20,$82,$85,$E6,$32
        .byte   $AD,$2C,$82,$F0,$06,$20,$8E,$84
        .byte   $66,$65,$00,$20,$8E,$84,$6D,$61
        .byte   $6C,$65,$20,$00,$AE,$4B,$82,$20
        .byte   $2D,$84,$63,$77,$E6,$32,$AE,$4D
        .byte   $82,$20,$2D,$84,$11,$79,$20,$10
        .byte   $8B,$C6,$33,$A2,$00,$8E,$C4,$81
        .byte   $86,$46,$8A,$0A,$A8,$BE,$3B,$82
        .byte   $B9,$3C,$82,$D0,$04,$E0,$00,$F0
        .byte   $05,$20,$25,$8B,$42,$78,$A6,$46
        .byte   $E8,$E0,$07,$90,$E3,$AE,$49,$82
        .byte   $AD,$4A,$82,$20,$22,$85,$A5,$3C
        .byte   $29,$0F,$F0,$1C,$20,$DC,$8A,$20
        .byte   $8E,$84,$43,$6F,$70,$70,$65,$72
        .byte   $20,$70,$65,$6E,$63,$65,$2E,$2E
        .byte   $2E,$2E,$00,$A5,$3C,$20,$CD,$83
        .byte   $A5,$3C,$4A,$4A,$4A,$4A,$F0,$1C
        .byte   $48,$20,$DC,$8A,$20,$8E,$84,$53
        .byte   $69,$6C,$76,$65,$72,$20,$70,$69
        .byte   $65,$63,$65,$73,$2E,$2E,$2E,$00
        .byte   $68,$20,$CD,$83,$A5,$3D,$F0,$39
        .byte   $20,$DC,$8A,$20,$8E,$84,$47,$6F
        .byte   $6C,$64,$20,$43,$72,$6F,$77,$6E
        .byte   $73,$2E,$2E,$2E,$2E,$00,$A5,$3D
        .byte   $C9,$10,$B0,$1A,$A9,$2E,$20,$D7
        .byte   $83,$A5,$3D,$20,$CD,$83,$4C,$41
        .byte   $8A,$45,$6E,$65,$6D,$79,$20,$76
        .byte   $65,$73,$73,$65,$6C,$F3,$20,$C4
        .byte   $83,$AD,$2B,$82,$F0,$09,$A2,$00
        .byte   $86,$46,$20,$22,$8B,$31,$8A,$AD
        .byte   $F0,$81,$8D,$C4,$81,$A2,$01,$86
        .byte   $46,$BD,$F2,$81,$F0,$05,$20,$22
        .byte   $8B,$D4,$78,$A6,$46,$E8,$E0,$06
        .byte   $90,$ED,$AD,$F1,$81,$8D,$C4,$81
        .byte   $A2,$01,$86,$46,$BD,$13,$82,$F0
        .byte   $05,$20,$22,$8B,$30,$79,$A6,$46
        .byte   $E8,$E0,$0B,$90,$ED,$A2,$00,$8E
        .byte   $C4,$81,$86,$46,$BD,$EA,$81,$F0
        .byte   $05,$20,$22,$8B,$30,$7A,$A6,$46
        .byte   $E8,$E0,$04,$90,$ED,$AD,$EF,$81
        .byte   $8D,$C4,$81,$A2,$01,$86,$46,$BD
        .byte   $F8,$81,$F0,$05,$20,$22,$8B,$7C
        .byte   $77,$A6,$46,$E8,$E0,$10,$90,$ED
        .byte   $AD,$EE,$81,$8D,$C4,$81,$A2,$01
        .byte   $86,$46,$BD,$08,$82,$F0,$05,$20
        .byte   $22,$8B,$88,$78,$A6,$46,$E8,$E0
        .byte   $0B,$90,$ED,$20,$56,$8B,$20,$C6
        .byte   $84,$4C,$01,$87,$A2,$00,$86,$32
        .byte   $A4,$33,$C8,$C0,$12,$90,$0E,$A4
        .byte   $30,$A9,$12,$85,$2F,$65,$2E,$C9
        .byte   $26,$B0,$05,$85,$2E,$84,$33,$60
        .byte   $A2,$0D,$A0,$12,$20,$8A,$84,$6D
        .byte   $6F,$72,$65,$00,$20,$56,$8B,$A9
        .byte   $00,$85,$5D,$E6,$32,$20,$0C,$87
        .byte   $A9,$05,$85,$30,$4A,$85,$2E,$A9
        .byte   $24,$85,$2F,$A9,$13,$85,$31,$4C
        .byte   $52,$16,$AA,$A9,$00,$48,$8A,$48
        .byte   $20,$DC,$8A,$A9,$03,$85,$32,$A2
        .byte   $09,$A9,$2E,$8D,$BE,$85,$20,$B9
        .byte   $84,$68,$AA,$68,$20,$7C,$85,$20
        .byte   $11,$84,$A6,$46,$AD,$C4,$81,$F0
        .byte   $0A,$EC,$C4,$81,$D0,$05,$A9,$1B
        .byte   $20,$D7,$83,$4C,$26,$84,$AD,$C3
        .byte   $81,$85,$5D,$20,$64,$16,$20,$46
        .byte   $16,$20,$01,$87



.segment "UNKNOWN"

        .byte   $60,$20,$8E,$84,$20,$6F,$66,$66
        .byte   $00,$60,$AD,$38,$16,$49,$FF,$8D
        .byte   $38,$16,$8D,$E7,$81,$F0,$EA,$20
        .byte   $8E,$84,$20,$6F,$6E,$00,$60,$20
        .byte   $ED,$83,$20,$A1,$8B,$20,$8E,$84
        .byte   $2C,$20,$74,$68,$6F,$75,$20,$61
        .byte   $72,$74,$20,$64,$65,$61,$64,$2E
        .byte   $00,$20,$46,$16,$A9,$00,$8D,$49
        .byte   $82,$8D,$4A,$82,$8D,$5A,$82,$8D
        .byte   $5B,$82,$8D,$3B,$82,$8D,$3C,$82
        .byte   $A4,$5D,$8C,$C3,$81,$85,$5D,$20
        .byte   $C6,$86,$20,$61,$16,$A9,$03,$85
        .byte   $60,$A9,$74,$85,$61,$A9,$80,$85
        .byte   $62,$A9,$25,$45,$5C,$85,$63,$A2
        .byte   $0C,$A0,$47,$B1,$60,$91,$62,$88
        .byte   $10,$F9,$A5,$60,$18,$69,$48,$85
        .byte   $60,$A5,$61,$69,$00,$85,$61,$A5
        .byte   $62,$18,$69,$40,$85,$62,$A5,$63
        .byte   $69,$01,$85,$63,$CA,$D0,$DA,$A9
        .byte   $02,$20,$85,$16,$A9,$02,$20,$85
        .byte   $16,$AD,$C3,$81,$85,$5D,$20,$64
        .byte   $16,$4C,$77,$87,$20,$CE,$8B
