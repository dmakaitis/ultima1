;-------------------------------------------------------------------------------
;
; print_player_name.s
;
; Prints the name of the player character.
;
;-------------------------------------------------------------------------------

.export mi_print_player_name

.import mi_print_char

.import mi_player_name

        .setcpu "6502"

.segment "CODE_PLAYER"

;-----------------------------------------------------------
;                   mi_print_player_name
;
; Prints the name of the player character.
;-----------------------------------------------------------

mi_print_player_name:
        ldx     #$00

@loop:  lda     mi_player_name,x
        beq     @done
        jsr     mi_print_char
        inx
        bne     @loop

@done:  rts



