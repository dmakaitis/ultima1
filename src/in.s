;-------------------------------------------------------------------------------
;
; in.s
;
;-------------------------------------------------------------------------------


.include "c64.inc"
.include "kernel.inc"
.include "global.inc"

        .setcpu "6502"

TXTPTR          := $007A                        ; Pointer into BASIC source code

;-------------------------------------------------------------------------------
;
; The load address for this file is always set to $2000, but is ignored. The
; actual location where this code should be loaded into memory is $6800.
;
;-------------------------------------------------------------------------------

.segment    "LOADADDR"

        .addr   $2000

.code

main:   jmp     decompress_image




j6803:  jsr     s6968
        lda     #$40
        sta     $61
        lda     #$00
        sta     $60
        tay
        ldx     #$24
@loop:  sta     ($60),y
        iny
        bne     @loop
        inc     $61
        dex
        bne     @loop

        ldx     #$0D                    ; Load MI at $7400
        jsr     load_file_cached
        jmp     mi_main                 ; Execute MI




decompress_image:
        lda     #$00                    ; Write to bitmap buffer at $4000
        sta     store_vector
        lda     #$40
        sta     store_vector + 1
        lda     #<compressed_image      ; Read from compressed image data
        sta     load_vector
        lda     #>compressed_image
        sta     load_vector + 1

@decompress_loop:
        jsr     lda_and_advance
        cmp     #$DA
        beq     b6883
        cmp     #$00                    ; If the next byte is $00, $10, $FF, $E6, $16, or
        beq     @store_run              ; $50, then it is a run and the following byte contains
        cmp     #$10                    ; the number of times the value should be repeated
        beq     @store_run
        cmp     #$FF
        beq     @store_run
        cmp     #$E6
        beq     @store_run
        cmp     #$16
        beq     @store_run
        cmp     #$50
        beq     @store_run

        jsr     sta_and_advance
        jmp     @decompress_loop

@store_run:
        pha
        jsr     lda_and_advance
        tax
        pla
@loop:  jsr     sta_and_advance
        dex
        bne     @loop
        jmp     @decompress_loop




;-----------------------------------------------------------
;                       lda_and_advance
;
; Loads the value stored at the memory location pointed to 
; by 'load_vector' into the accumulator, then advances
; 'load_vector' by one.
;-----------------------------------------------------------

lda_and_advance:
load_vector     := * + 1
        lda     compressed_image
        inc     load_vector
        bne     @exit
        inc     load_vector + 1
@exit:  rts




;-----------------------------------------------------------
;                       sta_and_advance
;
; Stores the value in the accumulator into the memory
; location pointed to by 'store_vector', then advances
; 'store_vector' by one.
;-----------------------------------------------------------

sta_and_advance:
store_vector    := * + 1
        sta     $4000
        inc     store_vector
        bne     @exit
        inc     store_vector + 1
@exit:  rts




b6883:  lda     #$00
        sta     $1200
        lda     #$20
        sta     $12C0
        ldx     #$00
b688F:  lda     $1200,x
        clc
        adc     #$01
        inx
        sta     $1200,x
        and     #$07
        bne     b68BB
        dex
        lda     $12C0,x
        clc
        adc     #$01
        inx
        sta     $12C0,x
        lda     $1200,x
        and     #$F0
        clc
        adc     #$40
        sta     $1200,x
        bcc     b68C3
        inc     $12C0,x
        jmp     b68C3
b68BB:  dex
        lda     $12C0,x
        inx
        sta     $12C0,x
b68C3:  cpx     #$BF
        bne     b688F
        lda     #$38
        sta     $5E
        lda     #$01
        sta     $5F
        ldx     #$27
b68D1:  lda     $5E
        sta     $15B0,x
        sec
        sbc     #$08
        sta     $5E
        lda     $5F
        sta     $15D8,x
        sbc     #$00
        sta     $5F
        dex
        bpl     b68D1
j68E7:  inc     d6A16
        jsr     s6BED
        jsr     s6F57
        jsr     s6978
        jsr     s6958
        jsr     s6D7F
        jsr     s6A57
        lda     #$00
        jsr     s6E37
        jsr     s6CCE
        jsr     s6F57
        lda     #$01
        jsr     s6E37
        jsr     s6C17
        jsr     s6CCE
        jsr     s6F57
        lda     #$02
        jsr     s6E37
        jsr     s6CCE
        jsr     s6CCE
        jsr     s6F57
        jsr     s6A96
        jsr     s6A37
        jsr     s6CCE
        jsr     s6AE0
        lda     #$20
        sta     $86
b6933:  lda     #$20
        sta     d6D16
        jsr     s6CD3
        dec     $86
        bne     b6933
        jsr     s6968
        lda     #$10
        sta     $86
b6946:  lda     #$10
        sta     d6D16
        jsr     s6CF2
        dec     $86
        bpl     b6946
        jmp     j68E7
j6955:  jmp     j6955
s6958:  lda     #$80
        sta     VIC_VIDEO_ADR
        lda     #$96
        sta     CIA2_PRA
        lda     #$FF
        sta     VIC_SPR_ENA
        rts
s6968:  lda     #$18
        sta     VIC_VIDEO_ADR
        lda     #$97
        sta     CIA2_PRA
        lda     #$00
        sta     VIC_SPR_ENA
        rts
s6978:  lda     #$00
        sta     $7B
        sta     TXTPTR
        sta     $79
        sta     $7C
        sta     $7E
        sta     $82
        sta     $83
        sta     $84
        sta     $87
        tax
b698D:  sta     $6400,x
        sta     $6500,x
        inx
        bne     b698D
        ldx     #$12
b6998:  lda     #$03
        sta     $6540,x
        lda     #$00
        sta     $6582,x
        dex
        bpl     b6998
        ldx     #$07
b69A7:  lda     d6A2F,x
        sta     $63F8,x
        dex
        bpl     b69A7
        lda     #$00
        sta     VIC_SPR_HI_X
        lda     #$1E
        sta     VIC_SPR_BG_PRIO
        ldx     #$0F
b69BC:  lda     d6A17,x
        sta     VIC_SPR0_X,x
        cpx     #$08
        bcs     b69CC
        lda     d6A27,x
        sta     VIC_SPR0_COLOR,x
b69CC:  dex
        bpl     b69BC
        ldx     #$3F
        lda     #$FF
b69D3:  sta     $6540,x
        sta     $6580,x
        dex
        bpl     b69D3
        lda     d6A16
        and     #$0F
        beq     b69F9
        ldx     #$26
b69E5:  lda     d765D,x
        sta     $64C0,x
        lda     d7684,x
        sta     $6500,x
        dex
        bpl     b69E5
        lda     #$00
        sta     $85
        rts
b69F9:  ldx     #$0E
b69FB:  lda     d7518,x
        sta     $64C0,x
        sta     $6500,x
        dex
        bpl     b69FB
        lda     #$FF
        sta     $85
        lda     #$B2
        sta     VIC_SPR5_Y
        lda     #$02
        sta     VIC_SPR5_COLOR
        rts
d6A16:  .byte   $00
d6A17:  .byte   $44,$C4,$00,$00,$00,$00,$53,$A5
        .byte   $60,$A5,$00,$A8,$00,$00,$00,$00
d6A27:  .byte   $01,$01,$0A,$00,$00,$01,$01,$01
d6A2F:  .byte   $90,$91,$92,$95,$96,$93,$97,$97
s6A37:  lda     #$00
        sta     $60
        sta     $62
        tay
        lda     #$40
        sta     $61
        lda     #$80
        sta     $63
        ldx     #$20
b6A48:  lda     ($60),y
        sta     ($62),y
        iny
        bne     b6A48
        inc     $61
        inc     $63
        dex
        bne     b6A48
        rts
s6A57:  lda     #$A8
        sta     d6A7B
        lda     #$6F
        sta     d6A7C
        ldx     #$38
b6A63:  ldy     #$13
        lda     $1200,x
        clc
        adc     $15B0,y
        sta     $60
        lda     $12C0,x
        adc     $15D8,y
        adc     #$20
        sta     $61
        ldy     #$00
b6A7A:
d6A7B           := * + 1
d6A7C           := * + 2
        lda     d6FA8
        sta     ($60),y
        inc     d6A7B
        bne     b6A87
        inc     d6A7C
b6A87:  tya
        clc
        adc     #$08
        tay
        cpy     #$68
        bcc     b6A7A
        inx
        cpx     #$4D
        bcc     b6A63
        rts
s6A96:  ldx     #$30
        ldy     #$0B
        lda     $1200,x
        clc
        adc     $15B0,y
        sta     $62
        lda     $12C0,x
        adc     $15D8,y
        adc     #$20
        sta     $63
        lda     #$C0
        sta     $60
        lda     #$70
        sta     $61
        ldx     #$06
b6AB7:  ldy     #$00
b6AB9:  lda     ($60),y
        sta     ($62),y
        iny
        cpy     #$B8
        bcc     b6AB9
        lda     $60
        clc
        adc     #$B8
        sta     $60
        lda     $61
        adc     #$00
        sta     $61
        lda     $62
        clc
        adc     #$40
        sta     $62
        lda     $63
        adc     #$01
        sta     $63
        dex
        bne     b6AB7
        rts
s6AE0:  lda     #$70
        sec
        sbc     $7C
        tax
        lda     #$B5
        sta     d6B1D
        lda     #$76
        sta     d6B1E
        lda     #$A0
        sta     d6B1A
        lda     #$78
        sta     d6B1B
b6AFA:  ldy     #$1E
        lda     $1214,x
        clc
        adc     $15B0,y
        sta     $60
        sta     $62
        lda     $12D4,x
        adc     $15D8,y
        adc     #$20
        sta     $61
        adc     #$40
        sta     $63
        ldy     #$00
b6B17:  lda     ($62),y
d6B1A           := * + 1
d6B1B           := * + 2
        and     d78A0
d6B1D           := * + 1
d6B1E           := * + 2
        ora     d76B5
        sta     ($60),y
        inc     d6B1D
        bne     b6B29
        inc     d6B1E
b6B29:  inc     d6B1A
        bne     b6B31
        inc     d6B1B
b6B31:  tya
        clc
        adc     #$08
        tay
        cpy     #$18
        bcc     b6B17
        inx
        cpx     #$71
        bcc     b6AFA
        lda     #$08
        sta     d6D16
        jsr     s6CD3
        inc     $7C
        lda     $7C
        cmp     #$70
        bcs     b6B52
        jmp     s6AE0
b6B52:  ldx     #$54
        lda     #$0D
        sta     d6B78
        lda     #$78
        sta     d6B79
b6B5E:  ldy     #$1E
        lda     $1214,x
        clc
        adc     $15B0,y
        sta     $62
        lda     $12D4,x
        adc     $15D8,y
        adc     #$60
        sta     $63
        ldy     #$00
b6B75:  lda     ($62),y
d6B78           := * + 1
d6B79           := * + 2
        ora     d780D
        sta     ($62),y
        inc     d6B78
        bne     b6B84
        inc     d6B79
b6B84:  tya
        clc
        adc     #$08
        tay
        cpy     #$18
        bcc     b6B75
        inx
        cpx     #$5F
        bcc     b6B5E
        lda     #$FF
        sta     $83
b6B96:  lda     #$35
        sta     d6BC2
        lda     #$78
        sta     d6BC3
        ldx     $7E
b6BA2:  ldy     #$1E
        lda     $1268,x
        clc
        adc     $15B0,y
        sta     $60
        sta     $62
        lda     $1328,x
        adc     $15D8,y
        adc     #$20
        sta     $61
        adc     #$40
        sta     $63
        ldy     #$00
b6BBF:  lda     ($62),y
d6BC2           := * + 1
d6BC3           := * + 2
        ora     d7835
        sta     ($60),y
        inc     d6BC2
        bne     b6BCE
        inc     d6BC3
b6BCE:  tya
        clc
        adc     #$08
        tay
        cpy     #$18
        bcc     b6BBF
        inx
        cpx     #$1D
        bcc     b6BA2
        lda     #$10
        sta     d6D16
        jsr     s6CD3
        inc     $7E
        lda     $7E
        cmp     #$1D
        bcc     b6B96
        rts
s6BED:  ldx     #$60
b6BEF:  ldy     #$1E
        lda     $1214,x
        clc
        adc     $15B0,y
        sta     $60
        lda     $12D4,x
        adc     $15D8,y
        adc     #$20
        sta     $61
        ldy     #$00
b6C06:  lda     #$00
        sta     ($60),y
        tya
        clc
        adc     #$08
        tay
        cpy     #$18
        bne     b6C06
        dex
        bpl     b6BEF
        rts
s6C17:  lda     #$FE
        sta     $7F
        lda     #$7C
        sta     $80
        lda     #$00
        sta     $81
        lda     #$1E
        sta     VIC_SPR_BG_PRIO
b6C28:  lda     #$0A
        sta     d6D16
        jsr     s6CD3
        ldx     $81
        inx
        cpx     #$03
        bcc     b6C39
        ldx     #$00
b6C39:  stx     $81
        lda     d6CCB,x
        tax
        ldy     #$2F
b6C41:  lda     d7AA3,x
        sta     $6440,y
        lda     d7A0B,x
        sta     $6480,y
        dex
        dey
        bpl     b6C41
        lda     $80
        sta     VIC_SPR1_Y
        sta     VIC_SPR2_Y
        lda     $7F
        clc
        adc     #$40
        sta     VIC_SPR1_X
        lda     VIC_SPR_HI_X
        and     #$FD
        bcc     b6C6A
        ora     #$02
b6C6A:  sta     VIC_SPR_HI_X
        lda     $7F
        clc
        adc     #$44
        sta     VIC_SPR2_X
        lda     VIC_SPR_HI_X
        and     #$FB
        bcc     b6C7E
        ora     #$04
b6C7E:  sta     VIC_SPR_HI_X
        lda     $81
        bne     b6C91
        dec     $80
        lda     $7F
        cmp     #$48
        bcs     b6C91
        inc     $80
        inc     $80
b6C91:  lda     $7F
        cmp     #$10
        bne     b6C9C
        lda     #$18
        sta     VIC_SPR_BG_PRIO
b6C9C:  dec     $7F
        dec     $7F
        bne     b6C28
        ldx     #$2F
b6CA4:  lda     d7B6B,x
        sta     $6440,x
        lda     d7B3B,x
        sta     $6480,x
        dex
        bpl     b6CA4
        lda     #$40
        sta     VIC_SPR2_X
        lda     #$47
        sta     VIC_SPR1_X
        lda     #$6E
        sta     VIC_SPR1_Y
        sta     VIC_SPR2_Y
        lda     #$FF
        sta     $82
        rts
        rts
d6CCB:  .byte   $2F,$5F,$8F
s6CCE:  lda     #$F0
        sta     d6D16
s6CD3:  lda     VIC_CTRL1
        bpl     s6CD3
b6CD8:  lda     VIC_HLINE
        bne     b6CD8
        inc     $79
        jsr     s6D2B
        jsr     s6D7F
        jsr     s6D17
        jsr     s6DA9
        dec     d6D16
        bne     s6CD3
        beq     b6D08
s6CF2:  lda     VIC_CTRL1
        bpl     s6CF2
b6CF7:  lda     VIC_HLINE
        bne     b6CF7
        ldx     #$00
b6CFE:  pha
        pla
        inx
        bne     b6CFE
        dec     d6D16
        bne     s6CF2
b6D08:  jsr     KERNEL_SCNKEY
        jsr     KERNEL_GETIN
        cmp     #$00
        beq     b6D15
        jmp     j6803
b6D15:  rts
d6D16:  .byte   $40
s6D17:  lda     $82
        beq     b6D2A
        ldx     #$07
        lda     $79
        lsr     a
        lsr     a
        cmp     #$08
        bcc     b6D27
        ldx     #$06
b6D27:  stx     $6444
b6D2A:  rts
s6D2B:  lda     $79
        and     #$03
        beq     b6D32
        rts
b6D32:  inc     $7D
        lda     $7D
        cmp     #$09
        bcc     b6D3E
        lda     #$00
        sta     $7D
b6D3E:  tax
        inc     $7B
        lda     $7B
        and     #$07
        sta     $7B
        tay
        lda     d6D67,y
        tay
        lda     d6D6F,x
        sta     $6000,y
        lda     $79
        and     #$1F
        bne     b6D66
        lda     $51CD
        pha
        lda     $51CE
        sta     $51CD
        pla
        sta     $51CE
b6D66:  rts
d6D67:  .byte   $04,$0C,$20,$31,$48,$64,$68,$7E
d6D6F:  .byte   $10,$30,$10,$60,$30,$70,$00,$A0
        .byte   $10,$30,$00,$60,$30,$70,$10,$A0
s6D7F:  lda     $79
        and     #$3F
        bne     b6DA8
        inc     TXTPTR
        ldx     TXTPTR
        lda     d6F90,x
        bpl     b6D92
        lda     #$00
        sta     TXTPTR
b6D92:  asl     a
        tax
        lda     d764F,x
        sta     $60
        lda     d7650,x
        sta     $61
        ldy     #$29
b6DA0:  lda     ($60),y
        sta     $6400,y
        dey
        bpl     b6DA0
b6DA8:  rts
s6DA9:  lda     $83
        beq     b6DA8
        lda     d6A16
        and     #$03
        bne     b6DA8
        lda     $79
        and     #$07
        bne     b6DA8
        lda     $84
        and     #$01
        clc
        adc     #$93
        sta     $63FD
        lda     $84
        clc
        adc     #$20
        sta     VIC_SPR5_X
        bcc     b6DD6
        lda     VIC_SPR_HI_X
        ora     #$20
        sta     VIC_SPR_HI_X
b6DD6:  inc     $84
        lda     $84
        cmp     #$48
        bcc     b6DE4
        lda     $85
        bpl     b6DE4
        dec     $84
b6DE4:  lda     $85
        bpl     b6E0F
        lda     $84
        cmp     #$10
        bcc     b6E0F
        cmp     #$1A
        bcc     b6E03
        cmp     #$30
        bcc     b6E0F
        cmp     #$3A
        bcs     b6E0F
        jsr     s6E10
        ora     #$40
        sta     ($60),y
        bne     b6E0F
b6E03:  lda     #$19
        sec
        sbc     $84
        jsr     s6E10
        and     #$BF
        sta     ($60),y
b6E0F:  rts
s6E10:  and     #$0F
        asl     a
        tax
        lda     d6E23,x
        sta     $60
        lda     d6E24,x
        sta     $61
        ldy     #$00
        lda     ($60),y
        rts
d6E23:  .byte   $FA
d6E24:  .byte   $52,$FB,$52,$FC,$52,$FD,$52,$FE
        .byte   $52,$FF,$52,$38,$54,$39,$54,$3A
        .byte   $54,$3B,$54
s6E37:  asl     a
        tax
        lda     #$0B
        sta     $32
        lda     #$07
        sta     $33
        lda     d6E6C,x
        sta     d6E4E
        lda     d6E6D,x
        sta     d6E4F
b6E4D:
d6E4E           := * + 1
d6E4F           := * + 2
        lda     d6E72
        bne     b6E53
        rts
b6E53:  bpl     b6E5D
        lda     #$0B
        sta     $32
        inc     $33
        bne     b6E62
b6E5D:  jsr     s6F17
        inc     $32
b6E62:  inc     d6E4E
        bne     b6E4D
        inc     d6E4F
        bne     b6E4D
d6E6C:  .byte   $72
d6E6D:  .byte   $6E,$8A,$6E,$E2,$6E
d6E72:  .byte   $FF,$FF,$FF,$20,$20,$20,$20,$20
        .byte   $20,$20,$20,$20,$70,$72,$65,$73
        .byte   $65,$6E,$74,$73,$2E,$2E,$2E,$00
d6E8A:  .byte   $2E,$2E,$2E,$61,$20,$6E,$65,$77
        .byte   $20,$72,$65,$6C,$65,$61,$73,$65
        .byte   $20,$6F,$66,$20,$74,$68,$65,$20
        .byte   $62,$65,$73,$74,$2D,$FF,$20,$20
        .byte   $20,$73,$65,$6C,$6C,$69,$6E,$67
        .byte   $20,$70,$65,$72,$73,$6F,$6E,$61
        .byte   $6C,$20,$63,$6F,$6D,$70,$75,$74
        .byte   $65,$72,$FF,$20,$20,$20,$72,$6F
        .byte   $6C,$65,$2D,$70,$6C,$61,$79,$69
        .byte   $6E,$67,$20,$61,$64,$76,$65,$6E
        .byte   $74,$75,$72,$65,$2E,$2E,$2E,$00
d6EE2:  .byte   $2E,$2E,$2E,$4C,$6F,$72,$64,$20
        .byte   $42,$72,$69,$74,$69,$73,$68,$27
        .byte   $73,$20,$6F,$72,$69,$67,$69,$6E
        .byte   $61,$6C,$FF,$20,$20,$20,$66,$61
        .byte   $6E,$74,$61,$73,$79,$20,$6D,$61
        .byte   $73,$74,$65,$72,$70,$69,$65,$63
        .byte   $65,$2E,$2E,$2E,$00
s6F17:  sta     $5E
        lda     $33
        asl     a
        asl     a
        asl     a
        tax
        ldy     $32
        lda     $1200,x
        clc
        adc     $15B0,y
        sta     d6F51
        lda     $12C0,x
        adc     $15D8,y
        adc     #$20
        sta     d6F52
        lda     $5E
        asl     a
        asl     a
        asl     a
        sta     d6F4E
        lda     $5E
        lsr     a
        lsr     a
        lsr     a
        lsr     a
        lsr     a
        clc
        adc     #$08
        sta     d6F4F
        ldx     #$07
b6F4D:
d6F4E           := * + 1
d6F4F           := * + 2
        lda     $0800,x
d6F51           := * + 1
d6F52           := * + 2
        sta     $2000,x
        dex
        bpl     b6F4D
        rts
s6F57:  lda     #$06
        asl     a
        asl     a
        asl     a
        tax
        ldy     #$0B
        lda     $1200,x
        clc
        adc     $15B0,y
        sta     $60
        lda     $12C0,x
        adc     $15D8,y
        adc     #$20
        sta     $61
        ldx     #$07
b6F74:  ldy     #$E7
        lda     #$00
b6F78:  sta     ($60),y
        dey
        cpy     #$FF
        bne     b6F78
        lda     $60
        clc
        adc     #$40
        sta     $60
        lda     $61
        adc     #$01
        sta     $61
        dex
        bne     b6F74
        rts
d6F90:  .byte   $00,$01,$00,$01,$02,$01,$00,$01
        .byte   $02,$03,$04,$03,$04,$03,$02,$01
        .byte   $00,$05,$06,$05,$06,$05,$06,$FF
d6FA8:  .byte   $00,$3F,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $FF,$FF,$FF,$FF,$C0,$00,$7F,$FF
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $FF,$C0,$00,$E0,$00,$00,$38,$00
        .byte   $00,$00,$00,$00,$00,$00,$C0,$00
        .byte   $C0,$06,$00,$30,$00,$00,$00,$00
        .byte   $00,$00,$00,$C0,$01,$80,$1E,$00
        .byte   $30,$78,$1F,$03,$0F,$06,$30,$31
        .byte   $80,$01,$80,$0C,$00,$60,$FC,$3F
        .byte   $86,$3F,$86,$30,$31,$80,$03,$00
        .byte   $18,$00,$61,$86,$31,$86,$31,$8C
        .byte   $70,$63,$00,$03,$00,$18,$00,$C3
        .byte   $0C,$63,$0C,$60,$0C,$78,$63,$00
        .byte   $06,$10,$30,$20,$C3,$0C,$6E,$0C
        .byte   $60,$18,$D8,$C6,$00,$06,$3F,$FF
        .byte   $F1,$86,$18,$DC,$18,$CE,$18,$CC
        .byte   $C6,$00,$0C,$7F,$FF,$F1,$86,$18
        .byte   $C6,$18,$DE,$31,$8D,$8C,$00,$0C
        .byte   $20,$60,$43,$0C,$31,$86,$31,$86
        .byte   $31,$87,$8C,$00,$18,$00,$C0,$03
        .byte   $0C,$31,$86,$31,$8C,$63,$07,$18
        .byte   $00,$18,$00,$C0,$06,$0F,$E3,$0C
        .byte   $63,$FC,$63,$03,$18,$00,$30,$01
        .byte   $80,$06,$07,$C3,$0C,$61,$F0,$C6
        .byte   $06,$30,$00,$30,$01,$80,$0C,$00
        .byte   $00,$00,$00,$00,$00,$00,$30,$00
        .byte   $60,$07,$80,$0C,$7F,$FF,$FF,$FF
        .byte   $FF,$FF,$FE,$60,$00,$60,$03,$00
        .byte   $18,$FF,$FF,$FF,$FF,$FF,$FF,$FC
        .byte   $60,$00,$E0,$00,$00,$38,$00,$00
        .byte   $00,$00,$00,$00,$00,$C0,$00,$FF
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $FF,$FF,$C0,$00,$7F,$FF,$FF,$FF
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$80
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$0C,$0F,$07
        .byte   $00,$00,$00,$00,$00,$03,$0F,$FE
        .byte   $00,$00,$00,$00,$00,$06,$07,$03
        .byte   $00,$00,$00,$00,$00,$06,$9E,$FC
        .byte   $00,$00,$00,$00,$00,$00,$01,$03
        .byte   $00,$00,$00,$00,$00,$C0,$C0,$C0
        .byte   $00,$00,$00,$00,$00,$00,$00,$01
        .byte   $00,$00,$00,$00,$00,$00,$00,$80
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$03
        .byte   $00,$00,$00,$00,$00,$00,$00,$E0
        .byte   $00,$00,$00,$00,$00,$00,$01,$03
        .byte   $00,$00,$00,$00,$0F,$7F,$FF,$FF
        .byte   $00,$00,$00,$00,$F8,$FF,$FF,$FF
        .byte   $00,$00,$00,$01,$0F,$FF,$FF,$FF
        .byte   $00,$30,$70,$E0,$E0,$C0,$80,$00
        .byte   $07,$03,$01,$01,$01,$01,$01,$01
        .byte   $FE,$FC,$F8,$F8,$F8,$F8,$F8,$F8
        .byte   $03,$01,$00,$00,$00,$00,$00,$00
        .byte   $FC,$F8,$F0,$F0,$F0,$F0,$F0,$F0
        .byte   $0F,$3F,$0F,$0F,$0F,$0F,$0F,$0F
        .byte   $C0,$C0,$C0,$C0,$C0,$C0,$C1,$C1
        .byte   $01,$03,$03,$07,$0F,$7F,$FF,$FF
        .byte   $80,$80,$80,$80,$80,$FC,$FC,$FC
        .byte   $00,$01,$03,$03,$01,$00,$00,$00
        .byte   $00,$80,$C0,$C0,$80,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$80
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $06,$0D,$0D,$0D,$0D,$06,$03,$00
        .byte   $30,$D8,$58,$98,$58,$30,$E0,$00
        .byte   $07,$07,$0F,$1C,$18,$00,$00,$00
        .byte   $FE,$E0,$00,$00,$00,$00,$00,$00
        .byte   $00,$FF,$7E,$7E,$7E,$7E,$7E,$7E
        .byte   $7C,$60,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $01,$01,$01,$01,$01,$01,$01,$01
        .byte   $F8,$F8,$F8,$F8,$F8,$F8,$F8,$F8
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0
        .byte   $0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F
        .byte   $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0
        .byte   $1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F
        .byte   $80,$80,$80,$80,$80,$80,$80,$80
        .byte   $00,$01,$03,$0F,$3F,$07,$07,$07
        .byte   $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0
        .byte   $01,$03,$0F,$1F,$3F,$1F,$1F,$1F
        .byte   $9F,$FF,$FF,$FF,$FF,$C1,$C1,$80
        .byte   $87,$CF,$FF,$FF,$FF,$FE,$FE,$FC
        .byte   $F8,$FE,$FF,$FF,$FF,$0F,$0F,$07
        .byte   $01,$01,$01,$80,$C0,$C0,$E0,$E0
        .byte   $C7,$FF,$FF,$F0,$70,$38,$00,$00
        .byte   $F8,$FE,$FF,$7F,$3F,$3F,$3F,$1F
        .byte   $00,$00,$00,$00,$00,$00,$00,$80
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $01,$01,$01,$01,$01,$01,$01,$00
        .byte   $F8,$F8,$F8,$FC,$FC,$FE,$FF,$FF
        .byte   $00,$00,$00,$01,$01,$03,$07,$FF
        .byte   $F8,$FC,$FC,$FC,$FC,$FC,$FC,$F8
        .byte   $0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F
        .byte   $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0
        .byte   $1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F
        .byte   $80,$80,$80,$80,$80,$80,$82,$86
        .byte   $07,$07,$07,$07,$07,$07,$07,$07
        .byte   $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0
        .byte   $1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F
        .byte   $80,$80,$80,$80,$80,$80,$80,$80
        .byte   $FC,$FC,$FC,$FC,$FC,$FC,$FC,$FC
        .byte   $07,$07,$07,$07,$07,$07,$07,$07
        .byte   $E0,$E0,$E0,$E0,$E0,$E1,$E1,$E1
        .byte   $1E,$7F,$FF,$F1,$F0,$F0,$F0,$F0
        .byte   $1F,$1F,$9F,$9F,$1F,$1F,$1F,$3F
        .byte   $80,$80,$80,$80,$80,$80,$C0,$C0
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $FF,$7F,$1F,$03,$00,$00,$00,$00
        .byte   $FF,$FF,$FF,$FE,$00,$00,$00,$00
        .byte   $F8,$F0,$C0,$00,$00,$00,$00,$00
        .byte   $0F,$0F,$1F,$3F,$00,$00,$00,$00
        .byte   $C0,$C0,$E0,$F0,$00,$00,$00,$00
        .byte   $0F,$0F,$07,$03,$00,$00,$00,$00
        .byte   $CE,$FC,$F8,$F0,$00,$00,$00,$00
        .byte   $07,$07,$07,$1F,$00,$00,$00,$00
        .byte   $C0,$C0,$C0,$F0,$00,$00,$00,$00
        .byte   $1F,$1F,$1F,$7F,$00,$00,$00,$00
        .byte   $80,$80,$80,$E3,$00,$00,$00,$00
        .byte   $FC,$FC,$FC,$FF,$00,$00,$00,$00
        .byte   $07,$07,$07,$0F,$0F,$0F,$1F,$1E
        .byte   $C0,$C0,$C0,$80,$80,$00,$00,$00
        .byte   $F8,$FF,$FF,$7F,$00,$00,$00,$00
        .byte   $7F,$EF,$CF,$87,$00,$00,$00,$00
        .byte   $C0,$C0,$E0,$F0,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$01,$03,$07
        .byte   $00,$00,$00,$0E,$7E,$FF,$FF,$FF
        .byte   $7E,$7E,$7E,$FF,$00,$FF,$FF,$FF
        .byte   $00,$00,$01,$0F,$7F,$FF,$FF,$FC
        .byte   $30,$70,$E0,$E0,$C0,$80,$00,$00
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
        .byte   $3C,$78,$60,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $07,$0F,$1C,$00,$00,$00,$00,$00
        .byte   $E0,$00,$00,$00,$00,$00,$00,$00
        .byte   $3F,$00,$00,$00,$00,$00,$00,$00
        .byte   $E0,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $C6,$C6,$C6,$B1,$8D,$A0,$C8,$C5
d7518:  .byte   $E0,$C0,$00,$7C,$70,$00,$FF,$FC
        .byte   $00,$FF,$FF,$00,$6F,$ED,$80,$18
        .byte   $00,$00,$7C,$00,$00,$7E,$00,$00
        .byte   $0E,$00,$00,$0F,$00,$00,$0F,$C0
        .byte   $00,$3F,$E0,$00,$6F,$F0,$00,$6D
        .byte   $F8,$00,$18,$F8,$00,$18,$DC,$00
        .byte   $00,$6C,$00,$00,$6C,$00,$00,$D8
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$18,$00,$00,$7C,$00,$00
        .byte   $7E,$00,$00,$0F,$F8,$00,$0F,$FC
        .byte   $00,$1F,$FC,$00,$7F,$F8,$00,$CC
d7570:  .byte   $DC,$00,$CC,$6C
d7574:  .byte   $00,$0C,$6C,$00,$18,$D8,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $30,$00,$00,$78,$00,$00,$FC,$00
        .byte   $00,$5F,$F8,$00,$0F,$FC,$00,$1F
        .byte   $FC,$00,$7F,$F8,$00,$CC,$DC,$00
        .byte   $CC,$6C,$00,$0C,$6C,$00,$18,$D8
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$30,$00,$00,$78,$00,$00
        .byte   $FC,$00,$00,$5F,$F8,$00,$0F,$FC
        .byte   $00,$1F,$FC,$00,$3F,$F8,$00,$6C
        .byte   $DC,$00,$CC,$6C,$00,$CC,$6C,$00
        .byte   $18,$D8,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$0F,$F8,$00
        .byte   $3F,$FC,$00,$7F,$FC,$00,$EF,$F8
        .byte   $00,$EC,$DC,$00,$EC,$6C,$00,$CC
        .byte   $6C,$00,$18,$D8,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$07
        .byte   $FC,$00,$1F,$FE,$00,$3F,$FE,$00
        .byte   $67,$FC,$00,$76,$6E,$00,$76,$36
        .byte   $00,$36,$36,$00,$0C,$6C,$00,$18
        .byte   $00,$00,$3C,$00,$00,$7E,$00,$00
        .byte   $2E,$00,$00,$0F,$00,$00,$0F,$C0
        .byte   $00,$7F,$E0,$00,$6F,$F0,$00,$0D
        .byte   $F8,$00,$0C,$F8,$00,$18,$DC,$00
        .byte   $00,$6C,$00,$00,$6C,$00,$00,$D8
        .byte   $00,$B0,$B0
d764F:  .byte   $27
d7650:  .byte   $75,$51,$75,$7B,$75,$A5,$75,$CF
        .byte   $75,$F9,$75,$23,$76
d765D:  .byte   $1B,$00,$00,$0F,$00,$00,$03,$00
        .byte   $00,$03,$00,$00,$1B,$00,$00,$1B
        .byte   $00,$00,$3E,$C0,$00,$39,$E0,$00
        .byte   $3B,$40,$00,$EB,$00,$00,$7F,$80
        .byte   $00,$A2,$80,$00,$24,$80,$00
d7684:  .byte   $01,$80,$00,$07,$80,$00,$0D,$80
        .byte   $00,$01,$80,$00,$0D,$80,$00,$0D
        .byte   $80,$00,$1F,$60,$00,$1C,$F0,$00
        .byte   $1D,$A0,$00,$75,$80,$00,$BF,$C0
        .byte   $00,$49,$20,$00,$51,$40,$00,$00
        .byte   $00,$00,$18,$D8,$00,$00,$00,$00
        .byte   $00
d76B5:  .byte   $00,$04,$00,$00,$0C,$00,$00,$1C
        .byte   $00,$00,$1C,$00,$00,$3C,$00,$00
        .byte   $3C,$00,$00,$3C,$00,$00,$7C,$00
        .byte   $00,$74,$00,$00,$74,$00,$00,$74
        .byte   $00,$00,$74,$00,$00,$74,$00,$00
        .byte   $74,$00,$00,$74,$00,$00,$74,$00
        .byte   $00,$74,$00,$00,$74,$00,$00,$74
        .byte   $00,$00,$74,$00,$00,$74,$00,$00
        .byte   $74,$00,$00,$74,$00,$00,$74,$00
        .byte   $00,$74,$00,$00,$74,$00,$00,$74
        .byte   $00,$00,$74,$00,$00,$74,$00,$00
        .byte   $74,$00,$00,$74,$00,$00,$74,$00
        .byte   $00,$74,$00,$00,$74,$00,$00,$74
        .byte   $00,$00,$74,$00,$00,$74,$00,$00
        .byte   $74,$00,$00,$74,$00,$00,$74,$00
        .byte   $00,$74,$00,$00,$74,$00,$00,$74
        .byte   $00,$00,$74,$00,$00,$74,$00,$00
        .byte   $74,$00,$00,$74,$00,$00,$74,$00
        .byte   $00,$74,$00,$00,$74,$00,$00,$74
        .byte   $00,$00,$74,$00,$00,$74,$00,$00
        .byte   $74,$00,$00,$74,$00,$00,$74,$00
        .byte   $00,$74,$00,$00,$74,$00,$00,$74
d7765:  .byte   $00,$00,$74,$00,$00,$74,$00,$00
        .byte   $74,$00,$00,$74,$00,$00,$74,$00
        .byte   $00,$74,$00,$00,$74,$00,$00,$74
        .byte   $00,$00,$74,$00,$00,$74,$00,$00
        .byte   $74,$00,$00,$74,$00,$00,$74,$00
        .byte   $00,$74,$00,$00,$74,$00,$00,$74
        .byte   $00,$00,$74,$00,$07,$FF,$C0,$0F
        .byte   $D7,$E0,$19,$93,$30,$1B,$FF,$B0
        .byte   $1F,$39,$F0,$0F,$BB,$E0,$00,$7C
        .byte   $00,$00,$10,$00,$00,$E8,$00,$00
        .byte   $D8,$00,$01,$B0,$00,$01,$1C,$00
        .byte   $01,$AE,$00,$01,$3E,$00,$00,$7F
        .byte   $00,$00,$7F,$00,$00,$7B,$00,$00
        .byte   $37,$00,$00,$0F,$00,$00,$0F,$80
        .byte   $00,$0F,$80,$00,$0F,$80,$00,$0F
        .byte   $80,$00,$0F,$80,$00,$0F,$80,$00
        .byte   $1F,$80,$00,$1F,$80,$00,$1F,$80
        .byte   $00,$1F,$80,$00,$1F,$80,$00,$1F
        .byte   $80,$00,$1F,$80,$00,$1F,$80,$00
        .byte   $1F,$80,$00,$1F,$80,$00,$1F,$80
        .byte   $00,$1F,$80,$00,$00,$00,$00,$00
d780D:  .byte   $00,$7C,$00,$00,$10,$00,$00,$28
        .byte   $00,$00,$18,$00,$00,$30,$00,$00
        .byte   $18,$00,$00,$38,$00,$00,$7C,$00
        .byte   $00,$7C,$00,$00,$7C,$00,$00,$38
        .byte   $00,$00,$0F,$00,$00,$0F,$00,$00
d7835:  .byte   $00,$00,$00,$01,$20,$00,$03,$F0
        .byte   $00,$03,$F8,$00,$01,$F9,$80,$03
        .byte   $FF,$80,$01,$FF,$00,$00,$FE,$00
        .byte   $00,$7E,$00,$00,$3E,$00,$00,$1F
        .byte   $00,$00,$1F,$00,$00,$0F,$00,$00
        .byte   $0F,$00,$00,$0F,$00,$00,$0F,$80
        .byte   $00,$0F,$80,$00,$0F,$80,$00,$0F
        .byte   $80,$00,$0F,$80,$00,$1F,$80,$00
        .byte   $1F,$80,$00,$1F,$80,$00,$1F,$80
        .byte   $00,$1F,$80,$00,$1F,$80,$00,$1F
        .byte   $80,$00,$1F,$80,$00,$1F,$80,$00
        .byte   $1F,$80,$00,$1F,$80,$00,$1F,$80
        .byte   $00,$1F,$80,$78,$00,$00,$FC,$00
        .byte   $00,$5F,$F8
d78A0:  .byte   $FF,$F9,$FF,$FF,$F1,$FF,$FF,$E1
        .byte   $FF,$FF,$C1,$FF,$FF,$C1,$FF,$FF
        .byte   $81,$FF,$FF,$81,$FF,$FF,$81,$FF
        .byte   $FF,$81,$FF,$FF,$81,$FF,$FF,$81
        .byte   $FF,$FF,$81,$FF,$FF,$81,$FF,$FF
        .byte   $81,$FF,$FF,$81,$FF,$FF,$81,$FF
        .byte   $FF,$81,$FF,$FF,$81,$FF,$FF,$81
        .byte   $FF,$FF,$81,$FF,$FF,$81,$FF,$FF
        .byte   $81,$FF,$FF,$81,$FF,$FF,$81,$FF
        .byte   $FF,$81,$FF,$FF,$81,$FF,$FF,$81
        .byte   $FF,$FF,$81,$FF,$FF,$81,$FF,$FF
        .byte   $81,$FF,$FF,$81,$FF,$FF,$81,$FF
        .byte   $FF,$81,$FF,$FF,$81,$FF,$FF,$81
        .byte   $FF,$FF,$81,$FF,$FF,$81,$FF,$FF
        .byte   $81,$FF,$FF,$81,$FF,$FF,$81,$FF
        .byte   $FF,$81,$FF,$FF,$81,$FF,$FF,$81
        .byte   $FF,$FF,$81,$FF,$FF,$81,$FF,$FF
        .byte   $81,$FF,$FF,$81,$FF,$FF,$81,$FF
        .byte   $FF,$81,$FF,$FF,$81,$FF,$FF,$81
        .byte   $FF,$FF,$81,$FF,$FF,$81,$FF,$FF
        .byte   $81,$FF,$FF,$81,$FF,$FF,$81,$FF
        .byte   $FF,$81,$FF,$FF,$81,$FF,$FF,$81
        .byte   $FF,$FF,$81,$FF,$FF,$81,$FF,$FF
        .byte   $81,$FF,$FF,$81,$FF,$FF,$81,$FF
        .byte   $FF,$81,$FF,$FF,$81,$FF,$FF,$81
        .byte   $FF,$FF,$81,$FF,$FF,$81,$FF,$FF
        .byte   $81,$FF,$FF,$81,$FF,$FF,$81,$FF
        .byte   $FF,$81,$FF,$FF,$81,$FF,$FF,$81
        .byte   $FF,$FF,$81,$FF,$FF,$81,$FF,$F8
        .byte   $00,$3F,$F0,$00,$1F,$E0,$00,$0F
        .byte   $E0,$00,$0F,$E0,$00,$0F,$F0,$00
        .byte   $1F,$FF,$83,$FF,$FF,$EF,$FF,$FF
        .byte   $07,$FF,$FF,$07,$FF,$FE,$0F,$FF
        .byte   $FE,$03,$FF,$FE,$01,$FF,$FE,$01
        .byte   $FF,$FF,$80,$FF,$FF,$E0,$FF,$FF
        .byte   $F0,$FF,$FF,$F0,$FF,$FF,$F0,$FF
        .byte   $FF,$F0,$7F,$FF,$F0,$7F,$FF,$F0
        .byte   $7F,$FF,$F0,$7F,$FF,$F0,$7F,$FF
        .byte   $F0,$7F,$FF,$E0,$7F,$FF,$E0,$7F
        .byte   $FF,$E0,$7F,$FF,$E0,$7F,$FF,$E0
        .byte   $7F,$FF,$E0,$7F,$FF,$E0,$7F,$FF
        .byte   $E0,$7F,$FF,$E0,$7F,$FF,$E0,$7F
        .byte   $FF,$E0,$7F,$FF,$E0,$7F,$FF,$E0
        .byte   $7F,$FF,$F0,$3F,$FF,$F0,$3F,$FF
        .byte   $F0,$3F,$FF,$F0,$3F,$FF,$F0,$3F
        .byte   $FF,$FF,$FF
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

compressed_image:
        .byte   $00,$0C,$03,$07,$0F,$0F,$00,$03
        .byte   $FC,$FE,$F0,$E0,$C0,$00,$08,$02
        .byte   $07,$02,$00,$40,$02,$07,$02,$00
        .byte   $E2,$1F,$1F,$1F,$1E,$1E,$0E,$0E
        .byte   $06,$80,$00,$37,$40,$E0,$40,$00
        .byte   $B5,$08,$1C,$08,$00,$45,$03,$00
        .byte   $9C,$08,$1C,$08,$00,$18,$02,$07
        .byte   $02,$00,$AD,$08,$1C,$08,$00,$00
        .byte   $00,$12,$C4,$B5,$E7,$00,$06,$70
        .byte   $ED,$00,$00,$00,$30,$F7,$9C,$9F
        .byte   $CF,$FF,$05,$7F,$ED,$FC,$7F,$FF
        .byte   $03,$D0,$FF,$02,$BF,$FF,$02,$FC
        .byte   $FD,$00,$01,$60,$F4,$FF,$03,$1F
        .byte   $FC,$00,$02,$40,$00,$01,$D0,$EC
        .byte   $7D,$D7,$00,$07,$40,$00,$00,$00
        .byte   $10,$FF,$01,$FC,$FF,$01,$BF,$9C
        .byte   $FF,$01,$F1,$CF,$FF,$01,$77,$E7
        .byte   $CF,$1F,$FF,$01,$FE,$F0,$FE,$FF
        .byte   $01,$1F,$FF,$02,$FD,$F9,$F5,$1D
        .byte   $F7,$1F,$F7,$FD,$F4,$DB,$A8,$B8
        .byte   $5A,$A5,$7E,$75,$D8,$10,$01,$00
        .byte   $01,$D0,$E0,$40,$40,$00,$00,$00
        .byte   $14,$B1,$CE,$BF,$EF,$F9,$E6,$01
        .byte   $B1,$CE,$FF,$01,$7E,$FD,$D6,$BD
        .byte   $6E,$99,$44,$77,$E4,$3B,$C4,$90
        .byte   $00,$03,$50,$01,$40,$00,$14,$0E
        .byte   $FC,$00,$06,$70,$F8,$00,$00,$00
        .byte   $08,$FF,$03,$FC,$FC,$FC,$FC,$FE
        .byte   $90,$40,$00,$0C,$03,$7F,$01,$07
        .byte   $1F,$7F,$7F,$27,$7F,$4F,$DF,$FF
        .byte   $01,$FE,$F0,$C7,$CF,$FC,$F4,$F1
        .byte   $C3,$1F,$7D,$D0,$C0,$00,$02,$DF
        .byte   $C3,$FD,$50,$01,$00,$05,$80,$50
        .byte   $01,$00,$00,$00,$05,$FF,$08,$1F
        .byte   $FF,$02,$FC,$F0,$C0,$80,$00,$01
        .byte   $FF,$01,$FC,$F0,$00,$05,$31,$40
        .byte   $00,$03,$1F,$7F,$BF,$00,$06,$FC
        .byte   $F1,$00,$00,$00,$18,$FF,$01,$FE
        .byte   $FC,$FC,$FC,$FC,$FC,$FC,$00,$01
        .byte   $01,$02,$06,$03,$06,$01,$00,$01
        .byte   $7F,$FF,$03,$1F,$E4,$39,$16,$01
        .byte   $D7,$C0,$8D,$3F,$3F,$66,$B9,$44
        .byte   $C7,$1F,$7F,$FF,$01,$BD,$EA,$11
        .byte   $40,$A0,$54,$F2,$EE,$11,$44,$00
        .byte   $04,$90,$44,$00,$00,$00,$0C,$FC
        .byte   $FC,$FE,$FE,$FE,$FE,$FF,$02,$00
        .byte   $02,$03,$0F,$1F,$7F,$FF,$01,$FC
        .byte   $1F,$7C,$F0,$C0,$80,$00,$00,$00
        .byte   $2B,$FF,$08,$F8,$F0,$F0,$E0,$E0
        .byte   $C0,$C0,$C0,$00,$00,$00,$30,$FF
        .byte   $08,$80,$80,$00,$38,$0C,$1E,$3F
        .byte   $7F,$33,$33,$00,$05,$80,$00,$04
        .byte   $0C,$1E,$3F,$7F,$33,$33,$00,$05
        .byte   $80,$00,$E2,$FF,$08,$00,$03,$01
        .byte   $00,$02,$01,$00,$05,$10,$01,$01
        .byte   $04,$40,$00,$06,$44,$01,$00,$04
        .byte   $04,$40,$00,$01,$04,$00,$03,$10
        .byte   $01,$41,$04,$40,$00,$06,$11,$40
        .byte   $04,$00,$04,$18,$3D,$7E,$FF,$01
        .byte   $3F,$3F,$1E,$5E,$DE,$DE,$DE,$5E
        .byte   $6D,$6D,$FF,$01,$C7,$D3,$D6,$DD
        .byte   $D1,$BF,$BF,$DE,$DE,$DE,$DE,$DE
        .byte   $DE,$00,$03,$80,$C6,$EF,$DF,$BF
        .byte   $00,$05,$11,$80,$C4,$00,$03,$01
        .byte   $44,$10,$01,$01,$40,$00,$02,$10
        .byte   $01,$01,$40,$00,$01,$04,$00,$03
        .byte   $04,$11,$00,$01,$40,$04,$40,$00
        .byte   $02,$40,$00,$01,$10,$01,$01,$04
        .byte   $40,$00,$06,$40,$04,$00,$07,$44
        .byte   $00,$A8,$FF,$08,$00,$01,$10,$01
        .byte   $01,$00,$01,$01,$00,$02,$04,$00
        .byte   $02,$11,$04,$00,$02,$01,$00,$02
        .byte   $11,$04,$00,$02,$10,$01,$00,$01
        .byte   $40,$01,$00,$02,$41,$04,$10,$01
        .byte   $00,$02,$04,$00,$01,$01,$10,$01
        .byte   $40,$00,$04,$01,$10,$01,$44,$00
        .byte   $02,$10,$01,$04,$66,$66,$7E,$7E
        .byte   $7D,$7D,$7D,$7D,$D8,$03,$DB,$DB
        .byte   $FD,$FD,$DD,$8D,$10,$01,$6D,$6D
        .byte   $FF,$04,$F3,$06,$B0,$B6,$F6,$EF
        .byte   $EF,$EE,$EC,$D9,$19,$DF,$DF,$EF
        .byte   $EF,$EF,$6F,$80,$81,$80,$90,$81
        .byte   $80,$84,$80,$00,$01,$11,$00,$01
        .byte   $40,$00,$01,$01,$10,$01,$04,$10
        .byte   $02,$40,$04,$00,$01,$01,$00,$02
        .byte   $10,$01,$00,$02,$11,$44,$00,$05
        .byte   $11,$04,$00,$02,$01,$00,$02,$11
        .byte   $04,$00,$02,$10,$01,$00,$01,$40
        .byte   $11,$00,$02,$41,$04,$10,$01,$00
        .byte   $03,$40,$05,$10,$01,$40,$01,$00
        .byte   $01,$40,$00,$02,$10,$01,$41,$04
        .byte   $00,$01,$04,$01,$00,$04,$11,$00
        .byte   $01,$44,$00,$06,$11,$44,$00,$06
        .byte   $11,$40,$01,$00,$06,$10,$01,$41
        .byte   $00,$07,$3F,$00,$06,$7F,$FF,$01
        .byte   $00,$06,$FF,$02,$00,$06,$F8,$FF
        .byte   $01,$00,$07,$FF,$01,$00,$27,$7F
        .byte   $00,$06,$0F,$FF,$01,$00,$06,$FF
        .byte   $02,$00,$05,$07,$FF,$02,$00,$05
        .byte   $FF,$03,$00,$05,$FF,$0B,$00,$01
        .byte   $01,$00,$03,$04,$00,$02,$40,$00
        .byte   $01,$10,$01,$01,$04,$00,$02,$40
        .byte   $00,$02,$44,$10,$01,$00,$03,$11
        .byte   $00,$01,$44,$10,$01,$00,$02,$04
        .byte   $01,$00,$01,$44,$10,$01,$01,$00
        .byte   $01,$41,$00,$05,$10,$01,$00,$01
        .byte   $02,$00,$02,$04,$7D,$7D,$7D,$7D
        .byte   $00,$04,$DD,$FD,$FD,$FD,$00,$04
        .byte   $E1,$E1,$E1,$E1,$3E,$3E,$3E,$3E
        .byte   $EE,$EF,$EF,$EF,$00,$04,$EF,$EF
        .byte   $EF,$EF,$00,$04,$81,$84,$80,$A0
        .byte   $08,$20,$00,$03,$40,$04,$01,$00
        .byte   $02,$44,$11,$00,$01,$04,$41,$00
        .byte   $04,$10,$01,$04,$41,$00,$02,$04
        .byte   $40,$10,$01,$00,$01,$40,$00,$01
        .byte   $10,$01,$01,$04,$00,$05,$44,$10
        .byte   $01,$00,$01,$04,$01,$00,$02,$44
        .byte   $10,$01,$01,$00,$01,$40,$00,$01
        .byte   $01,$04,$01,$00,$01,$10,$01,$40
        .byte   $12,$00,$05,$01,$0F,$3F,$7F,$FF
        .byte   $01,$00,$01,$0F,$3F,$FF,$05,$00
        .byte   $0F,$3F,$00,$07,$F8,$00,$07,$03
        .byte   $00,$05,$03,$7F,$FE,$00,$04,$7F
        .byte   $FB,$E0,$00,$05,$C0,$F0,$FF,$01
        .byte   $0F,$00,$06,$C0,$FF,$01,$00,$2F
        .byte   $01,$00,$06,$03,$F0,$00,$05,$3F
        .byte   $FC,$00,$06,$FE,$00,$0A,$FF,$08
        .byte   $00,$01,$11,$00,$03,$11,$00,$02
        .byte   $11,$04,$00,$02,$01,$00,$01,$40
        .byte   $00,$01,$04,$00,$03,$10,$01,$40
        .byte   $00,$03,$41,$04,$10,$01,$00,$03
        .byte   $44,$01,$10,$01,$40,$00,$03,$44
        .byte   $10,$02,$40,$00,$01,$01,$10,$01
        .byte   $04,$00,$02,$40,$04,$00,$01,$01
        .byte   $00,$03,$04,$00,$01,$11,$44,$00
        .byte   $03,$04,$41,$00,$04,$01,$00,$01
        .byte   $40,$00,$01,$04,$00,$02,$10,$01
        .byte   $00,$01,$40,$00,$03,$40,$04,$10
        .byte   $01,$00,$03,$44,$00,$01,$11,$04
        .byte   $00,$03,$44,$10,$01,$00,$03,$01
        .byte   $10,$01,$04,$00,$02,$40,$04,$00
        .byte   $01,$01,$00,$03,$04,$00,$01,$11
        .byte   $44,$00,$02,$01,$00,$01,$40,$11
        .byte   $04,$00,$02,$10,$01,$04,$20,$00
        .byte   $05,$03,$0F,$3F,$FF,$01,$00,$02
        .byte   $03,$3F,$FF,$04,$03,$FF,$07,$00
        .byte   $0C,$1F,$00,$04,$03,$78,$00,$01
        .byte   $80,$00,$04,$E0,$00,$06,$07,$00
        .byte   $07,$FE,$00,$1F,$07,$00,$07,$FF
        .byte   $01,$07,$00,$06,$80,$FC,$00,$17
        .byte   $0F,$00,$06,$1F,$E0,$00,$06,$C0
        .byte   $00,$1F,$FF,$08,$00,$01,$04,$00
        .byte   $03,$10,$01,$00,$01,$01,$10,$01
        .byte   $01,$04,$00,$01,$40,$00,$01,$11
        .byte   $04,$44,$10,$01,$00,$03,$11,$04
        .byte   $00,$01,$10,$01,$00,$02,$04,$01
        .byte   $00,$02,$41,$01,$00,$01,$40,$00
        .byte   $03,$01,$10,$01,$04,$11,$40,$00
        .byte   $02,$01,$10,$01,$40,$41,$00,$04
        .byte   $10,$01,$40,$04,$00,$02,$04,$40
        .byte   $10,$01,$00,$02,$11,$10,$01,$01
        .byte   $04,$00,$03,$11,$04,$44,$10,$01
        .byte   $00,$03,$11,$04,$00,$01,$10,$01
        .byte   $00,$02,$04,$01,$00,$02,$41,$01
        .byte   $00,$01,$40,$00,$03,$01,$10,$01
        .byte   $04,$11,$40,$00,$01,$01,$00,$01
        .byte   $10,$01,$40,$40,$00,$01,$01,$00
        .byte   $01,$10,$01,$40,$04,$00,$02,$01
        .byte   $0F,$1F,$3F,$FF,$03,$00,$04,$03
        .byte   $07,$0F,$0E,$00,$01,$03,$3E,$F8
        .byte   $E0,$80,$80,$00,$02,$80,$00,$AE
        .byte   $FF,$08,$00,$03,$04,$00,$01,$10
        .byte   $01,$00,$03,$40,$01,$00,$01,$40
        .byte   $00,$01,$10,$01,$01,$00,$01,$10
        .byte   $01,$00,$01,$40,$00,$02,$44,$10
        .byte   $01,$04,$10,$01,$00,$03,$44,$10
        .byte   $01,$00,$01,$40,$00,$03,$44,$10
        .byte   $01,$01,$00,$02,$01,$10,$01,$04
        .byte   $00,$02,$04,$11,$00,$01,$01,$00
        .byte   $03,$04,$41,$00,$01,$44,$00,$03
        .byte   $04,$41,$00,$04,$01,$00,$01,$40
        .byte   $00,$01,$10,$01,$01,$00,$01,$10
        .byte   $01,$00,$01,$40,$00,$02,$44,$10
        .byte   $01,$04,$10,$01,$00,$03,$44,$10
        .byte   $01,$00,$01,$40,$00,$02,$11,$04
        .byte   $00,$02,$44,$00,$04,$10,$01,$00
        .byte   $02,$02,$07,$1F,$3F,$7F,$7F,$7F
        .byte   $7F,$7F,$00,$03,$01,$03,$03,$03
        .byte   $00,$01,$7E,$F8,$F8,$F0,$E0,$E0
        .byte   $E0,$F8,$00,$B8,$FF,$08,$00,$01
        .byte   $80,$80,$80,$C0,$C0,$C0,$C0,$04
        .byte   $00,$03,$41,$04,$00,$05,$11,$04
        .byte   $00,$02,$10,$01,$00,$01,$04,$01
        .byte   $00,$02,$41,$04,$10,$01,$40,$00
        .byte   $03,$01,$10,$01,$40,$00,$01,$40
        .byte   $00,$02,$01,$10,$01,$40,$00,$01
        .byte   $01,$00,$03,$10,$01,$40,$04,$00
        .byte   $01,$01,$04,$40,$10,$01,$00,$02
        .byte   $11,$44,$00,$01,$04,$00,$03,$11
        .byte   $04,$00,$05,$11,$04,$00,$02,$10
        .byte   $01,$00,$02,$04,$01,$00,$01,$40
        .byte   $04,$11,$10,$01,$00,$01,$40,$00
        .byte   $01,$04,$01,$00,$01,$10,$02,$00
        .byte   $01,$10,$01,$00,$01,$40,$00,$02
        .byte   $40,$3F,$1F,$07,$07,$0F,$0F,$3F
        .byte   $FF,$01,$00,$07,$80,$FE,$3F,$0F
        .byte   $03,$00,$02,$03,$0F,$00,$01,$80
        .byte   $E0,$F8,$F8,$F0,$E0,$80,$00,$B0
        .byte   $FF,$08,$C0,$C0,$C0,$E0,$E0,$E0
        .byte   $E0,$E0,$41,$04,$00,$02,$10,$01
        .byte   $00,$01,$04,$00,$02,$40,$00,$02
        .byte   $44,$10,$01,$01,$40,$00,$03,$44
        .byte   $10,$01,$00,$02,$04,$00,$02,$44
        .byte   $10,$01,$01,$00,$01,$40,$00,$01
        .byte   $10,$01,$04,$00,$02,$04,$11,$40
        .byte   $00,$04,$04,$41,$00,$05,$04,$41
        .byte   $00,$02,$04,$40,$01,$00,$01,$40
        .byte   $00,$01,$10,$01,$01,$04,$00,$02
        .byte   $40,$00,$02,$44,$10,$01,$00,$05
        .byte   $44,$10,$01,$01,$00,$02,$40,$00
        .byte   $03,$01,$10,$01,$40,$00,$01,$01
        .byte   $01,$07,$0F,$1F,$1F,$3F,$3F,$00
        .byte   $01,$01,$03,$02,$1E,$38,$60,$78
        .byte   $C0,$C0,$80,$00,$05,$3E,$3E,$3E
        .byte   $1C,$0C,$06,$00,$BA,$FF,$08,$E0
        .byte   $E0,$E0,$E0,$E0,$F0,$F8,$F8,$00
        .byte   $01,$04,$01,$00,$01,$40,$01,$00
        .byte   $02,$10,$01,$00,$01,$01,$00,$01
        .byte   $10,$01,$00,$01,$44,$00,$01,$41
        .byte   $00,$01,$10,$01,$41,$00,$02,$44
        .byte   $10,$01,$00,$02,$01,$10,$01,$40
        .byte   $10,$01,$00,$01,$11,$00,$01,$01
        .byte   $10,$01,$40,$00,$01,$01,$10,$01
        .byte   $04,$00,$01,$10,$01,$40,$04,$00
        .byte   $01,$01,$00,$02,$10,$01,$00,$02
        .byte   $11,$44,$00,$02,$01,$00,$02,$11
        .byte   $04,$00,$02,$01,$10,$01,$00,$01
        .byte   $11,$04,$00,$02,$10,$01,$00,$01
        .byte   $40,$00,$03,$40,$04,$10,$01,$01
        .byte   $00,$01,$01,$44,$10,$01,$01,$00
        .byte   $02,$10,$01,$40,$3F,$3F,$1F,$0F
        .byte   $07,$07,$07,$00,$01,$3E,$03,$00
        .byte   $07,$80,$80,$F0,$00,$01,$07,$00
        .byte   $07,$80,$0F,$00,$07,$80,$FB,$00
        .byte   $07,$80,$00,$07,$0F,$00,$07,$E0
        .byte   $00,$07,$FE,$00,$90,$FF,$06,$FE
        .byte   $E0,$FE,$FF,$04,$BF,$0F,$01,$18
        .byte   $E0,$C0,$00,$02,$C0,$F0,$FC,$01
        .byte   $10,$01,$00,$01,$10,$01,$01,$40
        .byte   $00,$01,$10,$01,$01,$00,$01,$10
        .byte   $01,$41,$04,$00,$01,$01,$40,$00
        .byte   $03,$01,$00,$01,$10,$01,$01,$00
        .byte   $03,$04,$11,$40,$00,$04,$04,$41
        .byte   $00,$02,$04,$00,$01,$40,$00,$01
        .byte   $40,$00,$02,$44,$10,$01,$00,$02
        .byte   $40,$00,$02,$11,$04,$00,$02,$04
        .byte   $00,$02,$44,$10,$01,$00,$02,$01
        .byte   $04,$00,$01,$44,$10,$01,$00,$02
        .byte   $41,$00,$01,$40,$00,$02,$04,$01
        .byte   $00,$01,$10,$01,$40,$00,$01,$01
        .byte   $00,$01,$40,$00,$01,$01,$00,$03
        .byte   $10,$01,$01,$10,$01,$00,$01,$10
        .byte   $01,$40,$00,$02,$FF,$01,$3F,$03
        .byte   $00,$05,$FF,$04,$7F,$1F,$01,$00
        .byte   $01,$FF,$07,$07,$FF,$08,$00,$04
        .byte   $3E,$00,$09,$FF,$01,$03,$0F,$00
        .byte   $05,$F8,$FF,$01,$EE,$00,$06,$FF
        .byte   $01,$20,$00,$06,$FE,$00,$14,$7F
        .byte   $00,$07,$E0,$7F,$00,$07,$FF,$01
        .byte   $00,$07,$80,$00,$00,$00,$00,$00
        .byte   $52,$10,$A0,$50,$02,$10,$26,$50
        .byte   $06,$10,$22,$50,$07,$10,$21,$50
        .byte   $08,$10,$20,$90,$50,$01,$90,$50
        .byte   $05,$10,$20,$90,$90,$90,$50,$02
        .byte   $10,$23,$90,$50,$06,$10,$21,$90
        .byte   $90,$90,$50,$01,$10,$08,$50,$01
        .byte   $10,$1B,$90,$90,$A0,$10,$09,$50
        .byte   $01,$10,$1A,$60,$90,$90,$10,$0A
        .byte   $50,$01,$10,$03,$50,$01,$10,$16
        .byte   $60,$90,$50,$06,$10,$05,$50,$08
        .byte   $10,$13,$60,$90,$50,$06,$10,$05
        .byte   $50,$0D,$60,$60,$60,$60,$60,$10
        .byte   $03,$50,$01,$60,$60,$60,$60,$60
        .byte   $60,$90,$50,$06,$10,$05,$50,$08
        .byte   $60,$60,$16,$01,$E6,$07,$16,$04
        .byte   $E6,$05,$16,$01,$90,$50,$10,$60
        .byte   $60,$60,$16,$01,$E6,$11,$16,$02
        .byte   $90,$50,$0E,$60,$E6,$06,$16,$12
        .byte   $90,$50,$0D,$60,$E6,$03,$16,$16
        .byte   $90,$90,$50,$0C,$60,$E6,$0A,$16
        .byte   $0F,$90,$90,$50,$0B,$60,$E6,$04
        .byte   $16,$03,$E6,$02,$16,$11,$90,$90
        .byte   $50,$0B,$60,$E6,$10,$16,$0A,$90
        .byte   $90,$90,$50,$0C,$60,$60,$60,$60
        .byte   $E6,$0B,$16,$0A,$90,$10,$02,$A0
        .byte   $10,$0D,$60,$10,$2E,$DA,$B0
