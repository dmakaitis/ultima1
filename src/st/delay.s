;-------------------------------------------------------------------------------
;
; delay.s
;
; Simple method that simply does nothing but passes time.
;
;-------------------------------------------------------------------------------

.export delay_a_squared

        .setcpu "6502"

.segment "CODE_DELAY"

;-----------------------------------------------------------
;                      delay_a_squared
;
; Pauses for a period of time based on the value in the
; accumulator when the method is called. The delay will be
; of a duration equal to a constant times the value of the
; accumulator squared.
;-----------------------------------------------------------

delay_a_squared:
        sec
@loop_outer:
        pha
@loop_inner:
        sbc     #$01
        bne     @loop_inner
        pla
        sbc     #$01
        bne     @loop_outer
        rts
