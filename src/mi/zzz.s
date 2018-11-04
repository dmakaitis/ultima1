.include "c64.inc"
.include "kernel.inc"
.include "hello.inc"
.include "st.inc"

.export mi_cursor_to_col_0
.export mi_cursor_to_col_1
.export mi_play_error_sound_and_read_input
.export mi_print_char
.export mi_print_crlf_col_1
.export mi_print_player_name
.export mi_print_short_int
.export mi_print_string_entry_x
.export mi_print_text
.export mi_print_text_at_x_y
.export mi_print_x_chars
.export mi_restore_text_area
.export mi_store_text_area

.export mi_j8C5E
.export mi_s84C0
.export mi_s8689

.export mi_attribute_table
.export mi_class_name_table
.export mi_race_name_table

.export mi_player_save_data
.export mi_player_agility
.export mi_player_class
.export mi_player_hits
.export mi_player_intelligence
.export mi_player_name
.export mi_player_race
.export mi_player_random_seed
.export mi_player_sex
.export mi_player_sound_flag
.export mi_player_strength
.export mi_player_wisdom

.export mi_current_attribute
.export mi_w85BE

dec_lo          := $3C
dec_mid         := $3D
dec_hi          := $3E
hex_lo          := $3F
hex_hi          := $40

zpA2            := $A2

        .setcpu "6502"

.segment        "CODE_ZZZ"

mi_main:jmp     do_mi_main

        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$03
        .byte   $00,$00,$00,$07,$1F,$7F,$FF,$FF
        .byte   $07,$3F,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $80,$F0,$FC,$FF,$FF,$FF,$FF,$FF
        .byte   $00,$00,$00,$80,$C0,$F0,$FC,$FF
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $03,$0F,$0F,$1F,$3F,$7F,$FF,$FF
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $80,$C0,$E0,$F0,$F0,$FC,$FE,$FE
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $01,$01,$02,$03,$07,$07,$07,$0F
        .byte   $7F,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $FE,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $00,$80,$80,$C0,$C0,$C0,$C0,$C0
        .byte   $0F,$0F,$0F,$0F,$0F,$1F,$1F,$1F
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $E0,$E0,$E0,$E0,$E0,$E0,$C0,$C0
        .byte   $1F,$1F,$1F,$0F,$0F,$0F,$0F,$0F
        .byte   $FF,$FF,$FF,$FF,$FE,$F8,$F0,$F0
        .byte   $FF,$FF,$F8,$80,$00,$00,$00,$00
        .byte   $FF,$FF,$7F,$3F,$1F,$17,$0F,$0F
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $FF,$FC,$F0,$E0,$E0,$E0,$E0,$C0
        .byte   $FF,$7F,$01,$00,$00,$00,$00,$00
        .byte   $FF,$FF,$FF,$7F,$7F,$1F,$1F,$1F
        .byte   $C0,$C0,$C0,$80,$80,$80,$80,$80
        .byte   $07,$07,$07,$07,$07,$03,$03,$03
        .byte   $F0,$E0,$E0,$E0,$E0,$E0,$F0,$F0
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $03,$07,$07,$07,$0F,$1F,$7F,$FF
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $C0,$C0,$C0,$C0,$C0,$E0,$F0,$F8
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $1F,$1F,$1F,$1F,$1F,$1F,$3F,$3F
        .byte   $80,$80,$80,$C0,$C0,$C0,$C0,$C0
        .byte   $03,$03,$03,$03,$03,$03,$03,$03
        .byte   $F0,$F8,$FC,$FE,$FF,$FF,$FF,$FF
        .byte   $01,$07,$0F,$1F,$FF,$FF,$FF,$FF
        .byte   $FF,$FF,$FF,$FE,$FE,$FC,$FC,$F8
        .byte   $B7,$83,$03,$01,$01,$00,$00,$00
        .byte   $FE,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $00,$80,$E0,$FF,$FF,$FF,$FF,$FF
        .byte   $3F,$7F,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $C0,$C0,$C0,$C0,$C0,$C0,$C0,$80
        .byte   $03,$03,$01,$01,$01,$00,$00,$00
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$7F,$7F
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $F8,$F8,$F0,$F0,$F8,$F8,$FF,$FF
        .byte   $00,$00,$00,$00,$00,$A1,$FF,$FF
        .byte   $7F,$7F,$7F,$7F,$FF,$FF,$FF,$FF
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $FF,$FF,$FF,$FF,$FE,$FE,$FC,$78
        .byte   $80,$80,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $3F,$3F,$1E,$1F,$0F,$0F,$0F,$07
        .byte   $FF,$F7,$CF,$CF,$CF,$C7,$C7,$CF
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FB
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $EF,$E1,$F1,$F1,$F3,$F3,$F3,$F7
        .byte   $F8,$F0,$F0,$E0,$E0,$E0,$E0,$E0
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $07,$07,$07,$07,$07,$03,$03,$03
        .byte   $FF,$FB,$EB,$FB,$FF,$FD,$FA,$FA
        .byte   $EF,$52,$52,$52,$E2,$7E,$E7,$A4
        .byte   $79,$79,$11,$11,$11,$17,$FC,$92
        .byte   $FF,$35,$01,$05,$15,$7F,$CD,$4D
        .byte   $FF,$9F,$AF,$BF,$BF,$FF,$EF,$5F
        .byte   $E0,$E0,$E0,$E0,$C0,$C0,$C0,$C0
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $03,$01,$01,$00,$00,$00,$00,$00
        .byte   $FF,$FF,$FF,$FF,$7F,$7F,$3F,$1F
        .byte   $A4,$EC,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $96,$96,$97,$EF,$FF,$FF,$FF,$FF
        .byte   $49,$CB,$CF,$7F,$FF,$FF,$FF,$FF
        .byte   $7F,$FF,$FF,$FF,$FE,$FC,$F8,$F0
        .byte   $80,$80,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $0F,$07,$03,$00,$00,$00,$00,$00
        .byte   $FF,$FF,$FF,$FF,$3F,$0F,$00,$00
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$00,$00
        .byte   $FF,$FF,$FF,$FE,$FC,$F0,$00,$00
        .byte   $E0,$C0,$80,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
mi_race_name_table:
        .byte   "lizar"
        .byte   $E4
        .byte   "huma"
        .byte   $EE
        .byte   "el"
        .byte   $E6
        .byte   "dwar"
        .byte   $E6
        .byte   "bobbi"
        .byte   $F4
        .byte   $68,$61,$6E,$64,$F3,$64,$61,$67
        .byte   $67,$65,$F2,$6D,$61,$63,$E5,$61
        .byte   $78,$E5,$72,$6F,$70,$65,$20,$26
        .byte   $20,$73,$70,$69,$6B,$65,$F3,$73
        .byte   $77,$6F,$72,$E4,$67,$72,$65,$61
        .byte   $74,$20,$73,$77,$6F,$72,$E4,$62
        .byte   $6F,$77,$20,$26,$20,$61,$72,$72
        .byte   $6F,$77,$F3,$61,$6D,$75,$6C,$65
        .byte   $F4,$77,$61,$6E,$E4,$73,$74,$61
        .byte   $66,$E6,$74,$72,$69,$61,$6E,$67
        .byte   $6C,$E5,$70,$69,$73,$74,$6F,$EC
        .byte   $6C,$69,$67,$68,$74,$20,$73,$77
        .byte   $6F,$72,$E4,$70,$68,$61,$7A,$6F
        .byte   $F2,$62,$6C,$61,$73,$74,$65,$F2
        .byte   $68,$61,$6E,$64,$F3,$64,$61,$67
        .byte   $67,$65,$F2,$6D,$61,$63,$E5,$61
        .byte   $78,$E5,$72,$6F,$70,$E5,$73,$77
        .byte   $6F,$72,$E4,$67,$20,$73,$77,$6F
        .byte   $72,$E4,$62,$6F,$F7,$61,$6D,$75
        .byte   $6C,$65,$F4,$77,$61,$6E,$E4,$73
        .byte   $74,$61,$66,$E6,$74,$72,$69,$61
        .byte   $6E,$67,$6C,$E5,$70,$69,$73,$74
        .byte   $6F,$EC,$6C,$20,$73,$77,$6F,$72
        .byte   $E4,$70,$68,$61,$7A,$6F,$F2,$62
        .byte   $6C,$61,$73,$74,$65,$F2
mi_attribute_table:
        .byte   "Hit point"

        .byte   $F3
        .byte   "Strengt"
        .byte   $E8
        .byte   "Agilit"
        .byte   $F9
        .byte   "Stamin"
        .byte   $E1
        .byte   "Charism"
        .byte   $E1
        .byte   "Wisdo"
        .byte   $ED
        .byte   "Intelligenc"

        .byte   $E5
        .byte   $47,$6F,$6C,$E4,$52,$61,$63,$E5
        .byte   $54,$79,$70,$E5,$50,$72,$61,$79
        .byte   $65,$F2,$4F,$70,$65,$EE,$55,$6E
        .byte   $6C,$6F,$63,$EB,$4D,$61,$67,$69
        .byte   $63,$20,$4D,$69,$73,$73,$69,$6C
        .byte   $E5,$53,$74,$65,$61,$EC,$4C,$61
        .byte   $64,$64,$65,$72,$20,$44,$6F,$77
        .byte   $EE,$4C,$61,$64,$64,$65,$72,$20
        .byte   $55,$F0,$42,$6C,$69,$6E,$EB,$43
        .byte   $72,$65,$61,$74,$E5,$44,$65,$73
        .byte   $74,$72,$6F,$F9,$4B,$69,$6C,$EC
        .byte   $73,$6B,$69,$EE,$6C,$65,$61,$74
        .byte   $68,$65,$72,$20,$61,$72,$6D,$6F
        .byte   $75,$F2,$63,$68,$61,$69,$6E,$20
        .byte   $6D,$61,$69,$EC,$70,$6C,$61,$74
        .byte   $65,$20,$6D,$61,$69,$EC,$76,$61
        .byte   $63,$75,$75,$6D,$20,$73,$75,$69
        .byte   $F4,$72,$65,$66,$6C,$65,$63,$74
        .byte   $20,$73,$75,$69,$F4
mi_class_name_table:
        .byte   "peasan"
        .byte   $F4
        .byte   "fighte"
        .byte   $F2
        .byte   "cleri"
        .byte   $E3
        .byte   "wizar"
        .byte   $E4
        .byte   "thie"
        .byte   $E6
        .byte   $66,$6F,$6F,$F4,$68,$6F,$72,$73
        .byte   $E5,$63,$61,$72,$F4,$72,$61,$66
        .byte   $F4,$66,$72,$69,$67,$61,$74,$E5
        .byte   $61,$69,$72,$63,$61,$F2,$73,$68
        .byte   $75,$74,$74,$6C,$E5,$70,$68,$61
        .byte   $6E,$74,$6F,$ED,$73,$74,$61,$72
        .byte   $20,$63,$72,$75,$69,$73,$65,$F2
        .byte   $62,$61,$74,$74,$6C,$65,$20,$62
        .byte   $61,$73,$E5,$74,$69,$6D,$65,$20
        .byte   $6D,$61,$63,$68,$69,$6E,$E5,$4E
        .byte   $6F,$72,$74,$E8,$53,$6F,$75,$74
        .byte   $E8,$45,$61,$73,$F4,$57,$65,$73
        .byte   $F4,$50,$61,$73,$F3,$41,$74,$74
        .byte   $61,$63,$6B,$A0,$42,$6F,$61,$72
        .byte   $64,$A0,$43,$61,$73,$74,$A0,$44
        .byte   $72,$6F,$F0,$45,$6E,$74,$65,$F2
        .byte   $46,$69,$72,$65,$A0,$47,$65,$F4
        .byte   $48,$79,$70,$65,$72,$4A,$75,$6D
        .byte   $F0,$49,$6E,$66,$6F,$72,$6D,$20
        .byte   $61,$6E,$64,$20,$73,$65,$61,$72
        .byte   $63,$E8,$4B,$2D,$6C,$69,$6D,$E2
        .byte   $4E,$6F,$69,$73,$E5,$4F,$70,$65
        .byte   $EE,$51,$75,$69,$74,$2D,$20,$73
        .byte   $61,$76,$69,$6E,$67,$20,$67,$61
        .byte   $6D,$65,$2E,$2E,$AE,$52,$65,$61
        .byte   $64,$79,$20,$57,$65,$61,$70,$6F
        .byte   $6E,$2C,$41,$72,$6D,$6F,$75,$72
        .byte   $2C,$53,$70,$65,$6C,$6C,$3A,$A0
        .byte   $53,$74,$65,$61,$EC,$54,$72,$61
        .byte   $6E,$73,$61,$63,$F4,$55,$6E,$6C
        .byte   $6F,$63,$EB,$56,$69,$65,$F7,$58
        .byte   $2D,$69,$F4,$5A,$74,$61,$74,$F3
        .byte   $52,$65,$64,$20,$47,$65,$ED,$47
        .byte   $72,$65,$65,$6E,$20,$47,$65,$ED
        .byte   $42,$6C,$75,$65,$20,$47,$65,$ED
        .byte   $57,$68,$69,$74,$65,$20,$47,$65
        .byte   $ED,$0A,$05,$04,$03,$02,$01,$04
        .byte   $06,$08,$0A,$01,$02,$04,$06,$08
        .byte   $02,$04,$06,$08,$09,$0A,$02,$02
        .byte   $03,$03,$03,$04,$04,$04,$05,$05
        .byte   $05,$06,$06,$06,$07,$07,$07,$08
        .byte   $08,$08,$09,$09,$09,$0A,$0A,$A0
        .byte   $A0,$A0,$A0,$A0,$A0,$4E,$65,$73
        .byte   $73,$20,$63,$72,$65,$61,$74,$75
        .byte   $72,$E5,$67,$69,$61,$6E,$74,$20
        .byte   $73,$71,$75,$69,$E4,$64,$72,$61
        .byte   $67,$6F,$6E,$20,$74,$75,$72,$74
        .byte   $6C,$E5,$70,$69,$72,$61,$74,$65
        .byte   $20,$73,$68,$69,$F0,$68,$6F,$6F
        .byte   $E4,$62,$65,$61,$F2,$68,$69,$64
        .byte   $64,$65,$6E,$20,$61,$72,$63,$68
        .byte   $65,$F2,$64,$61,$72,$6B,$20,$6B
        .byte   $6E,$69,$67,$68,$F4,$65,$76,$69
        .byte   $6C,$20,$74,$72,$65,$6E,$F4,$74
        .byte   $68,$69,$65,$E6,$6F,$72,$E3,$6B
        .byte   $6E,$69,$67,$68,$F4,$6E,$65,$63
        .byte   $72,$6F,$6D,$61,$6E,$63,$65,$F2
        .byte   $65,$76,$69,$6C,$20,$72,$61,$6E
        .byte   $67,$65,$F2,$77,$61,$6E,$64,$65
        .byte   $72,$69,$6E,$67,$20,$77,$61,$72
        .byte   $6C,$6F,$63,$EB,$72,$61,$6E,$67
        .byte   $65,$F2,$73,$6B,$65,$6C,$65,$74
        .byte   $6F,$EE,$74,$68,$69,$65,$E6,$67
        .byte   $69,$61,$6E,$74,$20,$72,$61,$F4
        .byte   $62,$61,$F4,$67,$69,$61,$6E,$74
        .byte   $20,$73,$70,$69,$64,$65,$F2,$76
        .byte   $69,$70,$65,$F2,$6F,$72,$E3,$63
        .byte   $79,$63,$6C,$6F,$70,$F3,$67,$65
        .byte   $6C,$61,$74,$69,$6E,$6F,$75,$73
        .byte   $20,$63,$75,$62,$E5,$65,$74,$74
        .byte   $69,$EE,$6D,$69,$6D,$69,$E3,$6C
        .byte   $69,$7A,$61,$72,$64,$20,$6D,$61
        .byte   $EE,$6D,$69,$6E,$6F,$74,$61,$75
        .byte   $F2,$63,$61,$72,$72,$69,$6F,$6E
        .byte   $20,$63,$72,$65,$65,$70,$65,$F2
        .byte   $74,$61,$6E,$67,$6C,$65,$F2,$67
        .byte   $72,$65,$6D,$6C,$69,$EE,$77,$61
        .byte   $6E,$64,$65,$72,$69,$6E,$67,$20
        .byte   $65,$79,$65,$F3,$77,$72,$61,$69
        .byte   $74,$E8,$6C,$69,$63,$E8,$69,$6E
        .byte   $76,$69,$73,$69,$62,$6C,$65,$20
        .byte   $73,$65,$65,$6B,$65,$F2,$6D,$69
        .byte   $6E,$64,$20,$77,$68,$69,$70,$70
        .byte   $65,$F2,$7A,$6F,$72,$EE,$64,$61
        .byte   $65,$6D,$6F,$EE,$62,$61,$6C,$72
        .byte   $6F,$EE,$4C,$6F,$72,$64,$20,$42
        .byte   $72,$69,$74,$69,$73,$E8,$74,$68
        .byte   $65,$20,$46,$65,$75,$64,$61,$6C
        .byte   $20,$4C,$6F,$72,$64,$F3,$74,$68
        .byte   $65,$20,$44,$61,$72,$6B,$20,$55
        .byte   $6E,$6B,$6E,$6F,$77,$EE,$44,$61
        .byte   $6E,$67,$65,$72,$20,$61,$6E,$64
        .byte   $20,$44,$65,$73,$70,$61,$69,$F2
        .byte   $1F,$14,$03,$02,$06,$24,$16,$35
        .byte   $1E,$04,$2A,$0F,$3D,$20,$22,$36
        .byte   $15,$38,$1B,$38,$0F,$5E,$56,$7B
        .byte   $5A,$48,$43,$5D,$71,$53,$66,$74
        .byte   $6B,$5C,$5D,$78,$4F,$64,$6A,$48
        .byte   $7C,$76,$A1,$A9,$84,$A5,$B7,$BC
        .byte   $8E,$A2,$AC,$99,$8B,$94,$A3,$A2
        .byte   $87,$B0,$9B,$95,$B7,$83,$89,$DF
        .byte   $D4,$C3,$C2,$C6,$E4,$D6,$F5,$DE
        .byte   $C4,$EA,$CF,$FD,$E0,$E2,$F6,$D5
        .byte   $F8,$DB,$F8,$CF,$1E,$16,$3B,$1A
        .byte   $08,$03,$31,$1D,$13,$26,$34,$2B
        .byte   $1C,$1D,$38,$0F,$24,$2A,$08,$3C
        .byte   $36,$1F,$14,$03,$02,$06,$24,$35
        .byte   $16,$1E,$04,$2A,$0F,$3D,$20,$22
        .byte   $36,$15,$38,$1B,$38,$0F,$1F,$14
        .byte   $03,$02,$06,$24,$16,$35,$1E,$04
        .byte   $2A,$0F,$3D,$20,$22,$36,$15,$38
        .byte   $1B,$38,$0F,$21,$29,$04,$25,$37
        .byte   $3C,$0E,$22,$2C,$19,$0B,$14,$23
        .byte   $22,$07,$30,$1B,$15,$37,$03,$09
        .byte   $54,$68,$65,$20,$43,$61,$73,$74
        .byte   $6C,$65,$20,$6F,$66,$20,$4C,$6F
        .byte   $72,$64,$20,$42,$72,$69,$74,$69
        .byte   $73,$E8,$54,$68,$65,$20,$43,$61
        .byte   $73,$74,$6C,$65,$20,$6F,$66,$20
        .byte   $74,$68,$65,$20,$4C,$6F,$73,$74
        .byte   $20,$4B,$69,$6E,$E7,$54,$68,$65
        .byte   $20,$54,$6F,$77,$65,$72,$20,$6F
        .byte   $66,$20,$4B,$6E,$6F,$77,$6C,$65
        .byte   $64,$67,$E5,$54,$68,$65,$20,$50
        .byte   $69,$6C,$6C,$61,$72,$73,$20,$6F
        .byte   $66,$20,$50,$72,$6F,$74,$65,$63
        .byte   $74,$69,$6F,$EE,$54,$68,$65,$20
        .byte   $44,$75,$6E,$67,$65,$6F,$6E,$20
        .byte   $6F,$66,$20,$50,$65,$72,$69,$6E
        .byte   $69,$E1,$54,$68,$65,$20,$4C,$6F
        .byte   $73,$74,$20,$43,$61,$76,$65,$72
        .byte   $6E,$F3,$54,$68,$65,$20,$4D,$69
        .byte   $6E,$65,$73,$20,$6F,$66,$20,$4D
        .byte   $74,$2E,$20,$44,$72,$61,$73,$E8
        .byte   $54,$68,$65,$20,$4D,$69,$6E,$65
        .byte   $73,$20,$6F,$66,$20,$4D,$74,$2E
        .byte   $20,$44,$72,$61,$73,$68,$20,$49
        .byte   $C9,$4D,$6F,$6E,$64,$61,$69,$6E
        .byte   $27,$73,$20,$47,$61,$74,$65,$20
        .byte   $74,$6F,$20,$48,$65,$6C,$EC,$54
        .byte   $68,$65,$20,$55,$6E,$68,$6F,$6C
        .byte   $79,$20,$48,$6F,$6C,$E5,$54,$68
        .byte   $65,$20,$44,$75,$6E,$67,$65,$6F
        .byte   $6E,$20,$6F,$66,$20,$44,$6F,$75
        .byte   $62,$F4,$54,$68,$65,$20,$44,$75
        .byte   $6E,$67,$65,$6F,$6E,$20,$6F,$66
        .byte   $20,$4D,$6F,$6E,$74,$6F,$F2,$44
        .byte   $65,$61,$74,$68,$27,$73,$20,$41
        .byte   $77,$61,$6B,$65,$6E,$69,$6E,$E7
        .byte   $42,$72,$69,$74,$61,$69,$EE,$4D
        .byte   $6F,$6F,$EE,$46,$61,$77,$EE,$50
        .byte   $61,$77,$F3,$4D,$6F,$6E,$74,$6F
        .byte   $F2,$59,$65,$F7,$54,$75,$6E,$E5
        .byte   $47,$72,$65,$F9,$54,$68,$65,$20
        .byte   $43,$61,$73,$74,$6C,$65,$20,$42
        .byte   $61,$72,$61,$74,$61,$72,$69,$E1
        .byte   $54,$68,$65,$20,$43,$61,$73,$74
        .byte   $6C,$65,$20,$52,$6F,$6E,$64,$6F
        .byte   $72,$6C,$69,$EE,$54,$68,$65,$20
        .byte   $50,$69,$6C,$6C,$61,$72,$20,$6F
        .byte   $66,$20,$4F,$7A,$79,$6D,$61,$6E
        .byte   $64,$69,$61,$F3,$54,$68,$65,$20
        .byte   $50,$69,$6C,$6C,$61,$72,$73,$20
        .byte   $6F,$66,$20,$74,$68,$65,$20,$41
        .byte   $72,$67,$6F,$6E,$61,$75,$74,$F3
        .byte   $53,$63,$6F,$72,$70,$69,$6F,$6E
        .byte   $20,$48,$6F,$6C,$E5,$54,$68,$65
        .byte   $20,$53,$61,$76,$61,$67,$65,$20
        .byte   $50,$6C,$61,$63,$E5,$54,$68,$65
        .byte   $20,$48,$6F,$72,$72,$6F,$72,$20
        .byte   $6F,$66,$20,$74,$68,$65,$20,$48
        .byte   $61,$72,$70,$69,$65,$F3,$54,$68
        .byte   $65,$20,$48,$6F,$72,$72,$6F,$72
        .byte   $20,$6F,$66,$20,$74,$68,$65,$20
        .byte   $48,$61,$72,$70,$69,$65,$73,$20
        .byte   $49,$C9,$41,$64,$76,$61,$72,$69
        .byte   $27,$73,$20,$48,$6F,$6C,$E5,$54
        .byte   $68,$65,$20,$4C,$61,$62,$79,$72
        .byte   $69,$6E,$74,$E8,$54,$68,$65,$20
        .byte   $47,$6F,$72,$67,$6F,$6E,$27,$73
        .byte   $20,$48,$6F,$6C,$E5,$57,$68,$65
        .byte   $72,$65,$20,$48,$65,$72,$63,$75
        .byte   $6C,$65,$73,$20,$44,$69,$65,$E4
        .byte   $54,$68,$65,$20,$44,$65,$61,$64
        .byte   $20,$57,$61,$72,$72,$69,$6F,$72
        .byte   $27,$73,$20,$46,$69,$67,$68,$F4
        .byte   $41,$72,$6E,$6F,$6C,$E4,$4C,$69
        .byte   $6E,$64,$E1,$48,$65,$6C,$65,$EE
        .byte   $4F,$77,$65,$EE,$4A,$6F,$68,$EE
        .byte   $47,$65,$72,$72,$F9,$57,$6F,$6C
        .byte   $E6,$54,$68,$65,$20,$53,$6E,$61
        .byte   $6B,$E5,$54,$68,$65,$20,$43,$61
        .byte   $73,$74,$6C,$65,$20,$6F,$66,$20
        .byte   $4F,$6C,$79,$6D,$70,$75,$F3,$54
        .byte   $68,$65,$20,$42,$6C,$61,$63,$6B
        .byte   $20,$44,$72,$61,$67,$6F,$6E,$27
        .byte   $73,$20,$43,$61,$73,$74,$6C,$E5
        .byte   $54,$68,$65,$20,$53,$69,$67,$6E
        .byte   $20,$50,$6F,$73,$F4,$54,$68,$65
        .byte   $20,$53,$6F,$75,$74,$68,$65,$72
        .byte   $6E,$20,$53,$69,$67,$6E,$20,$50
        .byte   $6F,$73,$F4,$54,$68,$65,$20,$4D
        .byte   $65,$74,$61,$6C,$20,$54,$77,$69
        .byte   $73,$74,$65,$F2,$54,$68,$65,$20
        .byte   $54,$72,$6F,$6C,$6C,$27,$73,$20
        .byte   $48,$6F,$6C,$E5,$54,$68,$65,$20
        .byte   $56,$69,$70,$65,$72,$27,$73,$20
        .byte   $50,$69,$F4,$54,$68,$65,$20,$56
        .byte   $69,$70,$65,$72,$27,$73,$20,$50
        .byte   $69,$74,$20,$49,$C9,$54,$68,$65
        .byte   $20,$47,$75,$69,$6C,$64,$20,$6F
        .byte   $66,$20,$44,$65,$61,$74,$E8,$54
        .byte   $68,$65,$20,$45,$6E,$64,$2E,$2E
        .byte   $AE,$54,$68,$65,$20,$54,$72,$61
        .byte   $6D,$70,$20,$6F,$66,$20,$44,$6F
        .byte   $6F,$ED,$54,$68,$65,$20,$4C,$6F
        .byte   $6E,$67,$20,$44,$65,$61,$74,$E8
        .byte   $54,$68,$65,$20,$53,$6C,$6F,$77
        .byte   $20,$44,$65,$61,$74,$E8,$4E,$61
        .byte   $73,$73,$61,$F5,$43,$6C,$65,$61
        .byte   $72,$20,$4C,$61,$67,$6F,$6F,$EE
        .byte   $53,$74,$6F,$75,$F4,$47,$61,$75
        .byte   $6E,$74,$6C,$65,$F4,$49,$6D,$61
        .byte   $67,$69,$6E,$61,$74,$69,$6F,$EE
        .byte   $50,$6F,$6E,$64,$65,$F2,$57,$65
        .byte   $61,$6C,$74,$E8,$50,$6F,$6F,$F2
        .byte   $54,$68,$65,$20,$57,$68,$69,$74
        .byte   $65,$20,$44,$72,$61,$67,$6F,$6E
        .byte   $27,$73,$20,$43,$61,$73,$74,$6C
        .byte   $E5,$54,$68,$65,$20,$43,$61,$73
        .byte   $74,$6C,$65,$20,$6F,$66,$20,$53
        .byte   $68,$61,$6D,$69,$6E,$EF,$54,$68
        .byte   $65,$20,$47,$72,$61,$76,$65,$20
        .byte   $6F,$66,$20,$74,$68,$65,$20,$4C
        .byte   $6F,$73,$74,$20,$53,$6F,$75,$EC
        .byte   $45,$61,$73,$74,$65,$72,$6E,$20
        .byte   $53,$69,$67,$6E,$20,$50,$6F,$73
        .byte   $F4,$53,$70,$69,$6E,$65,$20,$42
        .byte   $72,$65,$61,$6B,$65,$F2,$46,$72
        .byte   $65,$65,$20,$44,$65,$61,$74,$68
        .byte   $20,$48,$6F,$6C,$E5,$54,$68,$65
        .byte   $20,$44,$65,$61,$64,$20,$43,$61
        .byte   $74,$27,$73,$20,$4C,$69,$66,$E5
        .byte   $54,$68,$65,$20,$44,$65,$61,$64
        .byte   $20,$43,$61,$74,$27,$73,$20,$4C
        .byte   $69,$66,$65,$20,$49,$C9,$54,$68
        .byte   $65,$20,$4D,$6F,$72,$62,$69,$64
        .byte   $20,$41,$64,$76,$65,$6E,$74,$75
        .byte   $72,$E5,$54,$68,$65,$20,$53,$6B
        .byte   $75,$6C,$6C,$20,$53,$6D,$61,$73
        .byte   $68,$65,$F2,$44,$65,$61,$64,$20
        .byte   $4D,$61,$6E,$27,$73,$20,$57,$61
        .byte   $6C,$EB,$54,$68,$65,$20,$44,$75
        .byte   $6E,$67,$65,$6F,$6E,$20,$6F,$66
        .byte   $20,$44,$6F,$6F,$ED,$48,$6F,$6C
        .byte   $65,$20,$74,$6F,$20,$48,$61,$64
        .byte   $65,$F3,$47,$6F,$72,$6C,$61,$E2
        .byte   $44,$65,$78,$74,$72,$6F,$EE,$4D
        .byte   $61,$67,$69,$E3,$57,$68,$65,$65
        .byte   $6C,$65,$F2,$42,$75,$6C,$6C,$64
        .byte   $6F,$7A,$65,$F2,$54,$68,$65,$20
        .byte   $42,$72,$6F,$74,$68,$65,$F2,$54
        .byte   $68,$65,$20,$54,$75,$72,$74,$6C
        .byte   $E5,$4C,$6F,$73,$74,$20,$46,$72
        .byte   $69,$65,$6E,$64,$F3
s8175:  bcc     b818E
        jsr     mi_print_text
        .byte   "}Disk error "

        .byte   $00
        jsr     s8B64
        jsr     st_clear_to_end_of_text_row_a
        sec
b818E:  rts

s818F:  lda     BM_ADDR_MASK
        bne     b8196
        jsr     st_copy_screen_2_to_1
b8196:  lda     #$97
        sta     CIA2_PRA
        lda     #$18
        sta     VIC_VIDEO_ADR
        lda     #$00
        sta     BM_ADDR_MASK
        sta     BM2_ADDR_MASK
        rts

text_area_cache:
        .byte   $00,$28,$00,$18,$00,$00
w81AD:  .byte   $00,$2F,$55,$31,$2E,$50,$4C,$41
        .byte   $59,$45,$52,$2F,$55,$31,$2E,$56
        .byte   $41,$52,$53,$00,$00,$00,$00
mi_current_attribute:
        .byte   $00,$05,$50,$00,$00,$40,$2F,$3B
        .byte   $3A,$20,$41,$42,$43,$44,$45,$46
        .byte   $47,$48,$49,$4B,$4E,$4F,$51,$52
        .byte   $53,$54,$55,$56,$58,$5A
mi_player_save_data:
        .byte   $CA,$01,$00,$00,$FF
mi_player_sound_flag:
        .byte   $FF,$20,$20,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$01,$01,$01,$01,$01
        .byte   $01,$01,$01,$01,$01,$01,$01,$01
        .byte   $01,$01,$01,$01,$01,$01,$01,$01
        .byte   $01,$01,$03,$03,$03,$00,$03,$03
        .byte   $03,$03,$03,$03,$01,$01,$01,$01
        .byte   $01,$01,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$FF
        .byte   $FF,$FF,$FF,$00,$00
mi_player_sex:
        .byte   $01
mi_player_name:
        .byte   $47,$6C,$69,$6E,$64,$61,$00,$00
        .byte   $00,$00,$00,$00,$00,$00
mi_player_hits:
        .byte   $84
player_hits_hi:
        .byte   $03
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
        .byte   $38
player_money_hi:
        .byte   $08
mi_player_race:
        .byte   $02,$00
mi_player_class:
        .byte   $02,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$95
mi_player_food:
        .byte   $59
player_food_hi:
        .byte   $00
mi_player_experience:
        .byte   $37
player_experience_hi:
        .byte   $02,$E8,$03,$E8,$03,$00,$FF
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
inc_then_read_ptr:
        inc     rts_ptr_lo
        bne     b83B4
        inc     rts_ptr_hi
b83B4:
rts_ptr_lo      := * + 1
rts_ptr_hi      := * + 2
        lda     BASIC_BUF
        rts

read_then_inc_ptr:
read_ptr_lo     := * + 1
read_ptr_hi     := * + 2
        lda     BASIC_BUF
        inc     read_ptr_lo
        bne     b83C3
        inc     read_ptr_hi
b83C3:  rts

        .byte   $48,$4A,$4A,$4A,$4A,$20,$CD,$83
        .byte   $68
print_digit:
        and     #$0F
        ora     #$30
        cmp     #$3A
        bcc     mi_print_char
        adc     #$06
mi_print_char:
        jsr     st_print_char
        inc     CUR_X
b83DC:  rts

print_char_or_esc:
        and     #$7F
        cmp     #$7C
        bcc     mi_print_char
        beq     print_lfcr
        cmp     #$7E
        beq     mi_print_crlf_col_1
        cmp     #$7D
        bne     b83DC
        lda     CUR_X
        cmp     #$02
        bcc     mi_cursor_to_col_1
mi_print_crlf_col_1:
        jsr     print_lfcr
mi_cursor_to_col_1:
        lda     #$01
        sta     CUR_X
        rts

clear_to_end_then_print_lfcr:
        jsr     st_clear_to_end_of_text_row_a
print_lfcr:
        inc     CUR_Y
        lda     CUR_Y
        cmp     CUR_Y_MAX
        bcc     mi_cursor_to_col_0
        tya
        pha
        txa
        pha
        jsr     st_scroll_text_area_up
        pla
        tax
        pla
        tay
mi_cursor_to_col_0:
        lda     #$00
        sta     CUR_X
        rts

        .byte   $E6,$30,$C6,$31,$E6,$2E,$C6,$2F
        .byte   $C6,$2F,$A5,$30,$85,$33,$D0,$EB
mi_print_string_entry_x:
        sec
        ror     w81AD
        bit     a:zpA2
        pla
        sta     rts_ptr_lo
        pla
        sta     rts_ptr_hi
        jsr     inc_then_read_ptr
        sta     read_ptr_lo
        jsr     inc_then_read_ptr
        sta     read_ptr_hi
        lda     rts_ptr_hi
        pha
        lda     rts_ptr_lo
        pha
        txa
        beq     b8455
b844C:  jsr     read_then_inc_ptr
        asl     a
        bcc     b844C
        dex
        bne     b844C
b8455:  jsr     read_then_inc_ptr
        cmp     #$7F
        beq     b847F
        pha
        bit     w81AD
        bpl     b8475
        and     #$7F
        cmp     #$7C
        bcs     b8475
        cmp     #$61
        bcc     b8472
        cmp     #$7B
        bcs     b8472
        eor     #$20
b8472:  sta     w81AD
b8475:  jsr     print_char_or_esc
        pla
        bpl     b8455
        lsr     w81AD
        rts

b847F:  jsr     read_then_inc_ptr
        clc
        adc     CUR_X
        sta     CUR_X
        jmp     b8455

mi_print_text_at_x_y:
        stx     CUR_X
        sty     CUR_Y
mi_print_text:
        pla
        sta     rts_ptr_lo
        pla
        sta     rts_ptr_hi
j8496:  jsr     inc_then_read_ptr
        beq     b84B0
        cmp     #$7F
        beq     b84A5
        jsr     print_char_or_esc
        jmp     j8496

b84A5:  jsr     inc_then_read_ptr
        clc
        adc     CUR_X
        sta     CUR_X
        jmp     j8496

b84B0:  lda     rts_ptr_hi
        pha
        lda     rts_ptr_lo
        pha
        rts

mi_print_x_chars:
        jsr     mi_print_char
        dex
        bne     mi_print_x_chars
        rts

mi_s84C0:
        jsr     st_set_text_window_full
        jsr     st_clear_text_window
s84C6:  jsr     st_set_text_window_full
        lda     #$10
        jsr     mi_print_char
        ldx     #$26
        lda     #$04
        jsr     mi_print_x_chars
        lda     #$12
        jsr     st_print_char
b84DA:  inc     CUR_Y
        jsr     mi_cursor_to_col_0
        lda     #$0A
        jsr     st_print_char
        lda     #$27
        sta     CUR_X
        lda     #$08
        jsr     st_print_char
        jsr     st_scan_and_buffer_input
        lda     CUR_Y
        eor     #$12
        bne     b84DA
        sta     CUR_X
        inc     CUR_Y
        lda     #$04
        jsr     mi_print_char
        ldx     #$26
        lda     #$06
        jsr     mi_print_x_chars
        lda     #$04
        jsr     st_print_char
        lda     #$1E
        sta     CUR_X
        lda     #$02
        jsr     st_print_char
        lda     #$0C
b8516:  inc     CUR_Y
        jsr     st_print_char
        ldx     CUR_Y
        cpx     #$17
        bcc     b8516
        rts

to_decimal_a_x:
        stx     hex_lo
        sta     hex_hi
        ldx     #$00
        stx     dec_lo
        stx     dec_mid
        stx     dec_hi
        stx     dec_cnt_hi
        stx     dec_cnt_mid
        inx
        stx     dec_cnt_lo
        sed
b8539:  lsr     hex_hi
        ror     hex_lo
        bcc     b8555
        clc
        lda     dec_lo
        adc     dec_cnt_lo
        sta     dec_lo
        lda     dec_mid
        adc     dec_cnt_mid
        sta     dec_mid
        lda     dec_hi
        adc     dec_cnt_hi
        sta     dec_hi
b8555:  clc
        lda     dec_cnt_lo
        adc     dec_cnt_lo
        sta     dec_cnt_lo
        lda     dec_cnt_mid
        adc     dec_cnt_mid
        sta     dec_cnt_mid
        lda     dec_cnt_hi
        adc     dec_cnt_hi
        sta     dec_cnt_hi
        lda     hex_lo
        ora     hex_hi
        bne     b8539
        cld
        rts

dec_cnt_lo:
        .byte   $01
dec_cnt_mid:
        .byte   $00
dec_cnt_hi:
        .byte   $00
print_long_int:
        jsr     to_decimal_a_x
        inx
        bne     b8588
mi_print_short_int:
        tax
        lda     #$00
        jsr     to_decimal_a_x
b8588:  sta     w85BD
        jmp     j8597

b858E:  lda     dec_lo,x
        lsr     a
        lsr     a
        lsr     a
        lsr     a
        jsr     s85A6
j8597:  txa
        bne     b859D
        inc     w85BD
b859D:  lda     dec_lo,x
        jsr     s85A6
        dex
        bpl     b858E
b85A5:  rts

s85A6:  and     #$0F
        bne     b85B7
        cmp     w85BD
        bne     b85BA
        lda     mi_w85BE
        beq     b85A5
        jmp     mi_print_char

b85B7:  sta     w85BD
b85BA:  jmp     print_digit

w85BD:  .byte   $00
mi_w85BE:
        .byte   $00,$A0,$FF,$38,$C8,$E9,$0A,$B0
        .byte   $FB,$98,$60,$85,$43,$20,$70,$16
        .byte   $C5,$43,$90,$04,$E5,$43,$B0,$F8
        .byte   $C9,$00,$85,$43,$60,$20,$73,$16
        .byte   $A5,$56,$60,$20,$77,$87,$A0,$3D
        .byte   $8C,$FC,$85,$20,$D5,$1E,$EA,$EA
        .byte   $EA,$C9,$00,$D0,$08,$20,$A0,$16
        .byte   $CE,$FC,$85,$D0,$EE,$60,$40,$A2
        .byte   $18,$DD,$C9,$81,$F0,$10,$CA,$10
        .byte   $F8,$20,$8E,$84,$48,$75,$68,$3F
        .byte   $00,$20,$72,$87,$38,$60,$8A,$48
        .byte   $C9,$04,$B0,$16,$AD,$C8,$81,$F0
        .byte   $11,$8D,$2C,$86,$AD,$C7,$81,$8D
        .byte   $2B,$86,$20,$2D,$84,$7F,$79,$4C
        .byte   $35,$86,$20,$2D,$84,$7F,$79,$68
        .byte   $0A,$AA,$18,$60,$18,$B0,$38,$8C
        .byte   $C5,$81,$8D,$C6,$81,$90,$05,$A9
        .byte   $00,$20,$85,$16,$F8,$38,$AD,$59
        .byte   $82,$ED,$C5,$81,$8D,$59,$82,$B0
        .byte   $13,$AD,$5A,$82,$0D,$5B,$82,$F0
        .byte   $0B,$AD,$5A,$82,$D0,$03,$CE,$5B
        .byte   $82,$CE,$5A,$82,$18,$AD,$4F,$82
        .byte   $6D,$C6,$81,$8D,$4F,$82,$B0,$02
        .byte   $D8,$60,$F8,$38,$A2,$00,$BD,$50
        .byte   $82,$69,$00,$9D,$50,$82,$E8,$B0
        .byte   $F5,$D8,$60
mi_s8689:
        jsr     mi_store_text_area
        jsr     st_set_text_window_stats
        jsr     mi_print_text
        .byte   "Hits |Food |Exp. |Coin "


        .byte   $00
        jmp     j86C9

s86AD:  cmp     #$01
        bcs     b86BB
        cpx     #$64
        bcs     b86BB
        pha
        lda     #$FF
        sta     CHAR_REV
        pla
b86BB:  jsr     print_long_int
        jsr     clear_to_end_then_print_lfcr
        lda     #$00
        sta     CHAR_REV
        rts

        .byte   $20,$0C,$87
j86C9:  jsr     st_set_text_window_stats
        sta     mi_w85BE
        lda     #$24
        sta     CUR_X_OFF
        lda     #$04
        sta     CUR_X_MAX
        lda     player_hits_hi
        ldx     mi_player_hits
        jsr     s86AD
        lda     player_food_hi
        ldx     mi_player_food
        jsr     s86AD
        lda     player_experience_hi
        ldx     mi_player_experience
        jsr     print_long_int
        jsr     clear_to_end_then_print_lfcr
        lda     player_money_hi
        ldx     mi_player_money
        jsr     print_long_int
        jsr     st_clear_to_end_of_text_row_a
mi_restore_text_area:
        ldx     #$05
b8703:  lda     text_area_cache,x
        sta     CUR_X_OFF,x
        dex
        bpl     b8703
        rts

mi_store_text_area:
        ldx     #$05
b870E:  lda     CUR_X_OFF,x
        sta     text_area_cache,x
        dex
        bpl     b870E
        rts

        .byte   $AE,$EE,$81,$20,$2D,$84,$88,$78
        .byte   $60,$A5,$33,$0A,$0A,$0A,$AA,$A4
        .byte   $32,$F0,$23,$88,$BD,$00,$12,$18
        .byte   $79,$B0,$15,$85,$36,$BD,$C0,$12
        .byte   $45,$5C,$79,$D8,$15,$85,$37,$A0
        .byte   $07,$A9,$00,$11,$36,$D0,$07,$88
        .byte   $10,$F9,$C6,$32,$D0,$D9,$60,$20
        .byte   $8E,$84,$7D,$48,$6D,$6D,$6D,$6D
        .byte   $2E,$2E,$2E,$20,$6E,$6F,$20,$65
        .byte   $66,$66,$65,$63,$74,$3F,$00,$A9
        .byte   $08,$D0,$0A,$20,$20,$87,$A9,$3F
        .byte   $20,$67,$16
mi_play_error_sound_and_read_input:
        lda     #$10
        jsr     st_play_sound_a
s8777:  nop
        nop
        nop
        jsr     KERNEL_GETIN
        cmp     #$00
        bne     s8777
        lda     #$00
        sta     SOUND_BUFFER_SIZE
        sta     INPUT_BUFFER_SIZE
        rts

        .byte   $20,$0C,$87,$A9,$04,$85,$30,$85
        .byte   $2E,$A9,$10,$85,$31,$A9,$20,$85
        .byte   $2F,$20,$52,$16,$20,$F3,$83,$A9
        .byte   $60,$20,$8B,$16,$20,$C9,$87,$A2
        .byte   $04,$A0,$12,$86,$26,$84,$27,$A2
        .byte   $FA,$20,$91,$16,$A6,$26,$A0,$6D
        .byte   $20,$91,$16,$A2,$04,$A4,$27,$20
        .byte   $91,$16,$A6,$26,$A0,$12,$20,$91
        .byte   $16,$A5,$5C,$45,$5D,$85,$5C,$60
        .byte   $48,$A9,$07,$85,$32,$68,$A2,$03
        .byte   $DD,$F5,$87,$F0,$03,$CA,$D0,$F8
        .byte   $8A,$0A,$A8,$B9,$FA,$87,$48,$B9
        .byte   $F9,$87,$48,$20,$2D,$84,$2E,$88
        .byte   $20,$4F,$16,$E6,$32,$60,$53,$57
        .byte   $41,$F4,$87,$00,$88,$0F,$88,$1E
        .byte   $88,$AD,$EE,$81,$20,$49,$88,$0A
        .byte   $08,$82,$88,$78,$8D,$EE,$81,$60
        .byte   $AD,$EF,$81,$20,$49,$88,$0F,$F8
        .byte   $81,$7C,$77,$8D,$EF,$81,$60,$AD
        .byte   $F0,$81,$20,$49,$88,$05,$F2,$81
        .byte   $D4,$78,$8D,$F0,$81,$60,$6E,$6F
        .byte   $74,$68,$69,$6E,$E7,$73,$70,$65
        .byte   $6C,$6C,$BA,$77,$65,$61,$70,$6F
        .byte   $6E,$BA,$61,$72,$6D,$6F,$75,$72
        .byte   $BA,$85,$46,$68,$8D,$B5,$83,$68
        .byte   $8D,$B6,$83,$20,$AC,$83,$8D,$0B
        .byte   $89,$20,$AC,$83,$85,$41,$20,$AC
        .byte   $83,$85,$42,$20,$AC,$83,$8D,$07
        .byte   $89,$20,$AC,$83,$8D,$08,$89,$AD
        .byte   $B6,$83,$48,$AD,$B5,$83,$48,$20
        .byte   $0C,$87,$20,$5E,$16,$A2,$0E,$A0
        .byte   $00,$A5,$5D,$8D,$C3,$81,$84,$5D
        .byte   $20,$8A,$84,$0E,$20,$52,$65,$61
        .byte   $64,$79,$20,$18,$00,$20,$52,$16
        .byte   $AC,$0B,$89,$A2,$01,$B1,$41,$F0
        .byte   $01,$E8,$88,$D0,$F8,$86,$43,$38
        .byte   $A9,$14,$E5,$43,$4A,$85,$33,$A9
        .byte   $61,$8D,$BF,$88,$A0,$00,$98,$48
        .byte   $A9,$0D,$85,$32,$20,$8E,$84,$61
        .byte   $29,$20,$00,$68,$20,$02,$89,$A8
        .byte   $E6,$33,$CC,$0B,$89,$B0,$0A,$EE
        .byte   $BF,$88,$C8,$B1,$41,$D0,$DF,$F0
        .byte   $F1,$20,$01,$87,$AD,$C3,$81,$85
        .byte   $5D,$20,$64,$16,$20,$76,$16,$48
        .byte   $20,$D6,$8A,$38,$68,$E9,$41,$F0
        .byte   $11,$30,$0C,$CD,$0B,$89,$90,$02
        .byte   $D0,$05,$A8,$B1,$41,$D0,$02,$A4
        .byte   $46,$98,$AA,$48,$20,$26,$84,$00
        .byte   $00,$68,$60,$0A,$20,$61,$16,$20
        .byte   $0C,$87,$20,$5E,$16,$20,$16,$84
        .byte   $A2,$0C,$A0,$00,$8C,$BE,$85,$A5
        .byte   $5D,$8D,$C3,$81,$84,$5D,$20,$8A
        .byte   $84,$0E,$20,$49,$6E,$76,$65,$6E
        .byte   $74,$6F,$72,$79,$20,$18,$7C,$7C
        .byte   $50,$6C,$61,$79,$65,$72,$3A,$20
        .byte   $00,$20,$A1,$8B,$20,$8E,$84,$7C
        .byte   $41,$20,$6C,$65,$76,$65,$6C,$20
        .byte   $00,$AE,$5C,$82,$AD,$5D,$82,$20
        .byte   $22,$85,$A5,$3D,$4A,$4A,$4A,$4A
        .byte   $18,$69,$01,$20,$82,$85,$E6,$32
        .byte   $AD,$2C,$82,$F0,$06,$20,$8E,$84
        .byte   $66,$65,$00,$20,$8E,$84,$6D,$61
        .byte   $6C,$65,$20,$00,$AE,$4B,$82,$20
        .byte   $2D,$84,$63,$77,$E6,$32,$AE,$4D
        .byte   $82,$20,$2D,$84,$11,$79,$20,$10
        .byte   $8B,$C6,$33,$A2,$00,$8E,$C4,$81
        .byte   $86,$46,$8A,$0A,$A8,$BE,$3B,$82
        .byte   $B9,$3C,$82,$D0,$04,$E0,$00,$F0
        .byte   $05,$20,$25,$8B,$42,$78,$A6,$46
        .byte   $E8,$E0,$07,$90,$E3,$AE,$49,$82
        .byte   $AD,$4A,$82,$20,$22,$85,$A5,$3C
        .byte   $29,$0F,$F0,$1C,$20,$DC,$8A,$20
        .byte   $8E,$84,$43,$6F,$70,$70,$65,$72
        .byte   $20,$70,$65,$6E,$63,$65,$2E,$2E
        .byte   $2E,$2E,$00,$A5,$3C,$20,$CD,$83
        .byte   $A5,$3C,$4A,$4A,$4A,$4A,$F0,$1C
        .byte   $48,$20,$DC,$8A,$20,$8E,$84,$53
        .byte   $69,$6C,$76,$65,$72,$20,$70,$69
        .byte   $65,$63,$65,$73,$2E,$2E,$2E,$00
        .byte   $68,$20,$CD,$83,$A5,$3D,$F0,$39
        .byte   $20,$DC,$8A,$20,$8E,$84,$47,$6F
        .byte   $6C,$64,$20,$43,$72,$6F,$77,$6E
        .byte   $73,$2E,$2E,$2E,$2E,$00,$A5,$3D
        .byte   $C9,$10,$B0,$1A,$A9,$2E,$20,$D7
        .byte   $83,$A5,$3D,$20,$CD,$83,$4C,$41
        .byte   $8A,$45,$6E,$65,$6D,$79,$20,$76
        .byte   $65,$73,$73,$65,$6C,$F3,$20,$C4
        .byte   $83,$AD,$2B,$82,$F0,$09,$A2,$00
        .byte   $86,$46,$20,$22,$8B,$31,$8A,$AD
        .byte   $F0,$81,$8D,$C4,$81,$A2,$01,$86
        .byte   $46,$BD,$F2,$81,$F0,$05,$20,$22
        .byte   $8B,$D4,$78,$A6,$46,$E8,$E0,$06
        .byte   $90,$ED,$AD,$F1,$81,$8D,$C4,$81
        .byte   $A2,$01,$86,$46,$BD,$13,$82,$F0
        .byte   $05,$20,$22,$8B,$30,$79,$A6,$46
        .byte   $E8,$E0,$0B,$90,$ED,$A2,$00,$8E
        .byte   $C4,$81,$86,$46,$BD,$EA,$81,$F0
        .byte   $05,$20,$22,$8B,$30,$7A,$A6,$46
        .byte   $E8,$E0,$04,$90,$ED,$AD,$EF,$81
        .byte   $8D,$C4,$81,$A2,$01,$86,$46,$BD
        .byte   $F8,$81,$F0,$05,$20,$22,$8B,$7C
        .byte   $77,$A6,$46,$E8,$E0,$10,$90,$ED
        .byte   $AD,$EE,$81,$8D,$C4,$81,$A2,$01
        .byte   $86,$46,$BD,$08,$82,$F0,$05,$20
        .byte   $22,$8B,$88,$78,$A6,$46,$E8,$E0
        .byte   $0B,$90,$ED,$20,$56,$8B,$20,$C6
        .byte   $84,$4C,$01,$87,$A2,$00,$86,$32
        .byte   $A4,$33,$C8,$C0,$12,$90,$0E,$A4
        .byte   $30,$A9,$12,$85,$2F,$65,$2E,$C9
        .byte   $26,$B0,$05,$85,$2E,$84,$33,$60
        .byte   $A2,$0D,$A0,$12,$20,$8A,$84,$6D
        .byte   $6F,$72,$65,$00,$20,$56,$8B,$A9
        .byte   $00,$85,$5D,$E6,$32,$20,$0C,$87
        .byte   $A9,$05,$85,$30,$4A,$85,$2E,$A9
        .byte   $24,$85,$2F,$A9,$13,$85,$31,$4C
        .byte   $52,$16,$AA,$A9,$00,$48,$8A,$48
        .byte   $20,$DC,$8A,$A9,$03,$85,$32,$A2
        .byte   $09,$A9,$2E,$8D,$BE,$85,$20,$B9
        .byte   $84,$68,$AA,$68,$20,$7C,$85,$20
        .byte   $11,$84,$A6,$46,$AD,$C4,$81,$F0
        .byte   $0A,$EC,$C4,$81,$D0,$05,$A9,$1B
        .byte   $20,$D7,$83,$4C,$26,$84,$AD,$C3
        .byte   $81,$85,$5D,$20,$64,$16,$20,$46
        .byte   $16,$20,$01,$87
s8B64:  jsr     mi_print_text
        .byte   "}Press Space to continue: "



        .byte   $00
        jsr     s8777
b8B85:  jsr     st_read_input
        cmp     #$0D
        beq     b8B94
        cmp     #$1B
        beq     b8B94
        cmp     #$20
        bne     b8B85
b8B94:  jsr     st_clear_current_text_row
        inc     CUR_X
        dec     CUR_Y
        jsr     s8777
        jmp     mi_store_text_area

mi_print_player_name:
        ldx     #$00
b8BA3:  lda     mi_player_name,x
        beq     b8BAE
        jsr     mi_print_char
        inx
        bne     b8BA3
b8BAE:  rts

        .byte   $60,$20,$8E,$84,$20,$6F,$66,$66
        .byte   $00,$60,$AD,$38,$16,$49,$FF,$8D
        .byte   $38,$16,$8D,$E7,$81,$F0,$EA,$20
        .byte   $8E,$84,$20,$6F,$6E,$00,$60,$20
        .byte   $ED,$83,$20,$A1,$8B,$20,$8E,$84
        .byte   $2C,$20,$74,$68,$6F,$75,$20,$61
        .byte   $72,$74,$20,$64,$65,$61,$64,$2E
        .byte   $00,$20,$46,$16,$A9,$00,$8D,$49
        .byte   $82,$8D,$4A,$82,$8D,$5A,$82,$8D
        .byte   $5B,$82,$8D,$3B,$82,$8D,$3C,$82
        .byte   $A4,$5D,$8C,$C3,$81,$85,$5D,$20
        .byte   $C6,$86,$20,$61,$16,$A9,$03,$85
        .byte   $60,$A9,$74,$85,$61,$A9,$80,$85
        .byte   $62,$A9,$25,$45,$5C,$85,$63,$A2
        .byte   $0C,$A0,$47,$B1,$60,$91,$62,$88
        .byte   $10,$F9,$A5,$60,$18,$69,$48,$85
        .byte   $60,$A5,$61,$69,$00,$85,$61,$A5
        .byte   $62,$18,$69,$40,$85,$62,$A5,$63
        .byte   $69,$01,$85,$63,$CA,$D0,$DA,$A9
        .byte   $02,$20,$85,$16,$A9,$02,$20,$85
        .byte   $16,$AD,$C3,$81,$85,$5D,$20,$64
        .byte   $16,$4C,$77,$87,$20,$CE,$8B
mi_j8C5E:
        lda     #$01
j8C60:  ldx     #$FF
        txs
        cmp     #$07
        bcs     b8C6A
        tax
        bne     b8C74
b8C6A:  ldx     #$04
        jsr     load_file
        bcs     b8C6A
        jmp     do_mi_main

b8C74:  clc
        adc     #$04
        sta     w8C97
b8C7A:  jsr     s8777
        ldx     w8C97
        jsr     load_file
        jsr     s8175
        bcs     b8C7A
        jsr     s818F
        jsr     mi_s8689
        jsr     s84C6
        jsr     mi_restore_text_area
        jmp     do_mi_main

w8C97:  .byte   $04,$20,$3D,$16,$4C,$9B,$8C
do_mi_main:
        sei
        ldx     #$FF
        txs
        ldx     #$0B
        jsr     load_file
        ldx     #$0F
        jsr     load_file
        jsr     st_set_text_window_full
        jsr     st_init_snd_gfx
        lda     #$60
        sta     BM_ADDR_MASK
        sta     BM2_ADDR_MASK
        jsr     st_swap_bitmaps
        jsr     s818F
        lda     #$96
        sta     CIA2_PRA
        lda     #$80
        sta     VIC_VIDEO_ADR
        lda     #$00
        jmp     j8C60

        .byte   $C8

; End of "code" segment
.code
