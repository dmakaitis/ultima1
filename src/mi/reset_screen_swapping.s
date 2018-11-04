;-------------------------------------------------------------------------------
;
; reset_screen_swapping.s
;
; Resets screen swapping so that the primary bitmap will be visible.
;
;-------------------------------------------------------------------------------

.include "c64.inc"
.include "st.inc"

.export reset_screen_swapping

        .setcpu "6502"

.segment "CODE_RESET_SCREEN"

;-----------------------------------------------------------
;                   reset_screen_swapping
;
; Resets screen swapping so that the primary bitmap will be
; visible.
;-----------------------------------------------------------

reset_screen_swapping:
        lda     BM_ADDR_MASK                            ; Make sure the primary bitmap is up to date
        bne     @set_vic_memory
        jsr     st_copy_screen_2_to_1

@set_vic_memory:
        lda     #$97                                    ; Set bitmap memory to $2000 and
        sta     CIA2_PRA                                ; screen memory to $0400
        lda     #$18
        sta     VIC_VIDEO_ADR

        lda     #$00
        sta     BM_ADDR_MASK
        sta     BM2_ADDR_MASK

        rts



