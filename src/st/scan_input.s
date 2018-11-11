;-------------------------------------------------------------------------------
;
; scan_input.s
;
; Routine for scanning the joystick and keyboard for input.
;
;-------------------------------------------------------------------------------

.include "c64.inc"
.include "kernel.inc"

.export st_scan_input

.export st_joystick_fire_key_equiv
.export st_key_repeat_rate_10ths

        .setcpu "6502"

TEMP_Y                  := $5E
zpC5                    := $C5

.segment "CODE_SCAN_INPUT"

;-----------------------------------------------------------
;                      st_scan_input
;
; Scans the keyboard and joystick for input. If a key or the
; joystick is currently being pressed, the input value is
; returned in the accumulator.
;-----------------------------------------------------------

st_scan_input:
        sty     TEMP_Y                                  ; cache the Y register

        lda     #$FF                                    ; Disable all keyboard matrix columns
        sta     CIA1_PRB

        lda     CIA1_PRA                                ; Read joystick port 2

        sty     TEMP_Y                                  ; cache the Y register (redundant)

        ldy     #$04                                    ; Check the five joystick bits
@loop_joystick:
        lsr     a
        bcs     @next_joystick_bit
        lda     joystick_commands,y                     ; If the bit is clear (meaning joystick is being pressed), get the equivalent keyboard command
        bne     @process_key_press
        rts



@next_joystick_bit:
        dey
        bpl     @loop_joystick

        jsr     KERNEL_SCNKEY                           ; Get the currently pressed key on the keyboard
        jsr     KERNEL_GETIN

        cmp     #$00                                    ; If no key was pressed, then we're done
        bne     @check_shift_at

        sta     last_key_pressed                        ; Record that the last "keypress" was empty
        sta     key_repeating_indicator
        beq     @done

@check_shift_at:
        cmp     #$BA                                    ; If the Shift-'@' key is being pressed, replace it with the '@' key (move up)
        bne     @check_cursor_up
        lda     #$40

@check_cursor_up:
        cmp     #$91                                    ; If the cursor up key is being pressed, replace it with the '@' key (move up)
        bne     @check_cursor_down
        lda     #$40

@check_cursor_down:
        cmp     #$11                                    ; If the cursor down key is being pressed, replace it with the '/' key (move down)
        bne     @check_question_mark
        lda     #$2F

@check_question_mark:
        cmp     #$3F                                    ; If the '?' key is being pressed, replace it with the '/' key (move down)
        bne     @check_cursor_left
        lda     #$2F

@check_cursor_left:
        cmp     #$9D                                    ; If the cursor left key is being pressed, replace it with the ':' key (move left)
        bne     @check_cursor_right
        lda     #$3A

@check_cursor_right:
        cmp     #$1D                                    ; If the cursor right key is being pressed, replace it with the ';' key (move right)
        bne     @set_high_bit
        lda     #$3B

@set_high_bit:
        ora     #$80                                    ; Set the high bit for the keyboard command

@process_key_press:
        cmp     last_key_pressed
        sta     last_key_pressed
        bne     @reset_repeat_timer                     ; If this is a new key, reset the key repeat timer

        cmp     #$C0                                    ; If any of the direction keys are set, check the repeat timer
        beq     @check_repeat_timer
        cmp     #$AF
        beq     @check_repeat_timer
        cmp     #$BB
        beq     @check_repeat_timer
        cmp     #$BA
        beq     @check_repeat_timer

        lda     #$00                                    ; If a direction key isn't being pressed, then never repeat the key
        sta     key_repeating_indicator
        beq     @done

@check_repeat_timer:
        ldy     st_key_repeat_rate_10ths                ; Disable repeating if the repeat rate is at least 0.4 seconds
        cpy     #$04
        bcs     @do_not_repeat

        ldy     key_repeating_indicator                 ; If the key is already repeating, use the "fast" repeat timer...
        bne     @check_10ths_timer

        ldy     CIA1_TODSEC                             ; If the key has already been held for more than 0.5 seconds, start repeating the key
        bne     @start_key_repeat
        ldy     CIA1_TOD10
        cpy     #$05
        bcs     @start_key_repeat
@do_not_repeat:
        lda     #$00
        beq     @done

@start_key_repeat:
        inc     key_repeating_indicator                 ; Set the key repeating indicator, then reset the timer
        bne     @reset_repeat_timer

@check_10ths_timer:
        ldy     CIA1_TOD10                              ; If the 10ths timer is less than the repeat timer, then do not repeat the key
        cpy     st_key_repeat_rate_10ths
        bcc     @do_not_repeat

@reset_repeat_timer:
        ldy     #$00
        sty     CIA1_TODHR
        sty     CIA1_TODSEC
        sty     CIA1_TOD10

@done:  ldy     #$FF
        sty     zpC5

        ldy     TEMP_Y                                  ; Restore the y register

        pha
        pla
        rts



last_key_pressed:
        .byte   $00

key_repeating_indicator:
        .byte   $00

        .byte   $A0,$FF



.segment "DATA_1632"

joystick_commands:
st_joystick_fire_key_equiv:
        .byte   $A0,$BB,$BA,$AF,$C0         ; fire, right, left, down, up (' ', ';', ':', '/', '@')

st_key_repeat_rate_10ths:
        .byte   $02
