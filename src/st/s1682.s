;-------------------------------------------------------------------------------
;
; s1682.s
;
; 
;
;-------------------------------------------------------------------------------

.include "c64.inc"

.import get_random_number
.import delay_a_squared
.import w1638

.export play_sound_a
.export do_s1685
.export do_s1688

.export w1C7E
.export sid_amp_cfg

zp2A                    := $2A
zp2B                    := $2B
zp3A                    := $3A
zp3B                    := $3B
TMP_43                  := $43
INPUT_BUFFER_SIZE       := $56
zp57                    := $57
zp5B                    := $5B
TMP_5E                  := $5E

rC0E8                   := $C0E8

        .setcpu "6502"

.segment "CODE_S1682"



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
; from $00 to $10 that will decide what sound to play.
;-----------------------------------------------------------

play_sound_a:
        stx     TMP_43                                  ; Cache the current value in the x register

        tax                                             ; Store the accumulator into the x register

        lsr     a                                       ; If the value in the accumulator is odd, then return
        bcs     return

        cpx     #$12                                    ; If the argument is >= $12, then return
        bcs     return

        lda     w1638                                   ; Check some flag to see if this method should be disabled
        beq     return

        php
        sei
        jsr     switch_on_x
        plp
        rts



;-----------------------------------------------------------
;                       switch_on_x
;
; Executes one of the routines pointed to in the
; sound_vectors tables based on the value contained in the
; x register. X must be an even number in the range $00 to
; $10.
;-----------------------------------------------------------

switch_on_x:
        lda     sound_vectors + 1,x                     ; Pick an address from the switch vectors and push it onto the stack.
        pha                                             ; The routine will be 'called' when we return from this routine before
        lda     sound_vectors,x                         ; actually returning to the caller. Essentially, this is a switch statement.
        pha

return: ldx     TMP_43                                  ; Restore the x register before "returning" from this routine.
        rts



;-----------------------------------------------------------
;                         do_s1688
;
; 
;-----------------------------------------------------------

do_s1688:
        lda     zp5B                                    ; If the value at $5B is zero then return
        beq     @done

        lda     zp57

        ldx     #$01
@loop:  ldy     zp57,x
        sty     INPUT_BUFFER_SIZE,x
        inx
        cpx     #$04
        bcc     @loop

        jsr     play_sound_a

        dec     zp5B                                    ; Decrement the value at $5B
@done:  rts



;-----------------------------------------------------------
;                         do_s1685
;
; 
;-----------------------------------------------------------

do_s1685:
        ldx     zp5B                                    ; If the value at $5B is zero then return
        beq     @done

        ldy     INPUT_BUFFER_SIZE,x
        bne     @skip
        dex

@skip:  cpx     #$04
        bcc     @done

        pha
        jsr     do_s1688
        pla
        ldx     zp5B

@done:  sta     zp57,x

        inc     zp5B                                    ; Increment the value at $5B
        rts



case_0E:
        ldy     #$10
        lda     #$30

b1BA6:  pha
        jsr     delay_a_squared
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
        lda     #$E8
        ldx     #$FF
        bne     b1C53

case_00:
        lda     #$00
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
        rts                                             ; what's already here makes much more sense than what it gets overwritten with...



sid_amp_cfg:
        .byte   $8F
