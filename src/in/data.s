;-------------------------------------------------------------------------------
;
; data.s
;
; Data segment of in.prg.
;
;-------------------------------------------------------------------------------

.export d7B3B
.export d7B6B
.export d7A0B
.export d7AA3


.export intro_backdrop

.export studio_logo
.export title_logo

.export horse_frame_ptrs
.export horse_anim_frames

.export knight_frame_0
.export knight_frame_1
.export car

.export sword
.export sword_mask
.export sword_hand
.export hand

        .setcpu "6502"

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

car:
        .incbin "intro_car.bin"

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

knight_frame_0:
        .incbin "intro_knight0.bin"

knight_frame_1:
        .incbin "intro_knight1.bin"

        .byte   $00,$00,$00,$18,$D8,$00,$00,$00
        .byte   $00,$00

sword:  
        .incbin "intro_sword.bin"

        .byte   $00,$00

sword_hand:
        .incbin "intro_sword_hand.bin"

        .byte   $00

hand:  
        .incbin "intro_hand.bin"

        .byte   $78,$00,$00,$FC,$00,$00,$5F,$F8

sword_mask:
        .incbin "intro_sword_mask.bin"

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
