;-------------------------------------------------------------------------------
;
; random.s
;
; Random number generator
;
;-------------------------------------------------------------------------------

.export get_random_number

        .setcpu "6502"

.segment "CODE_RANDOM"

;-----------------------------------------------------------
;                    get_random_number
;
; Generates a random number by combining values in the
; seed, then return the first byte in the seed. The random
; value is returned in the accumulator.
;-----------------------------------------------------------

get_random_number:
        clc
        lda     seed + $0F                              ; Update bytes zero through 15 of the seed
        ldx     #$0E
@loop_seed:
        adc     seed,x
        sta     seed,x
        dex
        bpl     @loop_seed

        lda     seed + $0F                              ; Update the first byte of the seed
        clc
        adc     seed
        sta     seed

        ldx     #$0F                                    ; Make sure the seed does not end with a zero - if so, increment the zero bytes at the end
@loop_inc:
        inc     seed,x
        bne     @done
        dex
        bpl     @loop_inc

@done:  lda     seed                                    ; The first byte in the seed is our random number
        rts



seed:   .byte   $64,$76,$85,$54,$F6,$5C,$76,$1F
        .byte   $E7,$12,$A7,$6B,$93,$C4,$6E,$1B



