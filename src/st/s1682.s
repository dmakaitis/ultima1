;-------------------------------------------------------------------------------
;
; s1682.s
;
; 
;
;-------------------------------------------------------------------------------

.include "c64.inc"

; .import get_random_number
.import delay_a_squared
.import w1638

.export do_s1682
.export do_s1685
.export do_s1688

.export sid_amp_cfg

zp2A                    := $2A
zp2B                    := $2B
zp3A                    := $3A
zp3B                    := $3B
zp43                    := $43
INPUT_BUFFER_SIZE       := $56
zp57                    := $57
zp5B                    := $5B
TMP_5E                  := $5E

rC0E8                   := $C0E8

get_random_number       := $ffff

        .setcpu "6502"

.segment "CODE_S1682"



switch_vectors:
        .addr   v1C4F - 1                               ; Need to store the routine address minus one since the CPU will add
        .addr   v1C49 - 1                               ; one to the program counter after 'returning' from the 'switch_on_x'
        .addr   v1C2C - 1                               ; routine...
        .addr   v1BBE - 1
        .addr   v1C1E - 1
        .addr   v1BB8 - 1
        .addr   v1C0D - 1
        .addr   v1BA2 - 1
        .addr   v1BB2 - 1



;-----------------------------------------------------------
;                         do_s1682
;
; 
;-----------------------------------------------------------

do_s1682:
        stx     zp43                                    ; Cache the current value in the x register
        tax
        lsr     a
        bcs     return
        cpx     #$12
        bcs     return
        lda     w1638
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
; switch_vectors tables based on the value contained in the
; x register. X must be an even number in the range $00 to
; $10.
;-----------------------------------------------------------

switch_on_x:
        lda     switch_vectors + 1,x                    ; Pick an address from the switch vectors and push it onto the stack.
        pha                                             ; The routine will be 'called' when we return from this routine before
        lda     switch_vectors,x                        ; actually returning to the caller. Essentially, this is a switch statement.
        pha

return: ldx     zp43                                    ; Restore the x register before "returning" from this routine.
        rts



;-----------------------------------------------------------
;                         do_s1688
;
; 
;-----------------------------------------------------------

do_s1688:
        lda     zp5B
        beq     b1B88
        lda     zp57
        ldx     #$01
b1B7A:  ldy     zp57,x
        sty     INPUT_BUFFER_SIZE,x
        inx
        cpx     #$04
        bcc     b1B7A
        jsr     do_s1682
        dec     zp5B
b1B88:  rts



;-----------------------------------------------------------
;                         do_s1685
;
; 
;-----------------------------------------------------------

do_s1685:
        ldx     zp5B
        beq     b1B9D
        ldy     INPUT_BUFFER_SIZE,x
        bne     b1B92
        dex
b1B92:  cpx     #$04
        bcc     b1B9D
        pha
        jsr     do_s1688
        pla
        ldx     zp5B
b1B9D:  sta     zp57,x
        inc     zp5B
        rts



v1BA2:  ldy     #$10
        lda     #$30
b1BA6:  pha
        jsr     delay_a_squared
        jsr     toggle_voice_3
        pla
        dey
        bne     b1BA6
        rts



v1BB2:  ldy     #$32
        lda     #$17
        bne     b1BA6
v1BB8:  ldx     #$40
        ldy     #$40
        bne     b1BC2
v1BBE:  ldx     #$E0
        ldy     #$06
b1BC2:  stx     zp3A
        stx     zp2A
        sty     zp3B
        lda     #$01
        sta     zp2B
b1BCC:  lda     zp3B
        sta     zp43
b1BD0:  ldx     zp2A
b1BD2:  dex
        bne     b1BD2
        jsr     toggle_voice_3
        ldx     zp2B
b1BDA:  dex
        bne     b1BDA
        jsr     toggle_voice_3
        dec     zp43
        bne     b1BD0
        dec     zp2A
        inc     zp2B
        lda     zp2B
        cmp     #$1B
        bne     b1BCC
b1BEE:  lda     zp3B
        sta     zp43
b1BF2:  ldx     zp2A
b1BF4:  dex
        bne     b1BF4
        jsr     toggle_voice_3
        ldx     zp2B
b1BFC:  dex
        bne     b1BFC
        jsr     toggle_voice_3
        dec     zp43
        bne     b1BF2
        inc     zp2A
        dec     zp2B
        bne     b1BEE
        rts



v1C0D:  lda     #$FB
        sta     zp3A
b1C11:  inx
        bne     b1C11
        jsr     toggle_voice_3
        dec     zp3A
        ldx     zp3A
        bne     b1C11
        rts



v1C1E:  ldy     #$A0
b1C20:  tya
        tax
b1C22:  dex
        bne     b1C22
        jsr     toggle_voice_3
        dey
        bne     b1C20
        rts



v1C2C:  lda     #$40
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

v1C49:  lda     #$E8
        ldx     #$FF
        bne     b1C53
v1C4F:  lda     #$00
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
        lda     TMP_5E
        rts

sid_amp_cfg:
        .byte   $8F
