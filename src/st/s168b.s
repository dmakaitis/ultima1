;-------------------------------------------------------------------------------
;
; s168b.s
;
; 
;
;-------------------------------------------------------------------------------

.export do_s168B

.export x_cache
.export y_cache
.export water_ctr
.export castle_flag_ctr
.export towne_flag_ctr

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