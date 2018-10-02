;-------------------------------------------------------------------------------
;
; swap_bitmaps.s
;
; This method clears the main viewport.
;
;-------------------------------------------------------------------------------

.include "c64.inc"
.include "kernel.inc"
.include "global.inc"
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
; This clears the main viewport, setting all bitmap values
; to zero and setting color memory to white with a black
; background.
;-----------------------------------------------------------

swap_bitmaps:
        jsr     wait_for_raster
        lda     BM_ADDR_MASK
        tax
        beq     _configure_cia
        ldx     #$01

_configure_cia:
        eor     BM2_ADDR_MASK
        sta     BM_ADDR_MASK
        lda     bitmap_cia_config,x
        sta     CIA2_PRA
        lda     bitmap_vic_config,x
        sta     VIC_VIDEO_ADR
_wait:  jsr     do_s1688
        bne     _wait
do_nothing2:
        rts

        .byte   $60,$60
do_nothing3:
        rts