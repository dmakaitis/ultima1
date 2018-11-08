;-------------------------------------------------------------------------------
;
; press_space.s
;
; Prompts the player to press space to continue, then waits for a response.
;
;-------------------------------------------------------------------------------

.include "st.inc"

.export press_space_to_continue
.export swap_screens_and_press_space

.import mi_print_text
.import mi_store_text_area
.import mi_reset_buffers
.import mi_restore_text_area

.import bm_addr_mask_cache

        .setcpu "6502"

.segment "CODE_PRESS_SPACE"

;-----------------------------------------------------------
;               swap_screens_and_press_space
;
; Swaps the bitmap screens, then waits for the user to
; press space to continue.
;-----------------------------------------------------------

swap_screens_and_press_space:
        lda     bm_addr_mask_cache
        sta     BM2_ADDR_MASK
        jsr     st_swap_bitmaps
        jsr     st_copy_screen_2_to_1
        jsr     mi_restore_text_area

        ; continued in press_space_to_continue



;-----------------------------------------------------------
;                  press_space_to_continue
;
; Prompts the player to press space to continue, then waits
; for a response.
;-----------------------------------------------------------

press_space_to_continue:
        jsr     mi_print_text

        .byte   "}Press Space to continue: ",$00

        jsr     mi_reset_buffers                        ; Make sure we do not have any buffered input before waiting

@loop:  jsr     st_read_input

        cmp     #$0D                                    ; Keep looping until the user has pressed
        beq     b8B94                                   ; RETURN, SPACE or ??? (fire maybe)
        cmp     #$1B
        beq     b8B94
        cmp     #$20
        bne     @loop

b8B94:  jsr     st_clear_current_text_row               ; Remove "Press Space..." message

        inc     CUR_X                                   ; Put the cursor back to where it was
        dec     CUR_Y

        jsr     mi_reset_buffers                        ; Make sure we have no buffered input left before continuing
        jmp     mi_store_text_area
