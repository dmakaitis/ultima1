;-------------------------------------------------------------------------------
;
; clear_main_viewport.s
;
; This method clears the main viewport.
;
;-------------------------------------------------------------------------------

.include "c64.inc"
.include "kernel.inc"
.include "global.inc"
.include "stlib.inc"

.export clear_main_viewport

TMP_PTR_LO      := $60
TMP_PTR_HI      := $61

        .setcpu "6502"

.segment "CODE_CLR_VIEWPORT"

;-----------------------------------------------------------
;                        clear_main_viewport
;
; This clears the main viewport, setting all bitmap values
; to zero and setting color memory to white with a black
; background.
;-----------------------------------------------------------

clear_main_viewport:
        lda     #$21
        eor     BM_ADDR_MASK
        sta     TMP_PTR_HI
        lda     #$48
        sta     TMP_PTR_LO
        ldx     #$11

_outer_bitmap_loop:
        ldy     #$00
        tya
_clear_bitmap_loop:
        sta     (TMP_PTR_LO),y
        iny
        bne     _clear_bitmap_loop

        inc     TMP_PTR_HI
        ldy     #$2F
_clear_bitmap_loop2:
        sta     (TMP_PTR_LO),y
        dey
        bpl     _clear_bitmap_loop2
        lda     TMP_PTR_LO
        clc
        adc     #$40
        sta     TMP_PTR_LO
        bcc     _bitmap_address_updated
        inc     TMP_PTR_HI
_bitmap_address_updated:
        dex
        bpl     _outer_bitmap_loop

        lda     #$29
        sta     TMP_PTR_LO
        lda     #$04
        ldx     BM_ADDR_MASK
        beq     _set_screen_mem_hi
        lda     #$60
_set_screen_mem_hi:
        ldx     #$11
        sta     TMP_PTR_HI

_outer_screen_mem_loop:
        ldy     #$25
        lda     #$10
_inner_screen_mem_loop:
        sta     (TMP_PTR_LO),y
        dey
        bpl     _inner_screen_mem_loop
        lda     TMP_PTR_LO
        clc
        adc     #$28
        sta     TMP_PTR_LO
        bcc     _screen_mem_address_updated
        inc     TMP_PTR_HI
_screen_mem_address_updated:
        dex
        bpl     _outer_screen_mem_loop
        rts
