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
.export r9EEC
.export rA119
.export rA121
.export rA129
.export weapon_ranges
.export total_player_vechicles
.export wA141
.export wA142
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



r9EEC:  .byte   $7E,$7E,$7E,$7F,$07,$54,$68,$65
        .byte   $20,$73,$69,$67,$6E,$20,$72,$65
        .byte   $61,$64,$73,$3A,$7E,$7E,$7F,$04
        .byte   $22,$47,$4F,$20,$45,$41,$53,$54
        .byte   $20,$54,$4F,$20,$47,$4F,$20,$45
        .byte   $41,$53,$54,$21,$A2,$7E,$7E,$7E
        .byte   $7F,$05,$54,$68,$65,$20,$67,$72
        .byte   $61,$76,$65,$20,$69,$73,$20,$6D
        .byte   $61,$72,$6B,$65,$64,$3A,$7E,$7E
        .byte   $7F,$09,$22,$56,$41,$45,$20,$56
        .byte   $49,$43,$54,$49,$53,$A2,$7E,$7E
        .byte   $7E,$7F,$07,$54,$68,$65,$20,$73
        .byte   $69,$67,$6E,$20,$72,$65,$61,$64
        .byte   $73,$3A,$7E,$7E,$7F,$06,$22,$4F
        .byte   $4D,$4E,$49,$41,$20,$4D,$55,$54
        .byte   $41,$4E,$54,$55,$52,$21,$A2,$7E
        .byte   $7E,$7F,$07,$54,$68,$65,$20,$73
        .byte   $69,$67,$6E,$20,$72,$65,$61,$64
        .byte   $73,$3A,$7E,$7E,$7F,$07,$22,$55
        .byte   $4C,$54,$49,$4D,$41,$20,$54,$48
        .byte   $55,$4C,$45,$21,$22,$7E,$7E,$7F
        .byte   $02,$54,$68,$65,$20,$73,$6B,$79
        .byte   $20,$67,$72,$6F,$77,$73,$20,$64
        .byte   $61,$72,$6B,$2C,$20,$61,$6E,$64
        .byte   $20,$61,$7E,$7F,$02,$73,$74,$72
        .byte   $6F,$6E,$67,$20,$6D,$61,$67,$69
        .byte   $63,$20,$65,$6E,$67,$75,$6C,$66
        .byte   $73,$20,$79,$6F,$75,$A1,$7E,$7E
        .byte   $7E,$7F,$08,$41,$20,$73,$69,$67
        .byte   $6E,$20,$72,$65,$61,$64,$73,$3A
        .byte   $7E,$7E,$7F,$02,$22,$46,$4F,$52
        .byte   $54,$45,$53,$20,$46,$4F,$52,$54
        .byte   $55,$4E,$41,$20,$41,$44,$49,$55
        .byte   $56,$41,$54,$21,$A2,$7F,$08,$4F
        .byte   $6E,$20,$61,$20,$70,$65,$64,$65
        .byte   $73,$74,$61,$6C,$2C,$7E,$7F,$05
        .byte   $74,$68,$65,$73,$65,$20,$77,$6F
        .byte   $72,$64,$73,$20,$61,$70,$70,$65
        .byte   $61,$72,$3A,$7E,$7E,$7F,$03,$22
        .byte   $4D,$59,$20,$4E,$41,$4D,$45,$20
        .byte   $49,$53,$20,$4F,$5A,$59,$4D,$41
        .byte   $4E,$44,$49,$41,$53,$2C,$7E,$7F
        .byte   $08,$4B,$49,$4E,$47,$20,$4F,$46
        .byte   $20,$4B,$49,$4E,$47,$53,$3A,$7E
        .byte   $7F,$06,$4C,$4F,$4F,$4B,$20,$4F
        .byte   $4E,$20,$4D,$59,$20,$57,$4F,$52
        .byte   $4B,$53,$2C,$7E,$7F,$03,$59,$45
        .byte   $20,$4D,$49,$47,$48,$54,$59,$2C
        .byte   $20,$41,$4E,$44,$20,$44,$45,$53
        .byte   $50,$41,$49,$52,$21,$22,$7E,$7E
        .byte   $7F,$03,$4E,$6F,$74,$68,$69,$6E
        .byte   $67,$20,$62,$65,$73,$69,$64,$65
        .byte   $20,$72,$65,$6D,$61,$69,$6E,$73
        .byte   $2E,$7E,$7F,$02,$59,$6F,$75,$20
        .byte   $66,$65,$65,$6C,$20,$61,$20,$73
        .byte   $74,$72,$61,$6E,$67,$65,$20,$66
        .byte   $6F,$72,$63,$65,$A1,$7E,$7E,$7E
        .byte   $7E,$7F,$03,$59,$6F,$75,$20,$66
        .byte   $65,$65,$6C,$20,$61,$20,$73,$74
        .byte   $72,$6F,$6E,$67,$20,$6D,$61,$67
        .byte   $69,$63,$7E,$7F,$07,$73,$75,$72
        .byte   $72,$6F,$75,$6E,$64,$69,$6E,$67
        .byte   $20,$79,$6F,$75,$A1,$7E,$7E,$7E
        .byte   $7F,$04,$59,$6F,$75,$20,$68,$65
        .byte   $61,$72,$20,$73,$6F,$6D,$65,$6F
        .byte   $6E,$65,$20,$73,$61,$79,$2C,$7E
        .byte   $7E,$20,$22,$54,$55,$52,$52,$49
        .byte   $53,$2D,$53,$43,$49,$45,$4E,$54
        .byte   $49,$41,$2D,$4D,$41,$47,$4E,$4F
        .byte   $50,$45,$52,$45,$A2



rA119:  .byte   $42,$41,$2D,$2C,$18,$17,$03,$02
rA121:  .byte   $00,$03,$04,$03,$00,$05,$02,$06
rA129:  .byte   $FF,$06,$FF,$04,$FF,$02,$FF,$00
weapon_ranges:
        .byte   $01,$01,$01,$01,$00,$01,$01,$03
        .byte   $00,$00,$00,$01,$03,$01,$03,$03
wA141:  .byte   $00
wA142:  .byte   $00

total_player_vechicles:
        .byte   $DE

wA144:  .byte   $02
wA145:  .byte   $4E,$06,$AB,$09,$19
