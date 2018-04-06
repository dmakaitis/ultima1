;-------------------------------------------------------------------------------
;
; lo.s
;
;-------------------------------------------------------------------------------


.include "c64.inc"

        .setcpu "6502"

;-------------------------------------------------------------------------------
;
; The load address for this file is always set to $2000, but is ignored. The
; actual location where this code should be loaded into memory is $8000.
;
;-------------------------------------------------------------------------------

.segment    "LOADADDR"

        .addr   $2000

.code

L0000           := $0000
L0036           := $0036
L0038           := $0038
L0066           := $0066
L180C           := $180C
L3618           := $3618
L380C           := $380C
L383C           := $383C
L3866           := $3866
L386C           := $386C
L3C6C           := $3C6C
L6060           := $6060
L6076           := $6076
L6666           := $6666
L666C           := $666C
L6676           := $6676
L6800           := $6800
L6C6C           := $6C6C
L6CFE           := $6CFE
LC480           := $C480
LC486           := $C486
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $00,$C0,$F0,$FC,$FC,$F0,$C0,$00
        .byte   $00,$C0,$F0,$FC,$FC,$F0,$C0,$00
        .byte   $07,$1F,$3F,$7F,$7F,$FF,$FF,$FF
        .byte   $03,$07,$0F,$1F,$3F,$7F,$FF,$FF
        .byte   $E0,$F8,$FC,$FE,$FE,$FF,$FF,$FF
        .byte   $C0,$E0,$F0,$F8,$FC,$FE,$FF,$FF
        .byte   $FF,$7F,$3F,$1F,$0F,$07,$03,$00
        .byte   $FF,$7F,$3F,$1F,$0F,$07,$03,$00
        .byte   $FF,$FE,$FC,$F8,$F0,$E0,$C0,$00
        .byte   $FF,$FE,$FC,$F8,$F0,$E0,$C0,$00
        .byte   $00,$03,$0F,$3F,$3F,$0F,$03,$00
        .byte   $00,$03,$0F,$3F,$3F,$0F,$03,$00
        .byte   $18,$3C,$7E,$18,$18,$7E,$3C,$18
        .byte   $00,$00,$38,$7C,$7C,$38,$00,$00
        .byte   $18,$3C,$7E,$18,$18,$18,$18,$18
        .byte   $18,$18,$18,$18,$18,$7E,$3C,$18
        .byte   $00,$10,$38,$54,$92,$28,$28,$28
        .byte   $FF,$BB,$FF,$FF,$FF,$FF,$BB,$FF
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$18,$18,$18,$18,$00,$18,$18
        .byte   $00,$36,$36,$6C,$00,$00,$00,$00
        .byte   $00,$6C,$FE,$6C,$6C,$FE,$6C,$00
        .byte   $00,$10,$3C,$70,$38,$1C,$78,$10
        .byte   $00,$00,$66,$6C,$18,$36,$66,$00
        .byte   $00,$70,$D8,$D8,$76,$DC,$DC,$76
        .byte   $00,$18,$18,$30,$00,$00,$00,$00
        .byte   $00,$0C,$18,$30,$30,$30,$18,$0C
        .byte   $00,$60,$30,$18,$18,$18,$30,$60
        .byte   $00,$00,$10,$38,$7C,$38,$10,$00
        .byte   $00,$00,$18,$18,$7E,$18,$18,$00
        .byte   $00,$00,$00,$00,$00,$18,$18,$30
        .byte   $00,$00,$00,$00,$7C,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$18,$18
        .byte   $00,$10,$7C,$BA,$92,$38,$28,$28
        .byte   $00,$38,$6C,$6C,$6C,$6C,$6C,$38
        .byte   $00,$08,$18,$38,$18,$18,$18,$3C
        .byte   $00,$38,$6C,$0C,$18,$30,$60,$7C
        .byte   $00,$38,$6C,$0C,$38,$0C,$6C,$38
        .byte   $00,$6C,$6C,$6C,$7C,$0C,$0C,$0C
        .byte   $00,$7C,$60,$78,$0C,$0C,$6C,$38
        .byte   $00,$0C,$18,$30,$78,$6C,$6C,$38
        .byte   $00,$7C,$0C,$0C,$18,$30,$30,$30
        .byte   $00,$38,$6C,$6C,$38,$6C,$6C,$38
        .byte   $00,$38,$6C,$6C,$3C,$18,$30,$60
        .byte   $00,$00,$18,$18,$00,$18,$18,$00
        .byte   $00,$00,$18,$18,$00,$18,$18,$08
        .byte   $30,$00,$03,$00,$60,$00,$06,$00
        .byte   $00,$00,$00,$7C,$00,$7C,$00,$00
        .byte   $00,$60,$30,$18,$0C,$18,$30,$60
        .byte   $00,$38,$6C,$0C,$18,$00,$18,$18
        .byte   $FE,$FE,$FE,$FE,$FE,$FE,$FE,$FE
        .byte   $00,$0E,$1E,$36,$36,$3E,$36,$66
        .byte   $00,$7C,$36,$36,$3C,$36,$36,$7C
        .byte   $00,$1C,$36,$60,$60,$60,$66,$3C
        .byte   $00,$7C,$36,$36,$36,$36,$36,$7C
        .byte   $00,$7E,$30,$30,$3C,$30,$30,$7E
        .byte   $00,$3E,$30,$30,$3C,$30,$30,$60
        .byte   $00,$1C,$36,$60,$60,$6E,$66,$3C
        .byte   $00,$66,$66,$66,$7E,$66,$66,$66
        .byte   $00,$7E,$18,$18,$18,$18,$18,$7E
        .byte   $00,$3E,$06,$06,$06,$66,$66,$3C
        .byte   $00,$66,$6C,$78,$70,$78,$6C,$66
        .byte   $00,$30,$30,$30,$30,$30,$38,$6E
        .byte   $00,$42,$66,$7E,$7E,$66,$66,$66
        .byte   $00,$46,$66,$76,$7E,$6E,$66,$62
        .byte   $00,$3C,$66,$66,$66,$66,$66,$3C
        .byte   $00,$7C,$66,$66,$7C,$60,$60,$70
        .byte   $00,$3C,$66,$66,$66,$66,$6C,$36
        .byte   $00,$7C,$66,$66,$7C,$6C,$66,$66
        .byte   $00,$1C,$36,$60,$3C,$06,$66,$3C
        .byte   $00,$7E,$18,$18,$18,$18,$18,$18
        .byte   $00,$66,$66,$66,$66,$66,$66,$3C
        .byte   $00,$66,$66,$66,$66,$66,$3C,$18
        .byte   $00,$66,$66,$66,$66,$7E,$66,$42
        .byte   $00,$66,$66,$3C,$18,$3C,$66,$66
        .byte   $00,$66,$66,$66,$3C,$18,$18,$18
        .byte   $00,$7E,$06,$0C,$7E,$30,$60,$7E
        .byte   $00,$66,$66,$7E,$7E,$66,$66,$00
        .byte   $00,$00,$54,$38,$10,$10,$28,$44
        .byte   $00,$18,$18,$7E,$7E,$18,$18,$00
        .byte   $00,$00,$10,$38,$6C,$00,$00,$00
        .byte   $00,$00,$10,$38,$54,$10,$28,$28
        .byte   $00,$00,$00,$7C,$7C,$38,$7C,$00
        .byte   $00,$00,$00,$3C,$6C,$6C,$6C,$36
        .byte   $00,$30,$30,$3C,$36,$36,$36,$6C
        .byte   $00,$00,$00,$3C,$66,$60,$66,$3C
        .byte   $00,$0C,$0C,$3C,$6C,$6C,$6C,$36
        .byte   $00,$00,$00,$3C,$66,$7E,$60,$3E
        .byte   $00,$1C,$36,$30,$7E,$30,$30,$60
        .byte   $00,$00,$00,$3C,$66,$3E,$06,$7C
        .byte   $00,$60,$60,$60,$78,$6C,$6C,$66
        .byte   $00,$00,$18,$00,$18,$18,$18,$3C
        .byte   $00,$0C,$00,$0C,$0C,$6C,$6C,$38
        .byte   $00,$60,$60,$66,$6C,$78,$6C,$66
        .byte   $00,$38,$18,$18,$18,$18,$18,$3C
        .byte   $00,$00,$00,$42,$66,$7E,$66,$66
        .byte   $00,$00,$00,$6C,$76,$66,$66,$66
        .byte   $00,$00,$00,$3C,$66,$66,$66,$3C
        .byte   $00,$00,$00,$7C,$66,$7C,$60,$70
        .byte   $00,$00,$00,$3E,$66,$3C,$0C,$06
        .byte   $00,$00,$00,$6C,$76,$60,$60,$60
        .byte   $00,$00,$00,$3C,$60,$3C,$06,$7C
        .byte   $00,$30,$30,$7C,$30,$30,$36,$1C
        .byte   $00,$00,$00,$6C,$6C,$6C,$6C,$36
        .byte   $00,$00,$00,$66,$66,$66,$3C,$18
        .byte   $00,$00,$00,$66,$66,$7E,$66,$42
        .byte   $00,$00,$00,$66,$3C,$18,$3C,$66
        .byte   $00,$00,$00,$66,$66,$3E,$0C,$38
        .byte   $00,$00,$00,$7E,$0C,$18,$30,$7E
        .byte   $00,$00,$10,$7C,$10,$38,$28,$28
        .byte   $6C,$3C,$38,$66,$66,$38,$3C,$6C
        .byte   $3C,$38,$66,$6C,$6C,$66,$38,$3C
        .byte   $38,$66,$6C,$3C,$3C,$6C,$66,$38
        .byte   $66,$6C,$3C,$38,$38,$3C,$6C,$66




;-----------------------------------------------------------
;                           start
;
; Called by hello.prg after the system has been initialized.
;-----------------------------------------------------------

start:  lda     #$00                    ; Disable screen
        sta     VIC_CTRL1

        ldx     #$20                    ; Fill memory $2000-$5FFF with $40
        stx     $FD
        lda     #$00
        tay
        sta     $FC
        ldx     #$40
@loop:  sta     ($FC),y
        iny
        bne     @loop
        inc     $FD
        dex
        bne     @loop

        lda     #$08
        sta     $FE
        lda     #$60                    ; Copy from $0C9E-$0EB5 to $4660-$4877
        sta     @store + 1
        lda     #$46
        sta     @store + 2
        lda     #$9E
        sta     @load + 1
        lda     #$0C
        sta     @load + 2
@copy_block:
        ldx     #$02                    ; Copy $0218 bytes
        ldy     #$18
@load:  lda     $0C9E
@store: sta     $2500
        inc     @load + 1
        bne     @increment_store
        inc     @load + 2
@increment_store:
        inc     @store + 1
        bne     @advance
        inc     @store + 2
@advance:
        dey
        bne     @load
        dex
        bne     @load

        lda     @store + 1              ; Advance storage target by $28 bytes to $48A0
        clc
        adc     #$28
        sta     @store + 1
        lda     @store + 2
        adc     #$00
        sta     @store + 2

        dec     $FE
        bne     @copy_block             ; Copy 7 more times, each time advancing target start by $0240 bytes...
        
        ldx     #$00
        lda     #$60
L0C6B:  sta     $0400,x
        sta     $0500,x
        sta     $0600,x
        sta     $06F0,x
        inx
        bne     L0C6B
        lda     #$00
        sta     VIC_BORDERCOLOR
        lda     #$37
        sta     VIC_CTRL1
        lda     #$08
        sta     VIC_CTRL2
        lda     #$18
        sta     VIC_VIDEO_ADR
        jsr     L1578
        ldx     #$05
        jsr     LC486
        ldx     #$0C
        jsr     LC480
        jmp     L6800




L0C9E:  .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $03,$03,$06,$06,$0C,$0C,$18,$18
        .byte   $FF,$00,$00,$00,$00,$00,$01,$01
        .byte   $FF,$20,$60,$60,$C0,$C0,$80,$80
        .byte   $FF,$02,$06,$06,$0C,$0C,$18,$18
        .byte   $FF,$00,$00,$01,$03,$07,$0F,$1F
        .byte   $FF,$78,$F8,$F8,$F8,$F8,$F8,$F8
        .byte   $FF,$02,$06,$06,$0C,$0C,$18,$18
        .byte   $FF,$00,$00,$00,$00,$00,$01,$01
        .byte   $FF,$20,$60,$60,$C0,$C0,$80,$80
        .byte   $FF,$02,$06,$06,$0C,$0C,$18,$18
        .byte   $FF,$00,$00,$00,$00,$03,$0F,$1F
        .byte   $FF,$00,$00,$00,$FF,$FF,$FF,$00
        .byte   $FF,$00,$00,$00,$FF,$FF,$FF,$00
        .byte   $FF,$00,$00,$00,$C0,$E0,$F0,$78
        .byte   $FF,$00,$00,$00,$00,$00,$03,$07
        .byte   $FF,$00,$00,$00,$3F,$FF,$FF,$80
        .byte   $FF,$00,$00,$00,$FF,$FF,$FF,$00
        .byte   $FF,$00,$00,$00,$F0,$F8,$FE,$0E
        .byte   $FF,$00,$00,$00,$00,$00,$00,$00
        .byte   $FF,$00,$00,$00,$78,$78,$F0,$F0
        .byte   $FF,$00,$00,$00,$00,$01,$03,$07
        .byte   $FF,$00,$00,$00,$FF,$FF,$FF,$C0
        .byte   $FF,$00,$00,$00,$FF,$FF,$FF,$00
        .byte   $FF,$00,$00,$00,$E0,$F8,$FE,$1E
        .byte   $FF,$00,$00,$00,$00,$00,$00,$00
        .byte   $FF,$00,$00,$00,$78,$78,$F0,$F0
        .byte   $FF,$00,$00,$00,$00,$03,$03,$07
        .byte   $FF,$00,$00,$00,$00,$80,$80,$C0
        .byte   $FF,$00,$00,$00,$00,$00,$00,$00
        .byte   $FF,$00,$00,$00,$00,$3C,$3C,$78
        .byte   $FF,$00,$01,$01,$03,$03,$06,$06
        .byte   $C0,$C0,$80,$80,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$01,$01
        .byte   $30,$30,$7F,$60,$C0,$C0,$80,$80
        .byte   $03,$03,$FF,$06,$0C,$0C,$18,$18
        .byte   $00,$00,$FF,$00,$00,$00,$01,$01
        .byte   $30,$30,$FF,$60,$C0,$C0,$80,$80
        .byte   $3F,$7F,$FF,$0F,$0F,$1E,$1E,$3C
        .byte   $F8,$F8,$FF,$00,$00,$00,$01,$01
        .byte   $30,$30,$FF,$60,$C0,$C0,$80,$80
        .byte   $03,$03,$FF,$06,$0C,$0C,$18,$18
L0E0E:  .byte   $00,$00,$FF,$00,$00,$00,$01,$01
        .byte   $30,$30,$E0,$60,$C0,$C0,$80,$81
        .byte   $1E,$3C,$3C,$78,$78,$F0,$F0,$E0
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$01,$01,$03,$03,$07
        .byte   $78,$F0,$F0,$E0,$E0,$C0,$C0,$80
        .byte   $07,$0F,$0F,$1E,$1E,$3C,$3C,$78
        .byte   $80,$00,$00,$00,$00,$00,$00,$03
        .byte   $00,$00,$00,$00,$00,$00,$0F,$FF
        .byte   $1E,$1E,$3C,$3C,$38,$F8,$E0,$80
        .byte   $01,$01,$03,$03,$07,$07,$0F,$0F
        .byte   $E0,$E0,$C0,$C0,$80,$80,$00,$00
        .byte   $07,$0F,$0F,$1E,$1E,$3C,$3C,$78
        .byte   $C0,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $1E,$3C,$3C,$78,$78,$00,$00,$00
        .byte   $01,$01,$03,$03,$07,$07,$0F,$0F
        .byte   $E0,$E0,$C0,$C0,$80,$80,$00,$00
        .byte   $07,$0F,$0F,$1F,$1F,$3C,$3C,$78
        .byte   $C0,$E0,$E0
L0EA9:  .byte               $F0,$F0,$78,$78,$3C
        .byte   $00,$00,$00,$01,$01,$03,$03,$07




        sei
        beq     L0EA9
        cpx     #$E0
        cpy     #$C0
        .byte   $80
        .byte   $0C
        .byte   $0C
        clc
        clc
        bmi     L0EF4
        rts
        rts
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        .byte   $03
        .byte   $03
        asl     $06
        .byte   $0F
        .byte   $0C
        clc
        clc
        brk
        brk
        brk
        brk
        .byte   $FF
        brk
        ora     ($03,x)
        bmi     L0F20
        rts
        rts
        .byte   $FF
L0EF4           := * + 1
        cpy     #$80
        .byte   $80
        .byte   $03
        .byte   $03
        asl     $06
        .byte   $FF
        .byte   $0C
        clc
        clc
        brk
        brk
        brk
        brk
        .byte   $FF
        ora     ($01,x)
        .byte   $03
        .byte   $3C
        sei
        sei
L0F0A           := * + 1
        beq     L0F0A
        cpx     #$E0
L0F0E           := * + 1
        cpy     #$03
L0F0F:  .byte   $03
        asl     $06
        .byte   $FF
        .byte   $0C
        clc
        clc
        brk
        brk
        brk
        brk
        .byte   $FF
        brk
        ora     ($01,x)
L0F1E:
L0F1F           := * + 1
        bmi     L0F50
L0F20:  rts
        rts
        .byte   $FF
L0F24           := * + 1
        cpy     #$C0
        cpy     #$03
        .byte   $03
        asl     $06
        .byte   $FC
        .byte   $0C
        clc
        clc
        ora     ($03,x)
        .byte   $03
        .byte   $07
        .byte   $07
        .byte   $0F
        .byte   $0F
        asl     $C0E0,x
L0F39           := * + 1
        cpy     #$80
        .byte   $80
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        .byte   $07
        .byte   $0F
        .byte   $0F
        asl     $3C1E,x
        .byte   $3C
        sei
        .byte   $80
        brk
L0F50:  brk
        ora     ($01,x)
        .byte   $03
        .byte   $03
        .byte   $07
        sei
        beq     L0F39
        cpx     #$E0
        cpy     #$C0
        .byte   $80
        .byte   $0F
        .byte   $1F
        asl     L0F0E,x
        .byte   $07
        .byte   $03
        ora     ($F8,x)
        .byte   $80
        brk
        brk
        .byte   $80
        .byte   $80
        cpx     #$F0
L0F6E:  brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        asl     $3C1E,x
L0F79:  .byte   $3C
        sei
        sei
        beq     L0F6E
        brk
        brk
        brk
        ora     ($01,x)
        .byte   $03
        .byte   $03
        .byte   $07
        sei
        beq     L0F79
        cpx     #$E0
        cpy     #$C0
        .byte   $80
        brk
        .byte   $03
        .byte   $03
        .byte   $03
        brk
        brk
        brk
        brk
        brk
        .byte   $FF
        .byte   $FF
        .byte   $FF
        .byte   $0F
        .byte   $0F
        .byte   $0F
        .byte   $0F
L0F9E:  brk
        cpy     #$C0
        cpy     #$80
        .byte   $80
        brk
        brk
        asl     $3C1E,x
L0FA9:  .byte   $3C
        sei
        sei
        beq     L0F9E
        brk
        brk
        brk
        ora     ($01,x)
        .byte   $03
        .byte   $03
        .byte   $07
        sei
        beq     L0FA9
        cpx     #$E0
        cpy     #$C0
        .byte   $80
        .byte   $3C
        asl     L0F1E,x
        .byte   $0F
        .byte   $07
        .byte   $07
        .byte   $03
        .byte   $07
        .byte   $0F
        .byte   $0F
        asl     $BC1E,x
        ldy     $80F8,x
        brk
        ora     ($01,x)
        .byte   $03
        .byte   $03
        asl     $06
        cpy     #$C0
        .byte   $80
        .byte   $80
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        ora     ($30,x)
        bmi     L1059
        .byte   $63
        .byte   $8F
        .byte   $3F
        .byte   $FF
        .byte   $FF
        .byte   $0F
        .byte   $3F
        inc     $FCFE,x
        .byte   $FF
        .byte   $FF
        .byte   $FF
        brk
        brk
        brk
        brk
        brk
        .byte   $FF
        .byte   $FF
        .byte   $FF
        bmi     L1040
        rts
        rts
        cpy     #$FF
        .byte   $FF
        .byte   $FF
        .byte   $03
        .byte   $07
        .byte   $07
        .byte   $0F
        .byte   $0F
        .byte   $FF
        .byte   $FF
        .byte   $FF
        cpy     #$80
        .byte   $80
        brk
        brk
        .byte   $FF
        .byte   $FF
        .byte   $FF
        bmi     L1058
        rts
        rts
        cpy     #$FF
        .byte   $FF
        .byte   $FF
        .byte   $03
        .byte   $03
        .byte   $07
        .byte   $07
        .byte   $0F
        .byte   $FF
        .byte   $FF
        .byte   $FF
        cpx     #$F0
        sed
        .byte   $FC
        inc     $FFFF,x
        .byte   $FF
        bmi     L1070
L1040:  rts
        rts
        rti
        brk
        .byte   $80
        brk
        asl     $3C3C,x
        .byte   $1F
        .byte   $0F
        .byte   $07
        brk
        brk
        brk
        brk
        brk
L1051:  .byte   $FF
        .byte   $FF
        .byte   $FF
        brk
        brk
        brk
        brk
L1058:
L1059           := * + 1
        ora     ($FF,x)
        .byte   $FF
        inc     a:L0000,x
        sei
        beq     L1051
        cpx     #$80
        brk
        brk
        brk
        .byte   $07
        .byte   $0F
        .byte   $0F
        asl     $1E1E,x
        brk
        brk
        .byte   $80
        brk
L1070:  brk
        brk
        brk
        brk
        brk
        brk
        ora     (L0000,x)
L1078:  brk
        brk
        brk
        brk
        brk
        brk
        beq     L1078
        sei
        sei
        sec
        sec
        brk
        brk
        ora     ($01,x)
        .byte   $03
        .byte   $03
        .byte   $07
        .byte   $07
        brk
        brk
        cpx     #$E0
        cpy     #$C0
        .byte   $80
L1093:  .byte   $80
        brk
        brk
        .byte   $07
        .byte   $0F
        .byte   $0F
        .byte   $0F
        .byte   $03
        brk
        brk
        brk
        .byte   $80
        brk
        brk
        .byte   $FF
        .byte   $FF
        .byte   $FF
        brk
        brk
        brk
        brk
        brk
        .byte   $FF
        .byte   $FF
        .byte   $FF
        brk
        brk
        asl     $783C
        beq     L1093
        cpy     #$00
        brk
        ora     ($01,x)
        .byte   $03
        .byte   $03
        .byte   $07
        .byte   $07
        brk
        brk
        cpx     #$E0
        cpy     #$C0
        .byte   $80
        .byte   $80
        brk
        brk
        .byte   $07
        .byte   $0F
        .byte   $0F
        asl     $1E1E,x
        brk
        brk
        .byte   $80
        brk
        brk
L10D1:  brk
        brk
        brk
        brk
        brk
        .byte   $03
        ora     ($01,x)
        brk
        brk
        brk
        brk
        brk
        sed
        beq     L10D1
        cpx     #$E0
        cpx     #$00
        brk
        .byte   $0C
        .byte   $0C
        clc
        clc
        bmi     L111C
        rts
        rts
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        .byte   $02
        .byte   $02
L1108:  asl     $06
        .byte   $0C
        .byte   $0C
        clc
        clc
        .byte   $FF
        .byte   $3F
        .byte   $0F
        .byte   $03
        brk
        brk
        ora     ($01,x)
        beq     L1108
        cpx     #$E0
        cpy     #$C0
L111C:  .byte   $80
        .byte   $80
        .byte   $03
        .byte   $03
        asl     $06
        .byte   $0C
L1123:  .byte   $0C
        clc
        clc
        brk
        brk
        brk
        brk
        brk
        ora     ($01,x)
        .byte   $03
        .byte   $3C
        sei
        sei
        beq     L1123
        cpx     #$E0
        cpy     #$03
        .byte   $03
        asl     $06
        .byte   $0C
        .byte   $0C
        clc
        clc
        brk
        brk
        brk
        brk
        brk
        brk
        ora     ($01,x)
        .byte   $7F
        .byte   $7F
        .byte   $7F
        ror     $E0F8,x
        cpy     #$80
        sed
        .byte   $E2
        stx     $06
        .byte   $0C
        .byte   $0C
        clc
        clc
        brk
        brk
        brk
        brk
        brk
        brk
        .byte   $03
        .byte   $0F
        brk
        brk
        brk
        brk
        brk
        brk
        sed
        sed
        brk
        brk
        brk
        brk
        brk
        brk
        sec
        sec
        brk
        brk
        brk
        brk
        brk
        brk
        sec
        sec
        brk
        brk
        brk
        brk
        brk
        brk
        .byte   $0F
        .byte   $3F
        brk
        brk
        brk
        brk
        brk
        brk
        cpx     #$E0
L1186:  brk
        brk
        brk
        brk
        brk
        brk
        .byte   $FF
        .byte   $FF
        brk
        brk
        brk
        brk
        brk
        brk
        beq     L1186
        brk
        brk
        brk
        brk
        brk
        brk
        .byte   $FF
        .byte   $FF
        brk
        brk
        brk
        brk
        brk
        brk
        .byte   $C3
        .byte   $C3
        brk
        brk
        brk
        brk
        brk
        brk
        .byte   $80
        .byte   $80
        brk
        brk
        brk
        brk
        brk
        brk
        .byte   $3C
        .byte   $7C
        brk
        brk
        brk
        brk
        brk
        brk
        .byte   $0F
        .byte   $3F
        brk
        brk
        brk
        brk
        brk
        brk
        cpx     #$E0
L11C6:  brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        beq     L11C6
        brk
        brk
        brk
        brk
        brk
        brk
        .byte   $E3
        .byte   $E3
        brk
        brk
        brk
        brk
        brk
        brk
        .byte   $80
        .byte   $83
        brk
        brk
        brk
        brk
        brk
        brk
        sed
        sed
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        ora     ($01,x)
        .byte   $03
        .byte   $03
        asl     $06
        cpy     #$C0
        .byte   $80
        .byte   $80
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        ora     ($01,x)
        .byte   $3F
        bmi     L1281
        rts
        cpy     #$C0
        .byte   $80
        .byte   $80
        .byte   $FF
        .byte   $03
        asl     $06
        .byte   $0C
        .byte   $0C
        clc
        clc
        .byte   $FF
        brk
        brk
        brk
        brk
        brk
        ora     ($01,x)
        .byte   $FF
        bmi     L1299
        rts
        cpy     #$C0
        .byte   $80
        .byte   $80
        .byte   $FF
        .byte   $07
        .byte   $07
        .byte   $0F
        .byte   $0F
        asl     $3C1E,x
        .byte   $FF
        .byte   $80
        .byte   $80
        brk
        brk
        brk
        ora     ($01,x)
        .byte   $FF
        bmi     L12B1
        rts
        cpy     #$C0
        .byte   $80
        .byte   $80
        .byte   $FF
        .byte   $03
        asl     $06
        .byte   $0C
        .byte   $0C
        clc
        clc
        .byte   $FF
        brk
        brk
L1261:  brk
        brk
        brk
        ora     ($01,x)
        beq     L1298
        rts
L1269:  rts
        cpy     #$C0
        .byte   $80
        .byte   $80
        asl     $3838,x
L1271:  rol     $070F,x
        .byte   $03
        brk
        brk
        brk
        brk
        brk
        .byte   $80
        cpy     #$E0
        cpx     #$70
        bvs     L1261
L1281:  cpx     #$FF
        .byte   $FF
        asl     $701E,x
        bvs     L1269
        cpx     #$C0
        cpy     #$00
        brk
        sei
        beq     L1271
        sed
        rol     L0F1F,x
        .byte   $07
        brk
        brk
L1298:  brk
L1299:  brk
        brk
        brk
        .byte   $80
        .byte   $80
        .byte   $0F
        .byte   $0F
        asl     $3C1E,x
        .byte   $3C
        sei
        sei
        ora     ($01,x)
        .byte   $03
        .byte   $03
        .byte   $07
        .byte   $07
        .byte   $0F
        .byte   $0F
        cpx     #$E0
L12B1           := * + 1
        cpy     #$C0
        inc     a:$FE,x
        brk
        .byte   $03
        .byte   $07
        .byte   $07
        .byte   $0F
        .byte   $0F
L12BB:  asl     $3C1E,x
        cpx     #$E3
        .byte   $FF
        ror     $0178,x
        ora     ($03,x)
        .byte   $FC
        sed
        sed
        beq     L12BB
        cpx     #$E0
        cpy     #$38
        beq     L12B1
        sed
        rol     L0F0F,x
        .byte   $07
        brk
        brk
        brk
        brk
        brk
        brk
        .byte   $80
        .byte   $80
        ora     ($01,x)
        .byte   $03
        .byte   $03
        .byte   $07
        .byte   $07
        .byte   $0F
        .byte   $0F
        sbc     ($E1,x)
        .byte   $C3
        .byte   $C3
        .byte   $83
        .byte   $87
        .byte   $07
        .byte   $0F
        .byte   $F3
        .byte   $F3
        .byte   $FB
        .byte   $FB
        .byte   $FF
        ldx     $3CBE,y
        .byte   $83
        .byte   $87
        .byte   $07
        asl     $1C0E
        .byte   $1C
        sec
        .byte   $80
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        .byte   $0C
        .byte   $0C
        clc
        clc
        bmi     L1344
        rts
        rts
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        .byte   $03
        .byte   $03
        .byte   $07
        asl     $0C
        .byte   $0C
        clc
        clc
        brk
        brk
        .byte   $FF
        brk
        brk
        brk
        ora     ($01,x)
L133E:  bmi     L1370
        .byte   $FF
        rts
        cpy     #$C0
L1344:  .byte   $80
        .byte   $80
        .byte   $03
        .byte   $03
        .byte   $FF
        asl     $0C
        .byte   $0C
        clc
        clc
        brk
        brk
        .byte   $FF
        .byte   $1F
        .byte   $1F
        .byte   $1F
        .byte   $1F
        .byte   $1F
        .byte   $3C
        sei
        .byte   $FF
        inc     $F8FC,x
        beq     L133E
        .byte   $03
        .byte   $03
        .byte   $FF
        asl     $0C
        .byte   $0C
        clc
        clc
        brk
        brk
        .byte   $FF
        brk
        brk
        brk
        ora     ($01,x)
        bmi     L13A0
L1370:  .byte   $FF
        rts
        cpy     #$C0
        .byte   $80
        .byte   $80
        .byte   $03
        .byte   $03
        inc     $0C06,x
        .byte   $0C
        clc
        clc
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        .byte   $03
        .byte   $FF
        inc     a:L0000,x
        brk
        brk
        cpx     #$C0
        .byte   $80
        brk
        brk
        brk
        brk
        brk
        .byte   $3C
        .byte   $3C
        sei
        sei
        brk
        brk
        brk
        brk
        brk
        brk
L13A0:  .byte   $03
        .byte   $03
        brk
        brk
        brk
        brk
        .byte   $03
        .byte   $0F
L13A8:  inc     a:$F8,x
        brk
        brk
        brk
        .byte   $80
        brk
        ora     ($01,x)
        brk
        brk
        brk
        brk
        beq     L13A8
        cpx     #$E0
        brk
        brk
        brk
        brk
        asl     $3F1E,x
        .byte   $3F
        brk
        brk
        brk
        brk
        brk
        brk
        sed
        sed
        brk
        brk
        brk
        brk
        .byte   $3C
        sei
        sei
        sei
        brk
        brk
        brk
        brk
        .byte   $03
        .byte   $07
        .byte   $07
        .byte   $07
        brk
        brk
        brk
        brk
        cpy     #$80
        .byte   $83
        .byte   $83
        brk
        brk
        brk
        brk
        .byte   $03
        .byte   $0F
        inc     a:$F8,x
        brk
        brk
        brk
        .byte   $80
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        asl     $3C1E,x
        .byte   $3C
        brk
        brk
        brk
        brk
        .byte   $0F
        asl     L0E0E
        brk
        brk
        brk
        brk
        .byte   $3C
        sec
        sec
        sec
        brk
        brk
        brk
        brk
        sec
        sec
        .byte   $3F
        .byte   $0F
        brk
        brk
        brk
        brk
        brk
        brk
        .byte   $83
        .byte   $83
        brk
        brk
        brk
        brk
        brk
        brk
        ora     ($01,x)
        .byte   $03
        .byte   $03
        asl     $06
        cpy     #$C0
        .byte   $80
        .byte   $80
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        bmi     L1478
        rts
        rts
        .byte   $FF
        brk
        brk
        brk
        .byte   $03
        .byte   $03
        asl     $06
        .byte   $FF
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        .byte   $FF
        brk
        brk
        brk
        bmi     L1490
        rts
        rts
        .byte   $FF
        brk
        brk
        brk
        .byte   $1F
        .byte   $1F
        .byte   $1F
        asl     a:$FF,x
        brk
        brk
        cpy     #$80
        brk
        brk
        .byte   $FF
        brk
        brk
        brk
        bmi     L14A8
L1478:  rts
        rts
        .byte   $FF
        brk
        brk
        brk
        .byte   $03
        .byte   $03
        asl     $06
        .byte   $FF
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        .byte   $FF
        brk
        brk
        brk
        bmi     L14C0
L1490:  rts
        rts
        .byte   $FF
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        .byte   $FF
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        .byte   $FF
        brk
        brk
        brk
        brk
        brk
L14A8:  brk
        brk
        .byte   $FF
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        .byte   $FF
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        .byte   $FF
        brk
        brk
        brk
        brk
        brk
L14C0:  brk
        brk
        .byte   $FF
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        .byte   $FF
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        .byte   $FF
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        .byte   $FF
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        .byte   $FF
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        .byte   $FF
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        .byte   $FF
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        .byte   $FF
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        .byte   $FF
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        .byte   $FF
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        .byte   $FF
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        .byte   $FF
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        .byte   $FF
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        .byte   $FF
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        .byte   $FF
        brk
        brk
        brk
        .byte   $0C
        .byte   $0C
        clc
        clc
        beq     L153C
L153C:  brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        brk
        lda     #$20
        tax
        sta     $E3
        lda     #$00
        tay
        sta     $E2
L1568:  sta     ($E2),y
        iny
        bne     L1568
        inc     $E3
        dex
        bne     L1568
        jsr     L1578
L1575:  jmp     L1575
L1578:  ldx     #$FF
        stx     $E0
        stx     $E1
        inx
        stx     $E7
        stx     $E8
L1583:  lsr     $E1
        ror     $E0
        bcc     L158F
        lda     $E1
        eor     #$B4
        sta     $E1
L158F:  lda     $E0
        sta     $E2
        sta     $E5
        lda     $E1
        and     #$1F
        cmp     #$06
        bcc     L15CB
        cmp     #$11
        bcs     L15CB
        clc
        adc     #$20
        sta     $E3
        adc     #$20
        sta     $E6
        lda     $E1
        and     #$E0
        rol     a
        rol     a
        rol     a
        rol     a
        tay
        sec
        lda     #$00
L15B6:  ror     a
        dey
        bpl     L15B6
        iny
        tax
        and     ($E5),y
        beq     L15CB
        sta     $E9
        txa
        eor     #$FF
        and     ($E2),y
        ora     $E9
        sta     ($E2),y
L15CB:  inc     $E7
        bne     L1583
        inc     $E8
        bne     L1583
        lda     $4000
        sta     $2000
        rts
        .byte   $CE
