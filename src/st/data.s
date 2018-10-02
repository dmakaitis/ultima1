;-------------------------------------------------------------------------------
;
; data.s
;
; Data segment of st.prg.
;
;-------------------------------------------------------------------------------

.export tile_images

        .setcpu "6502"


.segment "LOADADDR"

    .addr   $2000

.data

tile_images:
        .incbin "tiles.bin"

bitmap_y_offset_lo:
        .byte   $00,$01,$02,$03,$04,$05,$06,$07
        .byte   $40,$41,$42,$43,$44,$45,$46,$47
bitmap_y_offset_lo_16:
        .byte   $80,$81,$82,$83,$84,$85,$86,$87
        .byte   $C0,$C1,$C2,$C3,$C4,$C5,$C6,$C7
        .byte   $00,$01,$02,$03,$04,$05,$06,$07
        .byte   $40,$41,$42,$43,$44,$45,$46,$47
        .byte   $80,$81,$82,$83,$84,$85,$86,$87
        .byte   $C0,$C1,$C2,$C3,$C4,$C5,$C6,$C7
        .byte   $00,$01,$02,$03,$04,$05,$06,$07
        .byte   $40,$41,$42,$43,$44,$45,$46,$47
        .byte   $80,$81,$82,$83,$84,$85,$86,$87
        .byte   $C0,$C1,$C2,$C3,$C4,$C5,$C6,$C7
        .byte   $00,$01,$02,$03,$04,$05,$06,$07
        .byte   $40,$41,$42,$43,$44,$45,$46,$47
        .byte   $80,$81,$82,$83,$84,$85,$86,$87
        .byte   $C0,$C1,$C2,$C3,$C4,$C5,$C6,$C7
        .byte   $00,$01,$02,$03,$04,$05,$06,$07
        .byte   $40,$41,$42,$43,$44,$45,$46,$47
        .byte   $80,$81,$82,$83,$84,$85,$86,$87
        .byte   $C0,$C1,$C2,$C3,$C4,$C5,$C6,$C7
        .byte   $00,$01,$02,$03,$04,$05,$06,$07
        .byte   $40,$41,$42,$43,$44,$45,$46,$47
        .byte   $80,$81,$82,$83,$84,$85,$86,$87
        .byte   $C0,$C1,$C2,$C3,$C4,$C5,$C6,$C7
bitmap_y_offset_hi:
        .byte   $20,$20,$20,$20,$20,$20,$20,$20
        .byte   $21,$21,$21,$21,$21,$21,$21,$21
bitmap_y_offset_hi_16:
        .byte   $22,$22,$22,$22,$22,$22,$22,$22
        .byte   $23,$23,$23,$23,$23,$23,$23,$23
        .byte   $25,$25,$25,$25,$25,$25,$25,$25
        .byte   $26,$26,$26,$26,$26,$26,$26,$26
        .byte   $27,$27,$27,$27,$27,$27,$27,$27
        .byte   $28,$28,$28,$28,$28,$28,$28,$28
        .byte   $2A,$2A,$2A,$2A,$2A,$2A,$2A,$2A
        .byte   $2B,$2B,$2B,$2B,$2B,$2B,$2B,$2B
        .byte   $2C,$2C,$2C,$2C,$2C,$2C,$2C,$2C
        .byte   $2D,$2D,$2D,$2D,$2D,$2D,$2D,$2D
        .byte   $2F,$2F,$2F,$2F,$2F,$2F,$2F,$2F
        .byte   $30,$30,$30,$30,$30,$30,$30,$30
        .byte   $31,$31,$31,$31,$31,$31,$31,$31
        .byte   $32,$32,$32,$32,$32,$32,$32,$32
        .byte   $34,$34,$34,$34,$34,$34,$34,$34
        .byte   $35,$35,$35,$35,$35,$35,$35,$35
        .byte   $36,$36,$36,$36,$36,$36,$36,$36
        .byte   $37,$37,$37,$37,$37,$37,$37,$37
        .byte   $39,$39,$39,$39,$39,$39,$39,$39
        .byte   $3A,$3A,$3A,$3A,$3A,$3A,$3A,$3A
        .byte   $3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B
        .byte   $3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C
r1380:  .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
r1480:  .byte   $00,$20,$40,$60,$80,$A0,$C0,$E0
        .byte   $00,$20,$40,$60,$80,$A0,$C0,$E0
        .byte   $00,$20,$40,$60,$80,$A0,$C0,$E0
        .byte   $00,$20,$40,$60,$80,$A0,$C0,$E0
        .byte   $00,$20,$40,$60,$80,$A0,$C0,$E0
        .byte   $00,$20,$40,$60,$80,$A0,$C0,$E0
        .byte   $00,$20,$40,$60,$80,$A0,$C0,$E0
        .byte   $00,$20,$40,$60,$80,$A0,$C0,$E0
r14C0:  .byte   $0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C
        .byte   $0D,$0D,$0D,$0D,$0D,$0D,$0D,$0D
        .byte   $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E
        .byte   $0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F
        .byte   $10,$10,$10,$10,$10,$10,$10,$10
        .byte   $11,$11,$11,$11,$11,$11,$11,$11
        .byte   $12,$12,$12,$12,$12,$12,$12,$12
        .byte   $13,$13,$13,$13,$13,$13,$13,$13
r1500:  .byte   $60,$50,$50,$F0,$10,$10,$10,$F0
        .byte   $10,$10,$10,$10,$10,$10,$10,$10
        .byte   $10,$10,$50,$50,$10,$10,$10,$10
        .byte   $10,$10,$10,$10,$50,$50,$10,$10
        .byte   $50,$50,$10,$10,$10,$10,$10,$10
        .byte   $10,$10,$10,$10,$10,$10,$30,$A0
char_colors:
        .byte   $60,$60,$60,$60,$60,$60,$60,$60
        .byte   $60,$60,$60,$60,$60,$60,$60,$60
        .byte   $60,$60,$60,$60,$60,$60,$60,$60
        .byte   $60,$60,$10,$10,$10,$10,$10,$B0
        .byte   $10,$10,$10,$10,$10,$10,$10,$10
        .byte   $10,$10,$10,$10,$10,$10,$10,$10
        .byte   $10,$10,$10,$10,$10,$10,$10,$10
        .byte   $10,$10,$10,$10,$10,$10,$10,$10
        .byte   $10,$10,$10,$10,$10,$10,$10,$10
        .byte   $10,$10,$10,$10,$10,$10,$10,$10
        .byte   $10,$10,$10,$10,$10,$10,$10,$10
        .byte   $10,$10,$10,$10,$10,$10,$10,$10
        .byte   $10,$10,$10,$10,$10,$10,$10,$10
        .byte   $10,$10,$10,$10,$10,$10,$10,$10
        .byte   $10,$10,$10,$10,$10,$10,$10,$10
        .byte   $10,$10,$10,$10,$10,$10,$10,$10
bitmap_x_offset_lo:
        .byte   $00,$08,$10,$18,$20,$28,$30,$38
        .byte   $40,$48,$50,$58,$60,$68,$70,$78
        .byte   $80,$88,$90,$98,$A0,$A8,$B0,$B8
        .byte   $C0,$C8,$D0,$D8,$E0,$E8,$F0,$F8
        .byte   $00,$08,$10,$18,$20,$28,$30,$38
bitmap_x_offset_hi:
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $01,$01,$01,$01,$01,$01,$01,$01
scrmem_y_offset_lo:
        .byte   $00,$28
scrmem_y_offset_lo_02:
        .byte   $50,$78,$A0,$C8,$F0,$18,$40,$68
        .byte   $90,$B8,$E0,$08,$30,$58,$80,$A8
        .byte   $D0,$F8,$20,$48,$70,$98,$C0
scrmem_y_offset_hi:
        .byte   $04,$04
scrmem_y_offset_hi_02:
        .byte   $04,$04,$04,$04,$04,$05,$05,$05
        .byte   $05,$05,$05,$06,$06,$06,$06,$06
        .byte   $06,$06,$07,$07,$07,$07,$07
r1632:  .byte   $A0,$BB,$BA,$AF,$C0
r1637:  .byte   $02
w1638:  .byte   $FF
r1639:  .byte   $10
