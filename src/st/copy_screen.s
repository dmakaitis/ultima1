;-------------------------------------------------------------------------------
;
; copy_screen.s
;
; This method copies the bitmap and screen memory from screen 2 to screen 1.
;
;-------------------------------------------------------------------------------

.include "c64.inc"
.include "stlib.inc"

.export copy_screen_2_to_1

TMP_PTR_LO      := $60
TMP_PTR_HI      := $61
TMP_PTR2_LO     := $62
TMP_PTR2_HI     := $63

BITMAP_MEM      := $2000
BITMAP_MEM2     := $4000

        .setcpu "6502"

.segment "CODE_COPY"

;-----------------------------------------------------------
;                     copy_screen_2_to_1
;
; This method swaps the visible bitmap area between the 
; locations at $2000 and $4000. Screen memory swaps between 
; $0400 and $6000.
;-----------------------------------------------------------

copy_screen_2_to_1:
        lda     #$20
        tax
        eor     BM_ADDR_MASK
        sta     _dest_addr
        eor     BM2_ADDR_MASK
        sta     _src_addr
        ldy     #$00

_loop:
_src_addr       := * + 2
        lda     BITMAP_MEM2,y
_dest_addr      := * + 2
        sta     BITMAP_MEM,y
        iny
        bne     _loop
        inc     _src_addr
        inc     _dest_addr
        dex
        bne     _loop

        lda     #$00
        sta     TMP_PTR_LO
        sta     TMP_PTR2_LO
        lda     _src_addr
        cmp     #$60
        beq     _set_screen_source
        lda     #$04
_set_screen_source:
        sta     TMP_PTR_HI
        lda     _dest_addr
        cmp     #$60
        beq     _set_screen_dest
        lda     #$04
_set_screen_dest:
        sta     TMP_PTR2_HI
        ldx     #$04
        ldy     #$00

_loop2: lda     (TMP_PTR_LO),y
        sta     (TMP_PTR2_LO),y
        iny
        bne     _loop2
        inc     TMP_PTR_HI
        inc     TMP_PTR2_HI
        dex
        bne     _loop2
        rts
