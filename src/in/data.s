;-------------------------------------------------------------------------------
;
; data.s
;
; Data segment of in.prg.
;
;-------------------------------------------------------------------------------




.export horse_frame_ptrs
.export horse_anim_frames
.export d7B3B
.export d7B6B
.export d7A0B
.export d7AA3
.export d7835
.export d780D
.export d76B5
.export d78A0
.export title_logo
.export studio_logo
.export d7518
.export d7684
.export d765D
.export intro_backdrop

.data

horse_anim_frames:
        .byte   $00,$01,$00,$01,$02,$01,$00,$01
        .byte   $02,$03,$04,$03,$04,$03,$02,$01
        .byte   $00,$05,$06,$05,$06,$05,$06,$FF

studio_logo:
        .incbin "intro_studio.bin"

        .byte   $00,$00,$00,$00,$00,$00,$00

title_logo:
        .incbin "intro_title.bin"

        .byte   $C6,$C6,$C6,$B1,$8D,$A0,$C8,$C5

d7518:  .byte   $E0,$C0,$00,$7C,$70,$00,$FF,$FC
        .byte   $00,$FF,$FF,$00,$6F,$ED,$80

horse_frame_0:
        .incbin "intro_horse0.bin"

horse_frame_1:
        .incbin "intro_horse1.bin"

horse_frame_2:
        .incbin "intro_horse2.bin"

horse_frame_3:
        .incbin "intro_horse3.bin"

horse_frame_4:
        .incbin "intro_horse4.bin"

horse_frame_5:
        .incbin "intro_horse5.bin"

horse_frame_6:
        .incbin "intro_horse6.bin"

        .byte   $B0,$B0

horse_frame_ptrs:
        .addr   horse_frame_0
        .addr   horse_frame_1
        .addr   horse_frame_2
        .addr   horse_frame_3
        .addr   horse_frame_4
        .addr   horse_frame_5
        .addr   horse_frame_6

d765D:  .byte   $1B,$00,$00,$0F,$00,$00,$03,$00
        .byte   $00,$03,$00,$00,$1B,$00,$00,$1B
        .byte   $00,$00,$3E,$C0,$00,$39,$E0,$00
        .byte   $3B,$40,$00,$EB,$00,$00,$7F,$80
        .byte   $00,$A2,$80,$00,$24,$80,$00

d7684:  .byte   $01,$80,$00,$07,$80,$00,$0D,$80
        .byte   $00,$01,$80,$00,$0D,$80,$00,$0D
        .byte   $80,$00,$1F,$60,$00,$1C,$F0,$00
        .byte   $1D,$A0,$00,$75,$80,$00,$BF,$C0
        .byte   $00,$49,$20,$00,$51,$40,$00,$00
        .byte   $00,$00,$18,$D8,$00,$00,$00,$00
        .byte   $00

d76B5:  .byte   $00,$04,$00,$00,$0C,$00,$00,$1C
        .byte   $00,$00,$1C,$00,$00,$3C,$00,$00
        .byte   $3C,$00,$00,$3C,$00,$00,$7C,$00
        .byte   $00,$74,$00,$00,$74,$00,$00,$74
        .byte   $00,$00,$74,$00,$00,$74,$00,$00
        .byte   $74,$00,$00,$74,$00,$00,$74,$00
        .byte   $00,$74,$00,$00,$74,$00,$00,$74
        .byte   $00,$00,$74,$00,$00,$74,$00,$00
        .byte   $74,$00,$00,$74,$00,$00,$74,$00
        .byte   $00,$74,$00,$00,$74,$00,$00,$74
        .byte   $00,$00,$74,$00,$00,$74,$00,$00
        .byte   $74,$00,$00,$74,$00,$00,$74,$00
        .byte   $00,$74,$00,$00,$74,$00,$00,$74
        .byte   $00,$00,$74,$00,$00,$74,$00,$00
        .byte   $74,$00,$00,$74,$00,$00,$74,$00
        .byte   $00,$74,$00,$00,$74,$00,$00,$74
        .byte   $00,$00,$74,$00,$00,$74,$00,$00
        .byte   $74,$00,$00,$74,$00,$00,$74,$00
        .byte   $00,$74,$00,$00,$74,$00,$00,$74
        .byte   $00,$00,$74,$00,$00,$74,$00,$00
        .byte   $74,$00,$00,$74,$00,$00,$74,$00
        .byte   $00,$74,$00,$00,$74,$00,$00,$74

d7765:  .byte   $00,$00,$74,$00,$00,$74,$00,$00
        .byte   $74,$00,$00,$74,$00,$00,$74,$00
        .byte   $00,$74,$00,$00,$74,$00,$00,$74
        .byte   $00,$00,$74,$00,$00,$74,$00,$00
        .byte   $74,$00,$00,$74,$00,$00,$74,$00
        .byte   $00,$74,$00,$00,$74,$00,$00,$74
        .byte   $00,$00,$74,$00,$07,$FF,$C0,$0F
        .byte   $D7,$E0,$19,$93,$30,$1B,$FF,$B0
        .byte   $1F,$39,$F0,$0F,$BB,$E0,$00,$7C
        .byte   $00,$00,$10,$00,$00,$E8,$00,$00
        .byte   $D8,$00,$01,$B0,$00,$01,$1C,$00
        .byte   $01,$AE,$00,$01,$3E,$00,$00,$7F
        .byte   $00,$00,$7F,$00,$00,$7B,$00,$00
        .byte   $37,$00,$00,$0F,$00,$00,$0F,$80
        .byte   $00,$0F,$80,$00,$0F,$80,$00,$0F
        .byte   $80,$00,$0F,$80,$00,$0F,$80,$00
        .byte   $1F,$80,$00,$1F,$80,$00,$1F,$80
        .byte   $00,$1F,$80,$00,$1F,$80,$00,$1F
        .byte   $80,$00,$1F,$80,$00,$1F,$80,$00
        .byte   $1F,$80,$00,$1F,$80,$00,$1F,$80
        .byte   $00,$1F,$80,$00,$00,$00,$00,$00

d780D:  .byte   $00,$7C,$00,$00,$10,$00,$00,$28
        .byte   $00,$00,$18,$00,$00,$30,$00,$00
        .byte   $18,$00,$00,$38,$00,$00,$7C,$00
        .byte   $00,$7C,$00,$00,$7C,$00,$00,$38
        .byte   $00,$00,$0F,$00,$00,$0F,$00,$00

d7835:  .byte   $00,$00,$00,$01,$20,$00,$03,$F0
        .byte   $00,$03,$F8,$00,$01,$F9,$80,$03
        .byte   $FF,$80,$01,$FF,$00,$00,$FE,$00
        .byte   $00,$7E,$00,$00,$3E,$00,$00,$1F
        .byte   $00,$00,$1F,$00,$00,$0F,$00,$00
        .byte   $0F,$00,$00,$0F,$00,$00,$0F,$80
        .byte   $00,$0F,$80,$00,$0F,$80,$00,$0F
        .byte   $80,$00,$0F,$80,$00,$1F,$80,$00
        .byte   $1F,$80,$00,$1F,$80,$00,$1F,$80
        .byte   $00,$1F,$80,$00,$1F,$80,$00,$1F
        .byte   $80,$00,$1F,$80,$00,$1F,$80,$00
        .byte   $1F,$80,$00,$1F,$80,$00,$1F,$80
        .byte   $00,$1F,$80,$78,$00,$00,$FC,$00
        .byte   $00,$5F,$F8

d78A0:  .byte   $FF,$F9,$FF,$FF,$F1,$FF,$FF,$E1
        .byte   $FF,$FF,$C1,$FF,$FF,$C1,$FF,$FF
        .byte   $81,$FF,$FF,$81,$FF,$FF,$81,$FF
        .byte   $FF,$81,$FF,$FF,$81,$FF,$FF,$81
        .byte   $FF,$FF,$81,$FF,$FF,$81,$FF,$FF
        .byte   $81,$FF,$FF,$81,$FF,$FF,$81,$FF
        .byte   $FF,$81,$FF,$FF,$81,$FF,$FF,$81
        .byte   $FF,$FF,$81,$FF,$FF,$81,$FF,$FF
        .byte   $81,$FF,$FF,$81,$FF,$FF,$81,$FF
        .byte   $FF,$81,$FF,$FF,$81,$FF,$FF,$81
        .byte   $FF,$FF,$81,$FF,$FF,$81,$FF,$FF
        .byte   $81,$FF,$FF,$81,$FF,$FF,$81,$FF
        .byte   $FF,$81,$FF,$FF,$81,$FF,$FF,$81
        .byte   $FF,$FF,$81,$FF,$FF,$81,$FF,$FF
        .byte   $81,$FF,$FF,$81,$FF,$FF,$81,$FF
        .byte   $FF,$81,$FF,$FF,$81,$FF,$FF,$81
        .byte   $FF,$FF,$81,$FF,$FF,$81,$FF,$FF
        .byte   $81,$FF,$FF,$81,$FF,$FF,$81,$FF
        .byte   $FF,$81,$FF,$FF,$81,$FF,$FF,$81
        .byte   $FF,$FF,$81,$FF,$FF,$81,$FF,$FF
        .byte   $81,$FF,$FF,$81,$FF,$FF,$81,$FF
        .byte   $FF,$81,$FF,$FF,$81,$FF,$FF,$81
        .byte   $FF,$FF,$81,$FF,$FF,$81,$FF,$FF
        .byte   $81,$FF,$FF,$81,$FF,$FF,$81,$FF
        .byte   $FF,$81,$FF,$FF,$81,$FF,$FF,$81
        .byte   $FF,$FF,$81,$FF,$FF,$81,$FF,$FF
        .byte   $81,$FF,$FF,$81,$FF,$FF,$81,$FF
        .byte   $FF,$81,$FF,$FF,$81,$FF,$FF,$81
        .byte   $FF,$FF,$81,$FF,$FF,$81,$FF,$F8
        .byte   $00,$3F,$F0,$00,$1F,$E0,$00,$0F
        .byte   $E0,$00,$0F,$E0,$00,$0F,$F0,$00
        .byte   $1F,$FF,$83,$FF,$FF,$EF,$FF,$FF
        .byte   $07,$FF,$FF,$07,$FF,$FE,$0F,$FF
        .byte   $FE,$03,$FF,$FE,$01,$FF,$FE,$01
        .byte   $FF,$FF,$80,$FF,$FF,$E0,$FF,$FF
        .byte   $F0,$FF,$FF,$F0,$FF,$FF,$F0,$FF
        .byte   $FF,$F0,$7F,$FF,$F0,$7F,$FF,$F0
        .byte   $7F,$FF,$F0,$7F,$FF,$F0,$7F,$FF
        .byte   $F0,$7F,$FF,$E0,$7F,$FF,$E0,$7F
        .byte   $FF,$E0,$7F,$FF,$E0,$7F,$FF,$E0
        .byte   $7F,$FF,$E0,$7F,$FF,$E0,$7F,$FF
        .byte   $E0,$7F,$FF,$E0,$7F,$FF,$E0,$7F
        .byte   $FF,$E0,$7F,$FF,$E0,$7F,$FF,$E0
        .byte   $7F,$FF,$F0,$3F,$FF,$F0,$3F,$FF
        .byte   $F0,$3F,$FF,$F0,$3F,$FF,$F0,$3F
        .byte   $FF,$FF,$FF

d7A0B:  .byte   $20,$01,$F8,$F8,$0F,$F8,$FF,$3F
        .byte   $F0,$3E,$FF,$E0,$0D,$FF,$D8,$0F
        .byte   $FF,$BE,$0F,$FE,$7F,$0F,$FF,$F8
        .byte   $07,$FF,$C0,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$F8,$00,$07
        .byte   $FF,$E0,$07,$FC,$7C,$07,$FF,$BF
        .byte   $06,$FF,$DC,$07,$7F,$E0,$01,$7F
        .byte   $F0,$0C,$7F,$C0,$07,$7F,$C0,$00
        .byte   $7F,$00,$00,$1C,$00,$00,$FC,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$7C,$00,$07,$FF,$80,$0F
        .byte   $FF,$F0,$0F,$FF,$FF,$0F,$FF,$FC
        .byte   $0F,$FF,$E8,$07,$F8,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00

d7AA3:  .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$06
        .byte   $00,$00,$3E,$00,$00,$FE,$00,$00
        .byte   $06,$00,$00,$00,$13,$00,$00,$1A
        .byte   $00,$00,$11,$00,$00,$08,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$06
        .byte   $00,$00,$3E,$00,$00,$FE,$00,$00
        .byte   $06,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$06
        .byte   $00,$00,$3E,$00,$00,$FE,$00,$00
        .byte   $06,$00,$00,$00,$00,$00,$00,$09
        .byte   $80,$00,$0D,$00,$00,$08,$80,$00
        .byte   $04,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00

d7B3B:  .byte   $00,$01,$F0,$00,$3F,$F0,$00,$FF
        .byte   $F0,$01,$FF,$F0,$07,$FF,$F0,$0F
        .byte   $FF,$C0,$1F,$FE,$00,$7F,$FE,$00
        .byte   $00,$7C,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00

d7B6B:  .byte   $00,$07,$80,$00,$07,$E0,$00,$07
        .byte   $F0,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $28,$00,$00,$24,$00,$00,$28,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00

intro_backdrop:
        
        .incbin "intro_backdrop.bin"

        .byte   $b0
