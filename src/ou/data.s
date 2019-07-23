;-------------------------------------------------------------------------------
;
; data.s
;
; Data provided in the OU module.
;
;-------------------------------------------------------------------------------

.include "mi.inc"

.export command_routine_table
.export tile_descriptions
.export blocked_messages
.export signpost_text
.export world_signposts
.export signpost_attributes
.export signpost_quests
.export weapon_ranges
.export total_player_vechicles
.export signpost_cache
.export tile_cache
.export wA144
.export wA145

.import cmd_attack
.import cmd_board
.import cmd_cast
.import cmd_east
.import cmd_enter
.import cmd_fire
.import cmd_inform_search
.import cmd_north
.import cmd_pass
.import cmd_quit_save
.import cmd_ready
.import cmd_south
.import cmd_west
.import cmd_xit

.data

command_routine_table:
        .addr   cmd_north
        .addr   cmd_south
        .addr   cmd_east
        .addr   cmd_west
        .addr   cmd_pass
        .addr   cmd_attack
        .addr   cmd_board
        .addr   cmd_cast
        .addr   mi_cmd_invalid
        .addr   cmd_enter
        .addr   cmd_fire
        .addr   mi_cmd_invalid
        .addr   mi_cmd_invalid
        .addr   cmd_inform_search
        .addr   mi_cmd_invalid
        .addr   mi_cmd_noise
        .addr   mi_cmd_invalid
        .addr   cmd_quit_save
        .addr   cmd_ready
        .addr   mi_cmd_invalid
        .addr   mi_cmd_invalid
        .addr   mi_cmd_invalid
        .addr   mi_cmd_invalid
        .addr   cmd_xit
        .addr   mi_cmd_ztats



tile_descriptions:
        .byte   "You are at se",$E1
        .byte   "You are in the lands~of",$A0
        .byte   "You are in the wood",$F3



blocked_messages:
        .byte   "You can't walk on water",$A1
        .byte   "Mountains are impassable",$A1
        .byte   "Aircars can't pass woods",$A1
        .byte   "s like water",$A1



signpost_text:
        .byte   "~~~",$7F
        .byte   $07,"The sign reads:~~",$7F
        .byte   $04,$22,"GO EAST TO GO EAST!",$A2

        .byte   "~~~",$7F
        .byte   $05,"The grave is marked:~~",$7F
        .byte   $09,$22,"VAE VICTIS",$A2

        .byte   "~~~",$7F
        .byte   $07,"The sign reads:~~",$7F
        .byte   $06,$22,"OMNIA MUTANTUR!",$A2

        .byte   "~~",$7F
        .byte   $07,"The sign reads:~~",$7F
        .byte   $07,$22,"ULTIMA THULE!",$22,"~~",$7F
        .byte   $02,"The sky grows dark, and a~",$7F
        .byte   $02,"strong magic engulfs you",$A1

        .byte   "~~~",$7F
        .byte   $08,"A sign reads:~~",$7F
        .byte   $02,$22,"FORTES FORTUNA ADIUVAT!",$A2
        
        .byte   $7F
        .byte   $08,"On a pedestal,~",$7F
        .byte   $05,"these words appear:~~",$7F
        .byte   $03,$22,"MY NAME IS OZYMANDIAS,~",$7F
        .byte   $08,"KING OF KINGS:~",$7F
        .byte   $06,"LOOK ON MY WORKS,~",$7F
        .byte   $03,"YE MIGHTY, AND DESPAIR!",$22,"~~",$7F
        .byte   $03,"Nothing beside remains.~",$7F
        .byte   $02,"You feel a strange force",$A1

        .byte   "~~~~",$7F
        .byte   $03,"You feel a strong magic~",$7F
        .byte   $07,"surrounding you",$A1

        .byte   "~~~",$7F
        .byte   $04,"You hear someone say,~~ ",$22,"TURRIS-SCIENTIA-MAGNOPERE",$A2



world_signposts:
        .byte   $42,$41,$2D,$2C,$18,$17,$03,$02

signpost_attributes:
        .byte   $00,$03,$04,$03,$00,$05,$02,$06

signpost_quests:
        .byte   $FF,$06,$FF,$04,$FF,$02,$FF,$00



weapon_ranges:
        .byte   $01,$01,$01,$01,$00,$01,$01,$03
        .byte   $00,$00,$00,$01,$03,$01,$03,$03



signpost_cache:
        .byte   $00
tile_cache:
        .byte   $00



total_player_vechicles:
        .byte   $DE



wA144:  .byte   $02
wA145:  .byte   $4E,$06,$AB,$09,$19
