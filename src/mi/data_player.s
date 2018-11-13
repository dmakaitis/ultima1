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
.export mi_player_continent
.export mi_player_continent_mask
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
.export mi_player_stamina
.export mi_player_strength
.export mi_player_wisdom

.export mi_player_position_x
.export mi_player_position_y

.export mi_player_820B
.export mi_player_821E
.export mi_player_8226
.export mi_player_8227
.export mi_player_8228
.export mi_player_8229
.export mi_player_822A
.export mi_player_8262
.export mi_player_8263
.export mi_player_8267
.export mi_player_8268
.export mi_player_826b
.export mi_player_826c
.export mi_player_826d
.export mi_player_82bb
.export mi_player_82bc
.export mi_player_82bd
.export mi_player_830c
.export mi_player_830d
.export mi_player_835b
.export mi_player_835c
.export mi_player_835d

.export w824F
.export w8250
.export w8259

        .setcpu "6502"

.segment "DATA_PLAYER"

mi_player_save_data:
        .byte   $CA,$01

mi_player_continent:
        .byte   $00
mi_player_continent_mask:
        .byte   $00,$FF

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
        .byte   $01,$03,$03
mi_player_820B:
        .byte   $03,$00,$03,$03,$03,$03,$03,$03

mi_player_inventory_vehicles:
        .byte   $01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00

mi_player_821E:
        .byte   $00,$00,$00,$00,$00
        .byte   $00,$00,$00
mi_player_8226:
        .byte   $FF
mi_player_8227:
        .byte   $FF
mi_player_8228:
        .byte   $FF
mi_player_8229:
        .byte   $FF
mi_player_822A:
        .byte   $00
mi_player_enemy_vessels:
        .byte   $00
mi_player_sex:
        .byte   $01
mi_player_name:
        .byte   $47,$6C,$69,$6E,$64,$61,$00,$00,$00,$00,$00,$00,$00,$00
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
        .byte   $E8,$03,$E8,$03
mi_player_8262:
        .byte   $00
mi_player_8263:
        .byte   $FF
mi_player_random_seed:
        .word   $BEEF
        .byte   $00
mi_player_8267:
        .byte   $00
mi_player_8268:
        .byte   $00,$00,$00
mi_player_826b:
        .byte   $00
mi_player_826c:
        .byte   $00
mi_player_826d:
        .byte   $00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00
mi_player_82bb:
        .byte   $00
mi_player_82bc:
        .byte   $00
mi_player_82bd:
        .byte   $00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
mi_player_830c:
        .byte   $00
mi_player_830d:
        .byte   $00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00
mi_player_835b:
        .byte   $00
mi_player_835c:
        .byte   $00
mi_player_835d:
        .byte   $00,$00,$00,$00,$00,$00,$00
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
