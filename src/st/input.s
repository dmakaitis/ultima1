;-------------------------------------------------------------------------------
;
; input.s
;
; Routines for reading input from the player.
;
;-------------------------------------------------------------------------------

.export buffer_input
.export draw_world_and_get_input
.export get_input
.export read_input
.export scan_and_buffer_input
.export wait_for_input

.export bitmap_cia_config
.export bitmap_vic_config

.import delay_a_squared
.import do_nothing4
.import draw_world
.import print_char
.import scan_input

        .setcpu "6502"

INPUT_BUFFER            := $4E
INPUT_BUFFER_SIZE       := $56

.segment "CODE_INPUT"

;-----------------------------------------------------------
;                   scan_and_buffer_input
;
; 
;-----------------------------------------------------------

scan_and_buffer_input:
        jsr     scan_input                              ; Scan for input
        bpl     buffer_input_done                       ; If the high bit isn't set, then we're done

        ; continued below



;-----------------------------------------------------------
;                       buffer_input
;
; Scan for input and, if a command is being issued, store it
; in the buffer.
;-----------------------------------------------------------

buffer_input:
        cmp     #$90                                    ; Don't buffer certain keypresses...
        beq     buffer_input_done
        cmp     #$93
        beq     buffer_input_done

        cmp     #$A0                                    ; If the command is 'space', then clear out the input buffer
        bne     @store_input
        ldx     #$00
        stx     INPUT_BUFFER_SIZE

@store_input:
        ldx     INPUT_BUFFER_SIZE                       ; If the input buffer is full, discard the input
        cpx     #$08
        bcs     buffer_input_done

        sta     INPUT_BUFFER,x                          ; Store the command into the buffer
        inc     INPUT_BUFFER_SIZE

buffer_input_done:
        rts



bitmap_cia_config:
        .byte   $97,$96
bitmap_vic_config:
        .byte   $18,$80



;-----------------------------------------------------------
;                     wait_for_input
;
; Scan for input until either a certain period of time has
; elapsed or until there is a command waiting in the input
; buffer.
;-----------------------------------------------------------

wait_for_input:
        ldy     #$07                                    ; Check for input seven times
@done:  jsr     scan_and_buffer_input

        lda     INPUT_BUFFER_SIZE                       ; If the input buffer is not empty, then we're done
        bne     buffer_input_done

        lda     #$4F                                    ; Delay for a bit
        jsr     delay_a_squared

        dey                                             ; Keep going until we've checked seven times
        bne     @done

        rts



;-----------------------------------------------------------
;                       read_input
;
; Gets the next player command to process. This method works
; exactly like get_input, but will block until the player
; has issued a command.
;-----------------------------------------------------------

read_input:
        jsr     get_input                               ; Get the next command from the player.

        beq     read_input                              ; Keep trying until we have some input to process.
        rts



;-----------------------------------------------------------
;                        get_input
;
; Get the next player command to process. The accumulator
; will contain the next command to process, or zero if there
; is no command to process.
;-----------------------------------------------------------

get_input:
        jsr     cache_x_y_and_update_cursor             ; Update the cursor on the screen

        jsr     wait_for_input                          ; Wait for some input

        lda     INPUT_BUFFER_SIZE                       ; If there is some input to proces ........
        bne     b1E5A

        beq     restore_registers_and_return            ; Otherwise we're done



;-----------------------------------------------------------
;                 draw_world_and_get_input
;
; Draw the world, then get the next player command to
; process. The accumulator will contain the next command to
; process, or zero if there is no command to process.
;-----------------------------------------------------------

draw_world_and_get_input:
        jsr     cache_x_y_and_update_cursor
        jsr     draw_world
        lda     INPUT_BUFFER_SIZE
        beq     restore_registers_and_return

b1E5A:  lda     #$20
        jsr     print_char
        lda     INPUT_BUFFER
        dec     INPUT_BUFFER_SIZE
        ldx     #$01
        cmp     #$FF
        bne     b1E6B
        lda     #$88
b1E6B:  cmp     #$E0
        bcc     b1E71
        eor     #$20
b1E71:  ldy     INPUT_BUFFER,x
        sty     INPUT_BUFFER - 1,x
        inx
        cpx     #$08
        bcc     b1E71

restore_registers_and_return:
        ldx     x_cache
        ldy     y_cache
        and     #$7F
        rts



;-----------------------------------------------------------
;                cache_x_y_and_update_cursor
;
; 
;-----------------------------------------------------------

cache_x_y_and_update_cursor:
        stx     x_cache
        sty     y_cache
        jsr     do_nothing4

        ; continued in update_cursor



.segment "DATA_1789"

x_cache:
        .byte   $00
y_cache:
        .byte   $00
