;-------------------------------------------------------------------------------
;
; draw.s
;
; Routine for drawing the world to the main viewport.
;
;-------------------------------------------------------------------------------

.include "stlib.inc"

.export draw_world

.import animate_water
.import buffer_input
.import scan_input
.import swap_bitmaps

.import bitmap_y_offset_hi
.import bitmap_y_offset_lo

.import scrmem_y_offset_hi
.import scrmem_y_offset_lo

.import tile_images

.import r1480
.import r14C0
.import r1500
.import r1639

castle_flag_hi          := tile_images + $89
castle_flag_lo          := tile_images + $8A
towne_flag_hi           := tile_images + $C3
towne_flag_lo           := tile_images + $C4
ship_flag_l_hi          := tile_images + $182
ship_flag_l_lo          := tile_images + $183
ship_flag_r_hi          := tile_images + $18A
ship_flag_r_lo          := tile_images + $18B

PLAYER_X                := $20
PLAYER_Y                := $21
zp45                    := $45
VIEW_X                  := $46
VIEW_Y                  := $47
zp48                    := $48
zp49                    := $49
WORLD_PTR               := $4C
TMP_5E                  := $5E
TMP_PTR_LO              := $60
TMP_PTR_HI              := $61
TMP_PTR2_LO             := $62
TMP_PTR2_HI             := $63
TMP_PTR3_LO             := $64
TMP_PTR3_HI             := $65
zp66                    := $66
zp6F                    := $6F

rB700                   := $B700

        .setcpu "6502"

.segment "DATA_178B"

water_ctr:
        .byte   $01
castle_flag_ctr:
        .byte   $03
towne_flag_ctr:
        .byte   $02

w178E:  .byte   $01

.segment "CODE_DRAW"

;-----------------------------------------------------------
;                        draw_world
;
; 
;-----------------------------------------------------------

draw_world:
        lda     #$08                                    ; zp45 := 8
        sta     zp45

        sec                                             ; VIEW_X := PLAYER_X - 9
        lda     PLAYER_X
        sbc     #$09
        sta     VIEW_X

        sec                                             ; VIEW_Y := PLAYER_Y - 4
        lda     PLAYER_Y
        sbc     #$04
        sta     VIEW_Y

@loop:  jsr     scan_input                              ; Scan and buffer any input where the high bit is set
        bpl     @b1CA4
        jsr     buffer_input

@b1CA4: lda     VIEW_Y                                  
        cmp     #$40
        bcs     @b1CC7

        lsr     a                                       ; WORLD_PTR := $6400 + (accumulator * 64)
        sta     WORLD_PTR + 1
        lda     #$00
        ror     a
        lsr     WORLD_PTR + 1
        ror     a
        sta     WORLD_PTR
        lda     WORLD_PTR + 1
        adc     #$64
        sta     WORLD_PTR + 1

        ldx     #$00                                    ; x := 0
        ldy     VIEW_X                                  ; y := VIEW_X

@b1CBF: cpy     #$40
        bcc     @b1CD2
        lda     #$00
        beq     @b1CF1

@b1CC7: ldx     #$12
        lda     #$00
@b1CCB: sta     zp66,x
        dex
        bpl     @b1CCB
        bmi     @b1CFA
@b1CD2: lda     (WORLD_PTR),y
        and     #$7E
        cmp     #$20
        bcc     @b1CF1
        cmp     #$59
        bcs     @b1CF1
        stx     zp48
        sta     zp49
        inc     w178E
        ldx     w178E
        lda     rB700,x
        and     #$02
        adc     zp49
        ldx     zp48
@b1CF1: lsr     a
        sta     zp66,x
        inx
        iny
        cpx     #$13
        bcc     @b1CBF
@b1CFA: lda     VIEW_Y
        inc     VIEW_Y
        cmp     PLAYER_Y
        bne     @b1D08
        lda     r1639
        lsr     a
        sta     zp6F
@b1D08: ldx     zp45
        lda     bitmap_y_offset_lo,x
        clc
        adc     #$28
        sta     TMP_PTR_LO
        lda     bitmap_y_offset_hi,x
        adc     #$01
        eor     BM_ADDR_MASK
        sta     TMP_PTR_HI
        lda     TMP_PTR_LO
        adc     #$40
        sta     TMP_PTR2_LO
        lda     TMP_PTR_HI
        adc     #$01
        sta     TMP_PTR2_HI
        lda     zp45
        lsr     a
        lsr     a
        lsr     a
        tay
        lda     scrmem_y_offset_lo,y
        sta     TMP_PTR3_LO
        lda     scrmem_y_offset_hi,y
        ldx     BM_ADDR_MASK
        beq     @b1D3C
        clc
        adc     #$5C
@b1D3C: sta     TMP_PTR3_HI
        ldx     #$12
@b1D40: lda     zp66,x
        tay
        lda     r1500,y
        sta     TMP_5E
        lda     r1480,y
        sta     @w1D62
        clc
        adc     #$10
        sta     @w1D67
        lda     r14C0,y
        sta     @w1D62 + 1
        adc     #$00
        sta     @w1D67 + 1
        ldy     #$0F
@b1D61:
@w1D62          := * + 1
        lda     tile_images,y
        sta     (TMP_PTR_LO),y
@w1D67          := * + 1
        lda     tile_images,y
        sta     (TMP_PTR2_LO),y
        dey
        bpl     @b1D61
        txa
        asl     a
        tay
        iny
        lda     TMP_5E
        sta     (TMP_PTR3_LO),y
        iny
        sta     (TMP_PTR3_LO),y
        tya
        clc
        adc     #$28
        tay
        lda     TMP_5E
        sta     (TMP_PTR3_LO),y
        dey
        sta     (TMP_PTR3_LO),y
        lda     TMP_PTR_LO
        sec
        sbc     #$10
        sta     TMP_PTR_LO
        lda     TMP_PTR_HI
        sbc     #$00
        sta     TMP_PTR_HI
        lda     TMP_PTR2_LO
        sec
        sbc     #$10
        sta     TMP_PTR2_LO
        lda     TMP_PTR2_HI
        sbc     #$00
        sta     TMP_PTR2_HI
        dex
        bpl     @b1D40
        lda     zp45
        clc
        adc     #$10
        sta     zp45
        lda     zp45
        cmp     #$98
        bcs     @update_screen
        jmp     @loop


@update_screen:
        jsr     swap_bitmaps

        dec     water_ctr                               ; Update the water every two frames
        bne     @update_castle
        lda     #$02
        sta     water_ctr
        ldy     #$00
        jsr     animate_water

@update_castle:
        dec     castle_flag_ctr                         ; Update the castle flag every three frames
        bne     @update_towne
        lda     #$03
        sta     castle_flag_ctr
        ldx     castle_flag_hi
        ldy     castle_flag_lo
        sty     castle_flag_hi
        stx     castle_flag_lo

@update_towne:
        dec     towne_flag_ctr                          ; Update the towne flag every two frames
        bne     @update_ship
        lda     #$02
        sta     towne_flag_ctr
        ldx     towne_flag_hi
        ldy     towne_flag_lo
        sty     towne_flag_hi
        stx     towne_flag_lo

@update_ship:
        ldx     ship_flag_r_hi                          ; Update the ship flag every frame
        ldy     ship_flag_r_lo
        sty     ship_flag_r_hi
        stx     ship_flag_r_lo
        ldx     ship_flag_l_hi
        ldy     ship_flag_l_lo
        sty     ship_flag_l_hi
        stx     ship_flag_l_lo

        ; continued in scan_and_buffer_input



