;-------------------------------------------------------------------------------
;
; error.s
;
; Routine for notifying the user they entered an invalid command.
;
;-------------------------------------------------------------------------------

.include "kernel.inc"
.include "st.inc"

.export mi_cmd_invalid
.export mi_play_error_sound_and_reset_buffers
.export mi_reset_buffers

.import move_cursor_back_to_last_character

        .setcpu "6502"

.segment "CODE_ERROR"

;-----------------------------------------------------------
;                      mi_cmd_invalid
;
; Routine called if the user enters an invalid command.
;-----------------------------------------------------------

mi_cmd_invalid:
        jsr     move_cursor_back_to_last_character

        lda     #'?'
        jsr     st_print_char

        ; continued in mi_play_error_sound_and_reset_buffers



;-----------------------------------------------------------
;          mi_play_error_sound_and_reset_buffers
;
; Plays the error sound, then resets all buffers to clear
; out any user input that may not have been processed yet.
;-----------------------------------------------------------

mi_play_error_sound_and_reset_buffers:
        lda     #$10                                    ; Play the error sound
        jsr     st_play_sound_a

        ; Continued in mi_reset_buffers



;-----------------------------------------------------------
;                     mi_reset_buffers
;
; Resets all buffers to clear out any user input or sounds
; that may not have been processed yet.
;-----------------------------------------------------------

mi_reset_buffers:
        nop                                             ; Wait until the user is not pressing anything
        nop
        nop
        jsr     KERNEL_GETIN
        cmp     #$00
        bne     mi_reset_buffers

        lda     #$00                                    ; Clear out the input and sound buffers
        sta     SOUND_BUFFER_SIZE
        sta     INPUT_BUFFER_SIZE

        rts



