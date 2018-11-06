;-------------------------------------------------------------------------------
;
; data_player.s
;
; Data block that defines the player save data.
;
;-------------------------------------------------------------------------------

.export mi_player_save_data
.export mi_player_agility
.export mi_player_class
.export mi_player_experience
.export mi_player_food
.export mi_player_hits
.export mi_player_intelligence
.export mi_player_money
.export mi_player_name
.export mi_player_race
.export mi_player_random_seed
.export mi_player_sex
.export mi_player_sound_flag
.export mi_player_strength
.export mi_player_wisdom

.export mi_r81E8
.export mi_r81E9
.export mi_w81EE
.export mi_w81EF
.export mi_w81F0
.export mi_w81F1
.export mi_w81F8
.export mi_w8213

        .setcpu "6502"

.segment "DATA_PLAYER"

mi_player_save_data:
        .byte   $CA,$01,$00,$00,$FF
mi_player_sound_flag:
        .byte   $FF
mi_r81E8:
        .byte   $20
mi_r81E9:
        .byte   $20,$00,$00,$00,$00
mi_w81EE:
        .byte   $00
mi_w81EF:
        .byte   $00
mi_w81F0:
        .byte   $00
mi_w81F1:
        .byte   $00,$01,$01,$01,$01,$01,$01
mi_w81F8:
        .byte   $01,$01,$01,$01,$01,$01,$01,$01
        .byte   $01,$01,$01,$01,$01,$01,$01,$01
        .byte   $01,$03,$03,$03,$00,$03,$03,$03
        .byte   $03,$03,$03
mi_w8213:
        .byte   $01,$01,$01,$01,$01,$01,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$FF,$FF,$FF,$FF,$00
        .byte   $00
mi_player_sex:
        .byte   $01
mi_player_name:
        .byte   $47,$6C,$69,$6E,$64,$61,$00,$00
        .byte   $00,$00,$00,$00,$00,$00
mi_player_hits:
        .byte   $84,$03
mi_player_strength:
        .byte   $5A,$00
mi_player_agility:
        .byte   $5A,$00
mi_player_stamina:
        .byte   $0F,$00
mi_player_charisma:
        .byte   $0F,$00
mi_player_wisdom:
        .byte   $32,$00
mi_player_intelligence:
        .byte   $0F,$00
mi_player_money:
        .byte   $38,$08
mi_player_race:
        .byte   $02,$00
mi_player_class:
        .byte   $02,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$95
mi_player_food:
        .byte   $59,$00
mi_player_experience:
        .byte   $37,$02
        .byte   $E8,$03,$E8,$03,$00,$FF
mi_player_random_seed:
        .byte   $EF,$BE,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00

