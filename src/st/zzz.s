.include "stlib.inc"

.import bitmap_x_offset_hi
.import bitmap_x_offset_lo
.import bitmap_y_offset_hi
.import bitmap_y_offset_lo

.import scrmem_y_offset_hi
.import scrmem_y_offset_lo

.export do_s168E
.export do_s1691
.export do_s1694

.export do_s168B

.export w1786
.export w1788

zp24                    := $24
zp25                    := $25
zp26                    := $26
zp27                    := $27
zp28                    := $28
zp29                    := $29
zp2A                    := $2A
zp2B                    := $2B
TMP_PTR4_LO             := $34
TMP_PTR4_HI             := $35
zp3A                    := $3A
zp3B                    := $3B
zp4D                    := $4D
TMP_5E                  := $5E
TMP_PTR_LO              := $60
TMP_PTR_HI              := $61
TMP_PTR2_LO             := $62
TMP_PTR2_HI             := $63

        .setcpu "6502"

.segment "CODE_S168B"

;-----------------------------------------------------------
;                         do_s168B
;
; 
;-----------------------------------------------------------

do_s168B:
        sta     w1788
        ldx     #$FF
        cmp     #$00
        bne     b1782
        tax
        lda     #$10
        sta     w1788
b1782:  stx     w1786
        rts



.segment "DATA_1786"

w1786:  .byte   $FF,$60

w1788:  .byte   $06











.segment "CODE_S168E"

;-----------------------------------------------------------
;                         do_s168E
;
; 
;-----------------------------------------------------------

do_s168E:
        ldy     zp27
        bmi     b1864
        ldx     zp26
        lda     bitmap_y_offset_hi + $10,y
        eor     BM_ADDR_MASK
        sta     TMP_PTR2_HI
        lda     bitmap_y_offset_lo + $10,y
        sta     TMP_PTR2_LO
s17FF:  sty     TMP_5E
        tya
        lsr     a
        lsr     a
        lsr     a
        tay
        lda     scrmem_y_offset_lo + $02,y
        sta     TMP_PTR_LO
        lda     scrmem_y_offset_hi + $02,y
        ldy     BM_ADDR_MASK
        beq     b1815
        clc
        adc     #$5C
b1815:  sta     TMP_PTR_HI
        txa
        lsr     a
        lsr     a
        lsr     a
        clc
        adc     #$04
        tay
        sta     y_cache2
        lda     w1788
        sta     (TMP_PTR_LO),y
        lda     TMP_PTR2_LO
        clc
        adc     bitmap_x_offset_lo,y
        sta     TMP_PTR4_LO
        lda     TMP_PTR2_HI
        adc     bitmap_x_offset_hi,y
        sta     TMP_PTR4_HI
        ldy     #$00
        lda     w1786
        eor     (TMP_PTR4_LO),y
        and     r1380,x
        eor     (TMP_PTR4_LO),y
        sta     (TMP_PTR4_LO),y
        inx
        beq     b1862
        txa
        and     #$07
        bne     b1862
        ldy     #$08
        lda     w1786
        eor     (TMP_PTR4_LO),y
        and     #$80
        eor     (TMP_PTR4_LO),y
        sta     (TMP_PTR4_LO),y
        ldy     y_cache2
        iny
        lda     w1788
        sta     (TMP_PTR_LO),y
b1862:  ldy     TMP_5E
b1864:  rts

y_cache2:
        .byte   $00



;-----------------------------------------------------------
;                         do_s1691
;
; 
;-----------------------------------------------------------

do_s1691:
        stx     zp28
        sty     zp29




;-----------------------------------------------------------
;                         do_s1694
;
; 
;-----------------------------------------------------------

do_s1694:
        jsr     do_s168E
        lda     zp28
        cmp     zp26
        bne     b1879
        lda     zp29
        cmp     zp27
        beq     b1864
b1879:  lda     #$01
        sta     zp2A
        sta     zp2B
        ldx     #$FF
        sec
        lda     zp28
        sbc     zp26
        bcs     b188F
        sec
        lda     zp26
        sbc     zp28
        stx     zp2A
b188F:  sta     zp24
        sec
        lda     zp29
        sbc     zp27
        bcs     b189F
        sec
        lda     zp27
        sbc     zp29
        stx     zp2B
b189F:  sta     zp25
        cmp     zp24
        bcc     b18CE
        sta     zp3A
        lsr     a
        sta     zp3B
b18AA:  clc
        lda     zp3B
        adc     zp24
        sta     zp3B
        sec
        sbc     zp25
        bcc     b18BF
        sta     zp3B
        clc
        lda     zp26
        adc     zp2A
        sta     zp26
b18BF:  clc
        lda     zp27
        adc     zp2B
        sta     zp27
        jsr     do_s168E
        dec     zp3A
        bne     b18AA
        rts

b18CE:  lda     zp24
        sta     zp3A
        lsr     a
        sta     zp3B
b18D5:  clc
        lda     zp26
        adc     zp2A
        sta     zp26
        tax
        clc
        lda     zp3B
        adc     zp25
        sta     zp3B
        bcc     b18EB
        sbc     zp24
        jmp     j18F0

b18EB:  sec
        sbc     zp24
        bcc     b1908
j18F0:  sta     zp3B
        clc
        lda     zp27
        adc     zp2B
        sta     zp27
        tay
        bmi     b190B
        lda     bitmap_y_offset_lo + $10,y
        sta     TMP_PTR2_LO
        lda     bitmap_y_offset_hi + $10,y
        eor     BM_ADDR_MASK
        sta     TMP_PTR2_HI
b1908:  jsr     s17FF
b190B:  dec     zp3A
        bne     b18D5
        rts



.segment "DATA_1380"

r1380:  .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01
