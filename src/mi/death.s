;-------------------------------------------------------------------------------
;
; death.s
;
; Routine for informing the player that they have died.
;
;-------------------------------------------------------------------------------

.include "st.inc"

.export mi_player_died

.import mi_print_player_name
.import mi_print_tab
.import mi_print_text
.import mi_reset_buffers
.import mi_update_stats

.import mi_player_food
.import mi_player_hits
.import mi_player_money


.import death_image
.import bm_addr_mask_cache

SOURCE_PTR      := $60
DEST_PTR        := $62

        .setcpu "6502"

.segment "CODE_DEATH"

;-----------------------------------------------------------
;                      mi_player_died
;
; Informs the player that they have died, then waits for
; them to aknowledge.
;-----------------------------------------------------------

mi_player_died:
        jsr     mi_print_tab                            ; Inform the player they have died.
        jsr     mi_print_player_name
        jsr     mi_print_text

        .asciiz ", thou art dead."

        jsr     st_copy_screen_2_to_1

        lda     #$00                                    ; Reset gold, food and hit points to zero
        sta     mi_player_money
        sta     mi_player_money + 1
        sta     mi_player_food
        sta     mi_player_food + 1
        sta     mi_player_hits
        sta     mi_player_hits + 1

        ldy     BM2_ADDR_MASK
        sty     bm_addr_mask_cache
        sta     BM2_ADDR_MASK

        jsr     mi_update_stats                         ; Display the updated stats

        jsr     st_clear_main_viewport

        lda     #<death_image
        sta     SOURCE_PTR
        lda     #>death_image
        sta     SOURCE_PTR + 1

        lda     #$80                                    ; Draw the skull in the center of the main viewport
        sta     DEST_PTR
        lda     #$25
        eor     BM_ADDR_MASK
        sta     DEST_PTR + 1

        ldx     #$0C                                    ; Copy an area 72 pixels wide by 96 pixels high

@loop_y:
        ldy     #$47

@loop_x:
        lda     (SOURCE_PTR),y
        sta     (DEST_PTR),y
        dey
        bpl     @loop_x

        lda     SOURCE_PTR                              ; Advance the source by 72 bytes
        clc
        adc     #$48
        sta     SOURCE_PTR
        lda     SOURCE_PTR + 1
        adc     #$00
        sta     SOURCE_PTR + 1

        lda     DEST_PTR                                ; Advance the target by 320 bytes
        clc
        adc     #$40
        sta     DEST_PTR
        lda     DEST_PTR + 1
        adc     #$01
        sta     DEST_PTR + 1

        dex
        bne     @loop_y

        lda     #$02                                    ; Play the "player hit" sound twice
        jsr     st_queue_sound
        lda     #$02
        jsr     st_queue_sound

        lda     bm_addr_mask_cache
        sta     BM2_ADDR_MASK
        jsr     st_swap_bitmaps
        jmp     mi_reset_buffers                        ; Wait for the user to aknowledge, then return



;-----------------------------------------------------------
;-----------------------------------------------------------

        jsr     mi_player_died

        ; continued in mi_load_ou_module
