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

BM_ADDR_MASK                        := $5C;

zp24                    := $24
zp25                    := $25
zp26                    := $26
zp27                    := $27
zp28                    := $28
zp29                    := $29
zp2A                    := $2A
zp2B                    := $2B
BITMAP_PTR              := $34
zp3A                    := $3A
zp3B                    := $3B
zp4D                    := $4D
TMP_5E                  := $5E
SCREEN_PTR              := $60
BITMAP_ROW_PTR          := $62

        .setcpu "6502"

.segment "CODE_S168B"

;-----------------------------------------------------------
;                         do_s168B
;
; 
;-----------------------------------------------------------

do_s168B:
        sta     w1788                                   ; w1788 := a

        ldx     #$FF                                    ; x := $ff

        cmp     #$00                                    ; if a != 0 then we're done
        bne     @done

        tax                                             ; x := a (0)

        lda     #$10                                    ; w1788 := $10
        sta     w1788

@done:  stx     w1786                                   ; w1786 := x
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
        ldy     zp27                                    ; y := zp27
        bmi     done                                    ; if y is negative (high bit set), then we're done

        ldx     zp26                                    ; x := xp26

        lda     bitmap_y_offset_hi + $10,y              ; BITMAP_ROW_PTR := address in memory of row (y + 16) of the screen bitmap
        eor     BM_ADDR_MASK
        sta     BITMAP_ROW_PTR + 1
        lda     bitmap_y_offset_lo + $10,y
        sta     BITMAP_ROW_PTR

s17FF:  sty     TMP_5E                                  ; TMP_5E := y

        tya                                             ; y /= 8
        lsr     a
        lsr     a
        lsr     a
        tay

        lda     scrmem_y_offset_lo + $02,y              ; SCREEN_PTR := address in screen memory of the same pixel row that BITMAP_ROW_PTR is pointing to in bitmap memory
        sta     SCREEN_PTR
        lda     scrmem_y_offset_hi + $02,y
        ldy     BM_ADDR_MASK
        beq     @set_screen_ptr_hi
        clc
        adc     #$5C
@set_screen_ptr_hi:
        sta     SCREEN_PTR + 1

        txa                                             ; y := (x / 8) + 4
        lsr     a
        lsr     a
        lsr     a
        clc
        adc     #$04
        tay

        sta     y_cache                                 ; y_cache := a (y)

        lda     w1788                                   ; SCREEN_PTR[y] := w1788
        sta     (SCREEN_PTR),y

        lda     BITMAP_ROW_PTR                          ; BITMAP_PTR := BITMAP_ROW_PTR + bitmap_x_offset[y]
        clc
        adc     bitmap_x_offset_lo,y
        sta     BITMAP_PTR
        lda     BITMAP_ROW_PTR + 1
        adc     bitmap_x_offset_hi,y
        sta     BITMAP_PTR + 1

        ldy     #$00                                    ; y := 0

        lda     w1786                                   ; a := w1786
        eor     (BITMAP_PTR),y
        and     r1380,x
        eor     (BITMAP_PTR),y
        sta     (BITMAP_PTR),y

        inx
        beq     b1862

        txa
        and     #$07
        bne     b1862

        ldy     #$08
        
        lda     w1786
        eor     (BITMAP_PTR),y
        and     #$80
        eor     (BITMAP_PTR),y
        sta     (BITMAP_PTR),y

        ldy     y_cache
        iny

        lda     w1788
        sta     (SCREEN_PTR),y

b1862:  ldy     TMP_5E
done:   rts

y_cache:
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
        beq     done

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
        sta     BITMAP_ROW_PTR
        lda     bitmap_y_offset_hi + $10,y
        eor     BM_ADDR_MASK
        sta     BITMAP_ROW_PTR + 1
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
