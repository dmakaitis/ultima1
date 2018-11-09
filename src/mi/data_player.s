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
.export mi_player_current_vehicle
.export mi_player_enemy_vessels
.export mi_player_equipped_armor
.export mi_player_equipped_spell
.export mi_player_equipped_weapon
.export mi_player_experience
.export mi_player_food
.export mi_player_gems
.export mi_player_hits
.export mi_player_intelligence
.export mi_player_inventory_armor
.export mi_player_inventory_spells
.export mi_player_inventory_vehicles
.export mi_player_inventory_weapons
.export mi_player_money
.export mi_player_name
.export mi_player_race
.export mi_player_random_seed
.export mi_player_sex
.export mi_player_sound_flag
.export mi_player_strength
.export mi_player_wisdom

.export mi_player_position_x
.export mi_player_position_y

.export w824F
.export w8250
.export w8259

        .setcpu "6502"

.segment "DATA_PLAYER"

mi_player_save_data:
        .byte   $CA,$01,$00,$00,$FF
mi_player_sound_flag:
        .byte   $FF
mi_player_position_x:
        .byte   $20
mi_player_position_y:
        .byte   $20
mi_player_gems:
        .byte   $00,$00,$00,$00
mi_player_equipped_spell:
        .byte   $00
mi_player_equipped_weapon:
        .byte   $00
mi_player_equipped_armor:
        .byte   $00
mi_player_current_vehicle:
        .byte   $00
mi_player_inventory_armor:
        .byte   $01,$01,$01,$01,$01,$01
mi_player_inventory_weapons:
        .byte   $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
mi_player_inventory_spells:
        .byte   $01,$03,$03,$03,$00,$03,$03,$03,$03,$03,$03
mi_player_inventory_vehicles:
        .byte   $01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00
        .byte   $00,$00,$00,$FF,$FF,$FF,$FF,$00
mi_player_enemy_vessels:
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
