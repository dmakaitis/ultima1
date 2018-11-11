;-------------------------------------------------------------------------------
;
; noise.s
;
; Command handler for turning sound on and off.
;
;-------------------------------------------------------------------------------

.include "st.inc"

.export mi_cmd_noise

.import mi_print_text

.import mi_player_sound_flag

        .setcpu "6502"

.segment "CODE_NOISE"

        .byte   $60



;-----------------------------------------------------------

b8BB0:  jsr     mi_print_text
        .byte   " off"
        .byte   $00
        rts

;-----------------------------------------------------------
;                       mi_cmd_noise
;
; Command handler for turning sound on and off.
;-----------------------------------------------------------

mi_cmd_noise:
        lda     st_sound_enabled_flag
        eor     #$FF
        sta     st_sound_enabled_flag
        sta     mi_player_sound_flag
        beq     b8BB0
        jsr     mi_print_text
        .byte   " on"
        .byte   $00
        rts
