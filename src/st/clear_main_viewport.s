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

.export clear_main_viewport

BM_ADDR_MASK    := $5C

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

@outer_bitmap_loop:
        ldy     #$00
        tya
@clear_bitmap_loop:
        sta     (TMP_PTR_LO),y
        iny
        bne     @clear_bitmap_loop

        inc     TMP_PTR_HI
        ldy     #$2F
@clear_bitmap_loop2:
        sta     (TMP_PTR_LO),y
        dey
        bpl     @clear_bitmap_loop2
        lda     TMP_PTR_LO
        clc
        adc     #$40
        sta     TMP_PTR_LO
        bcc     @bitmap_address_updated
        inc     TMP_PTR_HI
@bitmap_address_updated:
        dex
        bpl     @outer_bitmap_loop

        lda     #$29
        sta     TMP_PTR_LO
        lda     #$04
        ldx     BM_ADDR_MASK
        beq     @set_screen_mem_hi
        lda     #$60
@set_screen_mem_hi:
        ldx     #$11
        sta     TMP_PTR_HI

@outer_screen_mem_loop:
        ldy     #$25
        lda     #$10
@inner_screen_mem_loop:
        sta     (TMP_PTR_LO),y
        dey
        bpl     @inner_screen_mem_loop
        lda     TMP_PTR_LO
        clc
        adc     #$28
        sta     TMP_PTR_LO
        bcc     @screen_mem_address_updated
        inc     TMP_PTR_HI
@screen_mem_address_updated:
        dex
        bpl     @outer_screen_mem_loop
        rts
