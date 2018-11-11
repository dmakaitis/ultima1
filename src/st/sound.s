;-------------------------------------------------------------------------------
;
; sound.s
;
; 
; Sound playing routines.
;
;-------------------------------------------------------------------------------

.include "c64.inc"

.export st_sound_enabled_flag

.export INPUT_BUFFER_SIZE
.export SOUND_BUFFER_SIZE

.export play_sound_a
.export queue_sound
.export play_next_sound

.export w1C7E
.export sid_amp_cfg

.import st_delay_a_squared

.import get_random_number

zp2A                    := $2A
zp2B                    := $2B
zp3A                    := $3A
zp3B                    := $3B
TMP_43                  := $43
INPUT_BUFFER_SIZE       := $56
SOUND_BUFFER            := $57
SOUND_BUFFER_SIZE       := $5B
TMP_5E                  := $5E

rC0E8                   := $C0E8

        .setcpu "6502"

.segment "CODE_SOUND"



sound_vectors:
        .addr   case_00 - 1                             ; Need to store the routine address minus one since the CPU will add
        .addr   case_02 - 1                             ; one to the program counter after 'returning' from the 'switch_on_x'
        .addr   case_04 - 1                             ; routine...
        .addr   case_06 - 1
        .addr   case_08 - 1
        .addr   case_0A - 1
        .addr   case_0C - 1
        .addr   case_0E - 1
        .addr   case_10 - 1



;-----------------------------------------------------------
;                        play_sound_a
;
; Plays one of several sounds depending on the value in the
; accumulator. The accumulator must contain an even value 
; from $00 to $10 that will decide what sound to play. If
; the value is outside of this range, then this method does
; nothing.
;
; Sounds available include the following:
;
; 00 - step
; 02 - hit
; 04 - attack 1 (melee?)
; 06 - attack 2 (ranged?)
; 08 - spell cast failed
; 0A - cast spell
; 0C - fire cannon
; 0E - movement blocked
; 10 - invalid command
;-----------------------------------------------------------

play_sound_a:
        stx     TMP_43                                  ; Cache the current value in the x register

        tax                                             ; Store the accumulator into the x register

        lsr     a                                       ; If the value in the accumulator is odd, then return
        bcs     return

        cpx     #$12                                    ; If the argument is >= $12, then return
        bcs     return

        lda     st_sound_enabled_flag                   ; Check some flag to see if this method should be disabled
        beq     return

        php
        sei
        jsr     play_sound_x
        plp
        rts



;-----------------------------------------------------------
;                       play_sound_x
;
; Executes one of the routines pointed to in the
; sound_vectors tables based on the value contained in the
; x register. X must be an even number in the range $00 to
; $10.
;-----------------------------------------------------------

play_sound_x:
        lda     sound_vectors + 1,x                     ; Pick an address from the switch vectors and push it onto the stack.
        pha                                             ; The routine will be 'called' when we return from this routine before
        lda     sound_vectors,x                         ; actually returning to the caller. Essentially, this is a switch statement.
        pha

return: ldx     TMP_43                                  ; Restore the x register before "returning" from this routine.
        rts



;-----------------------------------------------------------
;                     play_next_sound
;
; Plays the next sound in the sound buffer. If the sound
; buffer is empty, this method does nothing.
;-----------------------------------------------------------

play_next_sound:
        lda     SOUND_BUFFER_SIZE                       ; If the sound buffer is empty then return
        beq     @done

        lda     SOUND_BUFFER                            ; Load the next sound in the buffer

        ldx     #$01                                    ; Advance each entry in the sound buffer
@loop:  ldy     SOUND_BUFFER,x
        sty     SOUND_BUFFER - 1,x
        inx
        cpx     #$04
        bcc     @loop

        jsr     play_sound_a                            ; Play the sound

        dec     SOUND_BUFFER_SIZE                       ; Decrement the sound buffer size

@done:  rts



;-----------------------------------------------------------
;                       queue_sound
;
; Queues a sound for playback. Up to four sounds can be
; queued. If the last sound in the buffer is a "step"
; sound (sound zero), it will be overwritten by the new
; sound. If the sound buffer is full, the first sound in
; the buffer will be played in order to free up space prior
; to adding the new sound to the end of the queue.
;-----------------------------------------------------------

queue_sound:
        ldx     SOUND_BUFFER_SIZE                       ; If the sound buffer is empty then skip ahead and add it
        beq     @done

        ldy     SOUND_BUFFER - 1,x                      ; If the last sound in the buffer is sound 0 (step), then pretend there is one fewer sounds in the buffer and overwrite it
        bne     @skip
        dex

@skip:  cpx     #$04                                    ; If there are currently less than four sounds in the buffer, go ahead and buffer the next one
        bcc     @done

        pha                                             ; Since the buffer is full, play the next sound in the buffer to free up space
        jsr     play_next_sound
        pla

        ldx     SOUND_BUFFER_SIZE                       ; Get the new size of the buffer

@done:  sta     SOUND_BUFFER,x                          ; Add the sound to the end of the buffer
        inc     SOUND_BUFFER_SIZE

        rts



case_0E:
        ldy     #$10
        lda     #$30

b1BA6:  pha
        jsr     st_delay_a_squared
        jsr     toggle_voice_3
        pla
        dey
        bne     b1BA6
        rts

case_10:
        ldy     #$32
        lda     #$17
        bne     b1BA6                                   ; Always branches



case_0A:
        ldx     #$40
        ldy     #$40
        bne     b1BC2
case_06:
        ldx     #$E0
        ldy     #$06
b1BC2:  stx     zp3A
        stx     zp2A
        sty     zp3B
        lda     #$01
        sta     zp2B
b1BCC:  lda     zp3B
        sta     TMP_43 
b1BD0:  ldx     zp2A
b1BD2:  dex
        bne     b1BD2
        jsr     toggle_voice_3
        ldx     zp2B
b1BDA:  dex
        bne     b1BDA
        jsr     toggle_voice_3
        dec     TMP_43 
        bne     b1BD0
        dec     zp2A
        inc     zp2B
        lda     zp2B
        cmp     #$1B
        bne     b1BCC
b1BEE:  lda     zp3B
        sta     TMP_43 
b1BF2:  ldx     zp2A
b1BF4:  dex
        bne     b1BF4
        jsr     toggle_voice_3
        ldx     zp2B
b1BFC:  dex
        bne     b1BFC
        jsr     toggle_voice_3
        dec     TMP_43 
        bne     b1BF2
        inc     zp2A
        dec     zp2B
        bne     b1BEE
        rts



case_0C:
        lda     #$FB
        sta     zp3A
b1C11:  inx
        bne     b1C11
        jsr     toggle_voice_3
        dec     zp3A
        ldx     zp3A
        bne     b1C11
        rts



case_08:
        ldy     #$A0
b1C20:  tya
        tax
b1C22:  dex
        bne     b1C22
        jsr     toggle_voice_3
        dey
        bne     b1C20
        rts



case_04:
        lda     #$40
        sta     zp3A
        lda     #$E0
        sta     zp3B
b1C34:  jsr     get_random_number
        ora     zp3B
        tax
b1C3A:  dex
        bne     b1C3A
        jsr     toggle_voice_3
        dec     zp3B
        lda     zp3B
        cmp     zp3A
        bcs     b1C34
        rts



case_02:
        lda     #$E8                                    ; Sound played when landing an attack
        ldx     #$FF
        bne     b1C53

case_00:
        lda     #$00                                    ; Sound played when taking a step
        ldx     #$08

b1C53:  stx     zp3A
        sta     w1C69
        lda     #$00
        sta     zp3B
b1C5C:  jsr     get_random_number
        ora     zp3B
        tax
b1C62:  dex
        bne     b1C62
        jsr     toggle_voice_3
w1C69           := * + 1
        bit     rC0E8
        dec     zp3A
        bne     b1C5C
        rts



toggle_voice_3:
        sta     TMP_5E
        lda     sid_amp_cfg
        eor     #$80
        sta     sid_amp_cfg
        sta     SID_Amp
w1C7E           := * + 1
        lda     TMP_5E                                  ; Pretty sure this is a bug - this code gets overwritten by the init code, but
        rts                                             ; what is already here makes much more sense than what it gets overwritten with...



sid_amp_cfg:
        .byte   $8F



.segment "DATA_1638"

st_sound_enabled_flag:
        .byte   $FF
