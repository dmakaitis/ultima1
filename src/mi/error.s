;-------------------------------------------------------------------------------
;
; error.s
;
; Routine for notifying the user they entered an invalid command.
;
;-------------------------------------------------------------------------------

.include "kernel.inc"
.include "st.inc"

.export mi_play_error_sound_and_reset_buffers

.export reset_buffers

        .setcpu "6502"

.segment "CODE_ERROR"

;-----------------------------------------------------------
;          mi_play_error_sound_and_reset_buffers
;
; Plays the error sound, then resets all buffers to clear
; out any user input that may not have been processed yet.
;-----------------------------------------------------------

mi_play_error_sound_and_reset_buffers:
        lda     #$10                                    ; Play the error sound
        jsr     st_play_sound_a

reset_buffers:
        nop                                             ; Wait until the user is not pressing anything
        nop
        nop
        jsr     KERNEL_GETIN
        cmp     #$00
        bne     reset_buffers

        lda     #$00                                    ; Clear out the input and sound buffers
        sta     SOUND_BUFFER_SIZE
        sta     INPUT_BUFFER_SIZE

        rts



