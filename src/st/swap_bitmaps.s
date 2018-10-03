;-------------------------------------------------------------------------------
;
; swap_bitmaps.s
;
; This method swaps the visible bitmap area between the locations at $2000
; and $4000. Screen memory swaps between $0400 and $6000.
;
;-------------------------------------------------------------------------------

.include "c64.inc"
.include "stlib.inc"

.export swap_bitmaps
.export do_nothing2
.export do_nothing3

do_s1688            := $ffff
bitmap_cia_config   := $ffff
bitmap_vic_config   := $ffff
wait_for_raster     := $ffff

        .setcpu "6502"

.segment "CODE_SWAP"

;-----------------------------------------------------------
;                        swap_bitmaps
;
; This method swaps the visible bitmap area between the 
; locations at $2000 and $4000. Screen memory swaps between 
; $0400 and $6000.
;-----------------------------------------------------------

swap_bitmaps:
        jsr     wait_for_raster
        lda     BM_ADDR_MASK
        tax
        beq     @configure_cia
        ldx     #$01

@configure_cia:
        eor     BM2_ADDR_MASK
        sta     BM_ADDR_MASK
        lda     bitmap_cia_config,x
        sta     CIA2_PRA
        lda     bitmap_vic_config,x
        sta     VIC_VIDEO_ADR
@wait:  jsr     do_s1688
        bne     @wait
do_nothing2:
        rts

        .byte   $60,$60
do_nothing3:
        rts