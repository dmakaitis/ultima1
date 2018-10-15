.include "c64.inc"
.include "kernel.inc"
.include "stlib.inc"

.import animate_water
.import delay_a_squared
.import do_nothing4
.import print_char
.import swap_bitmaps

.import bitmap_x_offset_hi
.import bitmap_x_offset_lo
.import bitmap_y_offset_hi
.import bitmap_y_offset_lo

.import scrmem_y_offset_hi
.import scrmem_y_offset_lo

.import tile_images

.import r1380

.import r1480
.import r14C0
.import r1500
.import r1632
.import r1637
.import r1639

.export get_random_number
.export read_from_buffer
.export read_input_from_buffer
.export scan_and_buffer_input
.export update_cursor
.export wait_for_input
.export wait_for_raster

.export do_s166A
.export do_s167C
.export do_s168E
.export do_s1691
.export do_s1694

.export bitmap_cia_config
.export bitmap_vic_config

.export do_s168B

.export w1786
.export w1788

zp20                    := $20
zp21                    := $21
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
zp45                    := $45
zp46                    := $46
zp47                    := $47
zp48                    := $48
zp49                    := $49
zp4C                    := $4C
zp4D                    := $4D
INPUT_BUFFER            := $4E
INPUT_BUFFER_SIZE       := $56
TMP_5E                  := $5E
TMP_PTR_LO              := $60
TMP_PTR_HI              := $61
TMP_PTR2_LO             := $62
TMP_PTR2_HI             := $63
TMP_PTR3_LO             := $64
TMP_PTR3_HI             := $65
zp66                    := $66
zp6F                    := $6F
zpC5                    := $C5

castle_flag_hi          := tile_images + $89
castle_flag_lo          := tile_images + $8A
towne_flag_hi           := tile_images + $C3
towne_flag_lo           := tile_images + $C4
ship_flag_l_hi          := tile_images + $182
ship_flag_l_lo          := tile_images + $183
ship_flag_r_hi          := tile_images + $18A
ship_flag_r_lo          := tile_images + $18B

rB700                   := $B700

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



w1786:  .byte   $FF,$60

w1788:  .byte   $06

x_cache:
        .byte   $00
y_cache:
        .byte   $00

water_ctr:
        .byte   $01
castle_flag_ctr:
        .byte   $03
towne_flag_ctr:
        .byte   $02

w178E:  .byte   $01







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








.segment "CODE_ZZZ"

wait_for_raster:
        jsr     scan_and_buffer_input
        lda     VIC_CTRL1
        bpl     wait_for_raster
        rts

do_s166A:
        lda     #$08
        sta     zp45
        sec
        lda     zp20
        sbc     #$09
        sta     zp46
        sec
        lda     zp21
        sbc     #$04
        sta     zp47
j1C9C:  jsr     scan_input
        bpl     b1CA4
        jsr     buffer_input
b1CA4:  lda     zp47
        cmp     #$40
        bcs     b1CC7
        lsr     a
        sta     zp4D
        lda     #$00
        ror     a
        lsr     zp4D
        ror     a
        sta     zp4C
        lda     zp4D
        adc     #$64
        sta     zp4D
        ldx     #$00
        ldy     zp46
b1CBF:  cpy     #$40
        bcc     b1CD2
        lda     #$00
        beq     b1CF1
b1CC7:  ldx     #$12
        lda     #$00
b1CCB:  sta     zp66,x
        dex
        bpl     b1CCB
        bmi     b1CFA
b1CD2:  lda     (zp4C),y
        and     #$7E
        cmp     #$20
        bcc     b1CF1
        cmp     #$59
        bcs     b1CF1
        stx     zp48
        sta     zp49
        inc     w178E
        ldx     w178E
        lda     rB700,x
        and     #$02
        adc     zp49
        ldx     zp48
b1CF1:  lsr     a
        sta     zp66,x
        inx
        iny
        cpx     #$13
        bcc     b1CBF
b1CFA:  lda     zp47
        inc     zp47
        cmp     zp21
        bne     b1D08
        lda     r1639
        lsr     a
        sta     zp6F
b1D08:  ldx     zp45
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
        beq     b1D3C
        clc
        adc     #$5C
b1D3C:  sta     TMP_PTR3_HI
        ldx     #$12
b1D40:  lda     zp66,x
        tay
        lda     r1500,y
        sta     TMP_5E
        lda     r1480,y
        sta     w1D62
        clc
        adc     #$10
        sta     w1D67
        lda     r14C0,y
        sta     w1D63
        adc     #$00
        sta     w1D68
        ldy     #$0F
b1D61:
w1D62           := * + 1
w1D63           := * + 2
        lda     tile_images,y
        sta     (TMP_PTR_LO),y
w1D67           := * + 1
w1D68           := * + 2
        lda     tile_images,y
        sta     (TMP_PTR2_LO),y
        dey
        bpl     b1D61
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
        bpl     b1D40
        lda     zp45
        clc
        adc     #$10
        sta     zp45
        lda     zp45
        cmp     #$98
        bcs     b1DB2
        jmp     j1C9C

b1DB2:  jsr     swap_bitmaps
        dec     water_ctr
        bne     b1DC4
        lda     #$02
        sta     water_ctr
        ldy     #$00
        jsr     animate_water
b1DC4:  dec     castle_flag_ctr
        bne     b1DDA
        lda     #$03
        sta     castle_flag_ctr
        ldx     castle_flag_hi
        ldy     castle_flag_lo
        sty     castle_flag_hi
        stx     castle_flag_lo
b1DDA:  dec     towne_flag_ctr
        bne     b1DF0
        lda     #$02
        sta     towne_flag_ctr
        ldx     towne_flag_hi
        ldy     towne_flag_lo
        sty     towne_flag_hi
        stx     towne_flag_lo
b1DF0:  ldx     ship_flag_r_hi
        ldy     ship_flag_r_lo
        sty     ship_flag_r_hi
        stx     ship_flag_r_lo
        ldx     ship_flag_l_hi
        ldy     ship_flag_l_lo
        sty     ship_flag_l_hi
        stx     ship_flag_l_lo
scan_and_buffer_input:
        jsr     scan_input
        bpl     b1E27
buffer_input:
        cmp     #$90
        beq     b1E27
        cmp     #$93
        beq     b1E27
        cmp     #$A0
        bne     b1E1D
        ldx     #$00
        stx     INPUT_BUFFER_SIZE
b1E1D:  ldx     INPUT_BUFFER_SIZE
        cpx     #$08
        bcs     b1E27
        sta     INPUT_BUFFER,x
        inc     INPUT_BUFFER_SIZE
b1E27:  rts

bitmap_cia_config:
        .byte   $97,$96
bitmap_vic_config:
        .byte   $18,$80
wait_for_input:
        ldy     #$07
b1E2E:  jsr     scan_and_buffer_input
        lda     INPUT_BUFFER_SIZE
        bne     b1E27
        lda     #$4F
        jsr     delay_a_squared
        dey
        bne     b1E2E
        rts

read_input_from_buffer:
        jsr     read_from_buffer
        beq     read_input_from_buffer
        rts

read_from_buffer:
        jsr     cache_x_y_and_update_cursor
        jsr     wait_for_input
        lda     INPUT_BUFFER_SIZE
        bne     b1E5A
        beq     b1E7A
do_s167C:
        jsr     cache_x_y_and_update_cursor
        jsr     do_s166A
        lda     INPUT_BUFFER_SIZE
        beq     b1E7A
b1E5A:  lda     #$20
        jsr     print_char
        lda     INPUT_BUFFER
        dec     INPUT_BUFFER_SIZE
        ldx     #$01
        cmp     #$FF
        bne     b1E6B
        lda     #$88
b1E6B:  cmp     #$E0
        bcc     b1E71
        eor     #$20
b1E71:  ldy     INPUT_BUFFER,x
        sty     zp4D,x
        inx
        cpx     #$08
        bcc     b1E71
b1E7A:  ldx     x_cache
        ldy     y_cache
        and     #$7F
        rts

cache_x_y_and_update_cursor:
        stx     x_cache
        sty     y_cache
        jsr     do_nothing4
update_cursor:
        ldx     cursor_char
        dex
        cpx     #$7C
        bcs     b1E96
        ldx     #$7F
b1E96:  stx     cursor_char
cursor_char     := * + 1
        lda     #$7C
        jsr     print_char
get_random_number:
        clc
        lda     w1ED4
        ldx     #$0E
b1EA4:  adc     w1EC5,x
        sta     w1EC5,x
        dex
        bpl     b1EA4
        lda     w1ED4
        clc
        adc     w1EC5
        sta     w1EC5
        ldx     #$0F
b1EB9:  inc     w1EC5,x
        bne     b1EC1
        dex
        bpl     b1EB9
b1EC1:  lda     w1EC5
        rts

w1EC5:  .byte   $64,$76,$85,$54,$F6,$5C,$76,$1F
        .byte   $E7,$12,$A7,$6B,$93,$C4,$6E
w1ED4:  .byte   $1B
scan_input:
        sty     TMP_5E
        lda     #$FF
        sta     CIA1_PRB
        lda     CIA1_PRA
        sty     TMP_5E
        ldy     #$04
b1EE3:  lsr     a
        bcs     b1EEC
        lda     r1632,y
        bne     b1F27
        rts

b1EEC:  dey
        bpl     b1EE3
        jsr     KERNEL_SCNKEY
        jsr     KERNEL_GETIN
        cmp     #$00
        bne     b1F01
        sta     w1F83
        sta     w1F84
        beq     b1F7A
b1F01:  cmp     #$BA
        bne     b1F07
        lda     #$40
b1F07:  cmp     #$91
        bne     b1F0D
        lda     #$40
b1F0D:  cmp     #$11
        bne     b1F13
        lda     #$2F
b1F13:  cmp     #$3F
        bne     b1F19
        lda     #$2F
b1F19:  cmp     #$9D
        bne     b1F1F
        lda     #$3A
b1F1F:  cmp     #$1D
        bne     b1F25
        lda     #$3B
b1F25:  ora     #$80
b1F27:  cmp     w1F83
        sta     w1F83
        bne     b1F6F
        cmp     #$C0
        beq     b1F46
        cmp     #$AF
        beq     b1F46
        cmp     #$BB
        beq     b1F46
        cmp     #$BA
        beq     b1F46
        lda     #$00
        sta     w1F84
        beq     b1F7A
b1F46:  ldy     r1637
        cpy     #$04
        bcs     b1F5E
        ldy     w1F84
        bne     b1F67
        ldy     CIA1_TODSEC
        bne     b1F62
        ldy     CIA1_TOD10
        cpy     #$05
        bcs     b1F62
b1F5E:  lda     #$00
        beq     b1F7A
b1F62:  inc     w1F84
        bne     b1F6F
b1F67:  ldy     CIA1_TOD10
        cpy     r1637
        bcc     b1F5E
b1F6F:  ldy     #$00
        sty     CIA1_TODHR
        sty     CIA1_TODSEC
        sty     CIA1_TOD10
b1F7A:  ldy     #$FF
        sty     zpC5
        ldy     TMP_5E
        pha
        pla
        rts

w1F83:  .byte   $00
w1F84:  .byte   $00,$A0,$FF