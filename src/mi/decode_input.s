;-------------------------------------------------------------------------------
;
; decode_input.s
;
; Decodes user input into a command and prints the command to the output.
;
;-------------------------------------------------------------------------------

.import mi_play_error_sound_and_reset_buffers
.import mi_print_text

.import print_string_entry_x

.import mi_command_table_override

.import command_table
.import command_decode_table

        .setcpu "6502"

.segment "CODE_DECODE"

;-----------------------------------------------------------
;               mi_decode_and_print_command_a
;
; Decodes the input that is in the accumulator and if it is
; a valid command, prints it to the output and returns the
; command ID * 2 in the x register. Returns 0 in the x
; register if the input is not a valid command.
;-----------------------------------------------------------

mi_decode_and_print_command_a:
        ldx     #$18                                    ; Validate input against the possible command
@loop:  cmp     command_decode_table,x
        beq     @command_found
        dex
        bpl     @loop

        jsr     mi_print_text                           ; If we did not match a valid command, let the user know
        .asciiz "Huh?"

        jsr     mi_play_error_sound_and_reset_buffers
        sec
        rts


@command_found:
        txa                                             ; a := the command ID (range 0 - 24)
        pha

        cmp     #$04                                    ; If the command was not a movement command...
        bcs     @print_standard_command                 ; ...then just print the command

        lda     mi_command_table_override + 1           ; Otherwise, check if the command names have been overridden
        beq     @print_standard_command

        sta     @new_command_table + 1                  ; If so, print the overridden command name
        lda     mi_command_table_override
        sta     @new_command_table
        jsr     print_string_entry_x
@new_command_table:
        .addr   command_table

        jmp     @done


@print_standard_command:
        jsr     print_string_entry_x
        .addr   command_table

@done:  pla                                             ; x := command ID * 2
        asl     a
        tax

        clc
        rts
