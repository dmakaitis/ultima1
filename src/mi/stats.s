;-------------------------------------------------------------------------------
;
; stats.s
;
; Routines for displaying the players primary stats.
;
;-------------------------------------------------------------------------------

.include "st.inc"

.export mi_display_stats

.import mi_print_text
.import mi_store_text_area

.import clear_to_end_then_print_lfcr
.import print_long_int

.import mi_player_experience
.import mi_player_food
.import mi_player_hits
.import mi_player_money

.import mi_number_padding

        .setcpu "6502"

.segment "CODE_STATS"

;-----------------------------------------------------------
;                     mi_display_stats
;
; Displays the primary stats for the player in the stats
; area of the screen, including writing the labels for each
; stat.
;-----------------------------------------------------------

mi_display_stats:
        jsr     mi_store_text_area
        jsr     st_set_text_window_stats

        jsr     mi_print_text                           ; Write the stat labels

        .byte   "Hits |Food |Exp. |Coin ",$00

        jmp     display_stat_values



;-----------------------------------------------------------
;                    print_stat_value_low_rev
;
; Prints the value for a stat. If the stat value is less
; than 100, the value will be highlighted by printing it in
; reverse text.
;-----------------------------------------------------------

print_stat_value_low_rev:
        cmp     #$01                                    ; If the stat value is less than 100...
        bcs     @print_value
        cpx     #$64
        bcs     @print_value

        pha                                             ; ...print in reverse text
        lda     #$FF
        sta     CHAR_REV
        pla

@print_value:
        jsr     print_long_int                          ; Print the value, then clear to the end of the text row
        jsr     clear_to_end_then_print_lfcr

        lda     #$00                                    ; Put text back into normal display mode
        sta     CHAR_REV

        rts


;-----------------------------------------------------------
;-----------------------------------------------------------

        jsr     mi_store_text_area



;-----------------------------------------------------------
;                   display_stat_values
;
; Displays the primary stats for the player in the stats
; area of the screen, but does not write the labels for the
; stats.
;-----------------------------------------------------------

display_stat_values:
        jsr     st_set_text_window_stats                ; 0 is in accumulator after this call...

        sta     mi_number_padding                       ; ...so we can disable number padding

        lda     #$24                                    ; Resize the text area to only include the area that
        sta     CUR_X_OFF                               ; contains the values (not the labels)
        lda     #$04
        sta     CUR_X_MAX

        lda     mi_player_hits + 1                      ; Display the player hitpoints
        ldx     mi_player_hits
        jsr     print_stat_value_low_rev                ; (in reverse if less than 100)

        lda     mi_player_food + 1                      ; Display the player food
        ldx     mi_player_food
        jsr     print_stat_value_low_rev                ; (in reverse if less than 100)

        lda     mi_player_experience + 1                ; Display player experience
        ldx     mi_player_experience
        jsr     print_long_int
        jsr     clear_to_end_then_print_lfcr

        lda     mi_player_money + 1                     ; Display player money
        ldx     mi_player_money
        jsr     print_long_int
        jsr     st_clear_to_end_of_text_row_a

        ; continued in mi_restore_text_area
