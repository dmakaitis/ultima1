;-------------------------------------------------------------------------------
;
; data.s
;
; Data segment of in.prg.
;
;-------------------------------------------------------------------------------

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

.export bird_body
.export bird_body_final
.export bird_head
.export bird_head_final


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

bird_body:  
        .incbin "intro_bird_body0.bin"
        .incbin "intro_bird_body1.bin"
        .incbin "intro_bird_body2.bin"

        .byte   $00,$00,$00,$00,$00,$00,$00,$00

bird_head:  
        .incbin "intro_bird_head0.bin"
        .incbin "intro_bird_head1.bin"
        .incbin "intro_bird_head2.bin"

        .byte   $00,$00,$00,$00,$00,$00,$00,$00

bird_body_final:
        .incbin "intro_bird_body3.bin"

bird_head_final:
        .incbin "intro_bird_head3.bin"

intro_backdrop:
        
        .incbin "intro_backdrop.bin"

        .byte   $b0
