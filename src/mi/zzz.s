.include "kernel.inc"
.include "st.inc"

.export mi_current_attribute
.export mi_w81C8
.export mi_s85FD
.export mi_s863C

.export bm_addr_mask_cache

.import mi_play_error_sound_and_reset_buffers
.import mi_player_food
.import mi_print_text

.import print_string_entry_x

.import r797F

.import w824F
.import w8250
.import w8259

        .setcpu "6502"

.segment        "CODE_ZZZ": absolute

        .byte   $2F,$55,$31,$2E,$50,$4C,$41,$59
        .byte   $45,$52,$2F,$55,$31,$2E,$56,$41
        .byte   $52,$53,$00,$00,$00

bm_addr_mask_cache:
        .byte   $00

mi_current_attribute:
        .byte   $00

w81C5:  .byte   $05
w81C6:  .byte   $50
w81C7:  .byte   $00

mi_w81C8:
        .byte   $00
        
w81C9:  .byte   $40,$2F,$3B,$3A,$20,$41,$42,$43
        .byte   $44,$45,$46,$47,$48,$49,$4B,$4E
        .byte   $4F,$51,$52,$53,$54,$55,$56,$58
        .byte   $5A



.segment "CODE_ZZZ2"

        .byte   $48,$4A,$4A,$4A,$4A,$20,$CD,$83
        .byte   $68



.segment        "CODE_ZZZ3": absolute

        .byte   $A0,$FF,$38,$C8,$E9,$0A,$B0,$FB
        .byte   $98,$60,$85,$43,$20,$70,$16,$C5
        .byte   $43,$90,$04,$E5,$43,$B0,$F8,$C9
        .byte   $00,$85,$43,$60,$20,$73,$16,$A5
        .byte   $56,$60,$20,$77,$87,$A0,$3D,$8C
        .byte   $FC,$85,$20,$D5,$1E,$EA,$EA,$EA
        .byte   $C9,$00,$D0,$08,$20,$A0,$16,$CE
        .byte   $FC,$85,$D0,$EE,$60,$40
mi_s85FD:
        ldx     #$18
b85FF:  cmp     w81C9,x
        beq     b8614
        dex
        bpl     b85FF
        jsr     mi_print_text
        .byte   "Huh?"
        .byte   $00
        jsr     mi_play_error_sound_and_reset_buffers
        sec
        rts

b8614:  txa
        pha
        cmp     #$04
        bcs     b8630
        lda     mi_w81C8
        beq     b8630
        sta     w862C
        lda     w81C7
        sta     w862B
        jsr     print_string_entry_x
w862B:
w862C           := * + 1
        .addr   r797F
        jmp     j8635

b8630:  jsr     print_string_entry_x
        .addr   r797F
j8635:  pla
        asl     a
        tax
        clc
        rts

        .byte   $18,$B0
mi_s863C:
        sec
        sty     w81C5
        sta     w81C6
        bcc     b864A
        lda     #$00
        jsr     st_queue_sound
b864A:  sed
        sec
        lda     w8259
        sbc     w81C5
        sta     w8259
        bcs     b866A
        lda     mi_player_food
        ora     mi_player_food + 1
        beq     b866A
        lda     mi_player_food
        bne     b8667
        dec     mi_player_food + 1
b8667:  dec     mi_player_food
b866A:  clc
        lda     w824F
        adc     w81C6
        sta     w824F
        bcs     b8678
        cld
        rts

b8678:  sed
        sec
        ldx     #$00
b867C:  lda     w8250,x
        adc     #$00
        sta     w8250,x
        inx
        bcs     b867C
        cld
        rts



.segment "CODE_ZZZ4"

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



.segment "CODE_ZZZ5"

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



.segment "CODE_ZZZ6"

        .byte   $60,$20,$8E,$84,$20,$6F,$66,$66
        .byte   $00,$60,$AD,$38,$16,$49,$FF,$8D
        .byte   $38,$16,$8D,$E7,$81,$F0,$EA,$20
        .byte   $8E,$84,$20,$6F,$6E,$00,$60
