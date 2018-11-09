.include "kernel.inc"
.include "st.inc"

.export mi_command_table_override
.export mi_selected_item
.export mi_s863C

.export bm_addr_mask_cache
.export command_decode_table

.import mi_player_food

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

mi_selected_item:
        .byte   $00

w81C5:  .byte   $05
w81C6:  .byte   $50

mi_command_table_override:
        .byte   $00,$00

command_decode_table:
        .byte   $40,$2F,$3B,$3A,$20,$41,$42,$43         ; 25 bytes
        .byte   $44,$45,$46,$47,$48,$49,$4B,$4E
        .byte   $4F,$51,$52,$53,$54,$55,$56,$58
        .byte   $5A



.segment "CODE_ZZZ2"

        .byte   $A0,$FF,$38,$C8,$E9,$0A,$B0,$FB
        .byte   $98,$60,$85,$43,$20,$70,$16,$C5
        .byte   $43,$90,$04,$E5,$43,$B0,$F8,$C9
        .byte   $00,$85,$43,$60,$20,$73,$16,$A5
        .byte   $56,$60,$20,$77,$87,$A0,$3D,$8C
        .byte   $FC,$85,$20,$D5,$1E,$EA,$EA,$EA
        .byte   $C9,$00,$D0,$08,$20,$A0,$16,$CE
        .byte   $FC,$85,$D0,$EE,$60,$40



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
        .byte   $00,$68,$60,$0A



.segment "CODE_ZZZ7"

        .byte   $60,$20,$8E,$84,$20,$6F,$66,$66
        .byte   $00,$60,$AD,$38,$16,$49,$FF,$8D
        .byte   $38,$16,$8D,$E7,$81,$F0,$EA,$20
        .byte   $8E,$84,$20,$6F,$6E,$00,$60
