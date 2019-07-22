.import st_bitmap_x_offset_hi
.import st_bitmap_x_offset_lo
.import st_bitmap_y_offset_hi
.import st_bitmap_y_offset_lo

.import scrmem_y_offset_hi
.import scrmem_y_offset_lo

.export do_set_draw_color
.export do_draw_pixel
.export do_draw_line_x_y
.export do_draw_line

BM_ADDR_MASK                        := $5C;

zp24                    := $24
zp25                    := $25
DRAW_START_X            := $26
DRAW_START_Y            := $27
DRAW_END_X              := $28
DRAW_END_Y              := $29
zp2A                    := $2A
zp2B                    := $2B
BITMAP_PTR              := $34
zp3A                    := $3A
zp3B                    := $3B
zp4D                    := $4D
Y_CACHE                 := $5E
SCREEN_PTR              := $60
BITMAP_ROW_PTR          := $62

        .setcpu "6502"

.segment "CODE_S168B"

;-----------------------------------------------------------
;                     do_set_draw_color
;
; Input:
;    a - color
;-----------------------------------------------------------

do_set_draw_color:
        sta     draw_color                              ; draw_color := a

        ldx     #$FF                                    ; x := $ff

        cmp     #$00                                    ; if color is not black on black then we're done
        bne     @done

        tax                                             ; x := a (0)

        lda     #$10                                    ; draw_color := $10
        sta     draw_color

@done:  stx     draw_mask                               ; draw_mask := x
        rts



.segment "DATA_1786"

draw_mask:  .byte   $FF,$60

draw_color:
        .byte   $06











.segment "CODE_S168E"

;-----------------------------------------------------------
;                      do_draw_pixel
;
; 
; Input:
;    DRAW_START_X - x coordinate (offset by 32 pixels)
;    DRAW_START_Y - y coordinate (offset by 16 pixels)
;
; Output:
;-----------------------------------------------------------

do_draw_pixel:
        ldy     DRAW_START_Y                            ; y := DRAW_START_Y
        bmi     done                                    ; if y is negative (high bit set), then we are done

        ldx     DRAW_START_X                            ; x := xp26

        lda     st_bitmap_y_offset_hi + $10,y           ; BITMAP_ROW_PTR := address in memory of row (y + 16) of the screen bitmap
        eor     BM_ADDR_MASK
        sta     BITMAP_ROW_PTR + 1
        lda     st_bitmap_y_offset_lo + $10,y
        sta     BITMAP_ROW_PTR

        ; continued in draw_pixel_x_y below



;-----------------------------------------------------------
;                      draw_pixel_x_y
;
; Draws a pixel at the given coordinates.
;
; Input:
;    x - x coordinate (offset by 32 pixels)
;    y - y coordinate (offset by 16 pixels)
;
; Output:
;-----------------------------------------------------------

draw_pixel_x_y:
        sty     Y_CACHE                                 ; Y_CACHE := y

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

        sta     x_coord_cache                           ; x_coord_cache := a (or y (or (x / 8) + 4))

        lda     draw_color                              ; SCREEN_PTR[y] := draw_color
        sta     (SCREEN_PTR),y

        lda     BITMAP_ROW_PTR                          ; BITMAP_PTR := BITMAP_ROW_PTR + bitmap_x_offset[y]
        clc
        adc     st_bitmap_x_offset_lo,y
        sta     BITMAP_PTR
        lda     BITMAP_ROW_PTR + 1
        adc     st_bitmap_x_offset_hi,y
        sta     BITMAP_PTR + 1

        ldy     #$00                                    ; y := 0

        lda     draw_mask                               ; a := draw_mask
        eor     (BITMAP_PTR),y
        and     line_pixel_masks,x
        eor     (BITMAP_PTR),y
        sta     (BITMAP_PTR),y

        inx
        beq     @restore_y

        txa                                             ; If (x + 1) is a multiple of 8...
        and     #$07
        bne     @restore_y

        ldy     #$08                                    ; ...draw an extra bit to the right of where we just drew...

        lda     draw_mask
        eor     (BITMAP_PTR),y
        and     #$80
        eor     (BITMAP_PTR),y
        sta     (BITMAP_PTR),y

        ldy     x_coord_cache                           ; ...and update the appropriate screen color value
        iny

        lda     draw_color
        sta     (SCREEN_PTR),y

@restore_y:
        ldy     Y_CACHE                                 ; y := Y_CACHE

done:   rts

x_coord_cache:
        .byte   $00



;-----------------------------------------------------------
;                      do_draw_line_x_y
;
; Input:
;    DRAW_START_X - start x coordinate
;    DRAW_START_Y - start y coordinate
;    x            - end x coordinate
;    y            - end y coordinate
;
; Output:
;-----------------------------------------------------------

do_draw_line_x_y:
        stx     DRAW_END_X                              ; DRAW_END_X := x
        sty     DRAW_END_Y                              ; DRAW_END_Y

        ; continued in do_s1964



;-----------------------------------------------------------
;                      do_draw_line
;
; Input:
;    DRAW_START_X - start x coordinate
;    DRAW_START_Y - start y coordinate
;    DRAW_END_X   - end x coordinate
;    DRAW_END_Y   - end y coordinate
;-----------------------------------------------------------

do_draw_line:
        jsr     do_draw_pixel                           ; Draw at (DRAW_START_X, DRAW_START_Y)

        lda     DRAW_END_X                                    ; Does DRAW_START_X = DRAW_END_X?
        cmp     DRAW_START_X
        bne     @not_done

        lda     DRAW_END_Y                              ; Does DRAW_START_Y = DRAW_END_X?
        cmp     DRAW_START_Y
        beq     done

@not_done:
        lda     #$01                                    ; zp2A := zp2B := 1
        sta     zp2A
        sta     zp2B

        ldx     #$FF                                    ; x := 255

        sec                                             ; zp24 := abs(DRAW_END_X - DRAW_START_X)
        lda     DRAW_END_X
        sbc     DRAW_START_X
        bcs     b188F
        sec
        lda     DRAW_START_X
        sbc     DRAW_END_X

        stx     zp2A
b188F:  sta     zp24

        sec                                             ; zp25 - abs(DRAW_END_Y-TART_Y)
        lda     DRAW_END_Y
  sbc     DRAW_START_Y
        bcs     b189F
        sec
        lda     DRAW_START_Y
        sbc     DRAW_END_Y
  stx     zp2B
b189F:  sta     zp25

        cmp     zp24                                    ; if zp25 < zp24...
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
        lda     DRAW_START_X
        adc     zp2A
        sta     DRAW_START_X
b18BF:  clc
        lda     DRAW_START_Y
        adc     zp2B
        sta     DRAW_START_Y
        jsr     do_draw_pixel                           ; Draw at (DRAW_START_X, DRAW_START_Y)
        dec     zp3A
        bne     b18AA
        rts

b18CE:  lda     zp24
        sta     zp3A
        lsr     a
        sta     zp3B
b18D5:  clc
        lda     DRAW_START_X
        adc     zp2A
        sta     DRAW_START_X
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
        lda     DRAW_START_Y
        adc     zp2B
        sta     DRAW_START_Y
        tay
        bmi     b190B
        lda     st_bitmap_y_offset_lo + $10,y
        sta     BITMAP_ROW_PTR
        lda     st_bitmap_y_offset_hi + $10,y
        eor     BM_ADDR_MASK
        sta     BITMAP_ROW_PTR + 1
b1908:  jsr     draw_pixel_x_y
b190B:  dec     zp3A
        bne     b18D5
        rts



.segment "DATA_1380"

line_pixel_masks:
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01         ; $C0 = 11000000
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01         ; $60 = 01100000
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01         ; $30 = 00110000
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01         ; $18 = 00011000
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01         ; $0C = 00001100
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01         ; $06 = 00000110
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01         ; $03 = 00000011
        .byte   $C0,$60,$30,$18,$0C,$06,$03,$01         ; $01 = 00000001 (special code will add bit 8 back in)
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
