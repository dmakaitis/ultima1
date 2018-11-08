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

.export r81EA
.export r81F2
.export r8208
.export r822B
.export w824F
.export w8250
.export w8259

        .setcpu "6502"

.segment "DATA_PLAYER"

mi_player_save_data:
        .byte   $CA,$01,$00,$00,$FF
mi_player_sound_flag:
        .byte   $FF
mi_r81E8:
        .byte   $20
mi_r81E9:
        .byte   $20
r81EA:
        .byte   $00,$00,$00,$00
mi_w81EE:
        .byte   $00
mi_w81EF:
        .byte   $00
mi_w81F0:
        .byte   $00
mi_w81F1:
        .byte   $00
r81F2:
        .byte   $01,$01,$01,$01,$01,$01
mi_w81F8:
        .byte   $01,$01,$01,$01,$01,$01,$01,$01
        .byte   $01,$01,$01,$01,$01,$01,$01,$01
r8208:
        .byte   $01,$03,$03,$03,$00,$03,$03,$03
        .byte   $03,$03,$03
mi_w8213:
        .byte   $01,$01,$01,$01,$01,$01,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$FF,$FF,$FF,$FF,$00
r822B:
        .byte   $00
mi_player_sex:
        .byte   $01
mi_player_name:
        .byte   $47,$6C,$69,$6E,$64,$61,$00,$00
        .byte   $00,$00,$00,$00,$00,$00
mi_player_hits:
        .word   $0384
mi_player_strength:
        .word   $005A
mi_player_agility:
        .word   $005A
mi_player_stamina:
        .word   $000F
mi_player_charisma:
        .word   $000F
mi_player_wisdom:
        .word   $0032
mi_player_intelligence:
        .word   $000F
mi_player_money:
        .word   $0838
mi_player_race:
        .byte   $02,$00
mi_player_class:
        .byte   $02,$00
w824F:  .byte   $00
w8250:  .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00
w8259:  .byte   $95
mi_player_food:
        .word   $0059
mi_player_experience:
        .word   $0237
        .byte   $E8,$03,$E8,$03,$00,$FF
mi_player_random_seed:
        .word   $BEEF
        .byte   $00,$00,$00,$00,$00,$00
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
        .byte   $00,$00,$00,$00,$00,$00,$00
        .byte   $00
