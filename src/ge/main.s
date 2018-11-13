;-------------------------------------------------------------------------------
;
; main.s
;
; Entry point for the character select/generation routines.
;
;-------------------------------------------------------------------------------

.include "c64.inc"

.include "mi.inc"
.include "st.inc"
.include "hello.inc"

.export main_menu

.import clear_text_area_below_cursor
.import create_character
.import draw_border
.import select_character
.import wait_for_user

PROCESSOR_PORT      := $0001

character_roster    := $B000

        .setcpu "6502"

.segment "CODE_MAIN"

;-----------------------------------------------------------
;                       main_menu
;
; Displays the Ultima 1 main menu and handles the users
; input. From the main menu, the user can either choose to
; create a new character, or play with an existing
; character.
;-----------------------------------------------------------

        ldx     #$11                                    ; Load the RO file (character roster) at $B000
        jsr     load_file

main_menu:
        jsr     st_set_text_window_full                 ; Set the text view to fill the entire window (minus border)

        lda     #$00                                    ; Set up the two bitmap address masks
        sta     BM2_ADDR_MASK
        sta     BM_ADDR_MASK

        jsr     draw_border
        jsr     clear_text_area_below_cursor

        ldy     #$06
        ldx     #$0C
        jsr     mi_print_text_at_x_y

        .byte   $1B,$1B,$1B," Ultima I ",$1B,$1B,$1B,"||",$7F

        .byte   $0E,"from darkest|",$7F
        .byte   $0E,"dungeons, to|",$7F
        .byte   $0D,"deepest space!|||",$7F


        .byte   $07,"a) Generate new character|",$7F
        .byte   $07,"b) Continue previous game||",$7F

        .byte   $0D,"Thy choice: ",$00

        jsr     st_swap_bitmaps

@read_input:
        jsr     st_read_input

        pha
        jsr     clear_text_area_below_cursor
        pla

        cmp     #$41                                    ; If the input is 'A' then jump to creating a character.
        bne     @not_a
        jmp     create_character

@not_a: cmp     #$42                                    ; If the input isn't 'B', then wait for more input.
        bne     @read_input

        lda     #$62                                    ; Print a 'b' out to the screen.
        jsr     st_print_char

        lda     character_roster                        ; Check the first byte of all the character names.
        ora     character_roster + $10                  ; If they are all zero, then we have no characters yet.
        ora     character_roster + $20
        ora     character_roster + $30
        beq     @no_characters

        jsr     select_character                        ; Prompt the user for with which character to play.

        lda     selected_character                      ; Load the requested character file.
        clc
        adc     #$12
        tax
        jsr     load_file

        bcs     @on_error                               ; If there is an I/O error, or the loaded data does not
        lda     mi_player_save_data                     ; start with the bytes $CA,$01, then tell the user we have
        cmp     #$CA                                    ; failed.
        bne     @on_error
        lda     mi_player_save_data + 1
        cmp     #$01
        beq     @start_game

@on_error:
        jsr     mi_store_text_area

        ldx     #$02
        ldy     #$14
        jsr     mi_print_text_at_x_y

        .byte   "Disk error.",$00

        jsr     mi_restore_text_area                    ; Wait for the user to aknowledge the error, then return to main menu
        jsr     wait_for_user
        jmp     main_menu


@no_characters:
        jsr     mi_store_text_area                      ; Tell the user they need to create a character, then wait for input
        ldx     #$02
        ldy     #$15
        jsr     mi_print_text_at_x_y

        .byte   "Thou must first create a character.",$00

        jsr     mi_restore_text_area
        jmp     @read_input


@start_game:
        ldy     #$00
        lda     #$30                                    ; Expose all RAM
        sta     PROCESSOR_PORT
        ldx     #$0D

@loop:
@source_page    := * + 2
        lda     d000_ram_init_data,y                    ; Copy 13 * 256 bytes up to $D000
@dest_page      := * + 2
        sta     $D000,y
        iny
        bne     @loop
        inc     @source_page
        inc     @dest_page
        dex
        bne     @loop

        stx     CIA2_PRA

        lda     #$36                                    ; Turn I/O and KERNAL back on
        sta     PROCESSOR_PORT

        lda     mi_player_sound_flag                    ; Load players saved sound preference
        sta     st_sound_enabled_flag

        lda     #$60                                    ; Reconfigure the bitmap address mask
        sta     BM_ADDR_MASK

        jsr     mi_clear_screen_and_draw_border
        jsr     st_set_text_window_command
        jsr     st_scroll_text_area_up
        jsr     mi_display_stats

        lda     #$60                                    ; Reconfigure the second bitmap address mask
        sta     BM2_ADDR_MASK

        jsr     st_swap_bitmaps
        jsr     st_copy_screen_2_to_1

        jmp     mi_load_ou_module



.segment "DATA_D000"

d000_ram_init_data:
        .word   lands_of_lord_british - d000_ram_init_data
        .word   lands_of_the_feudal_lords - d000_ram_init_data
        .word   lands_of_the_dark_unknown - d000_ram_init_data
        .word   lands_of_danger_and_despair - d000_ram_init_data

lands_of_lord_british:
        .incbin "map_british.bin"

lands_of_the_feudal_lords:
        .incbin "map_feudal_lords.bin"

lands_of_the_dark_unknown:
        .incbin "map_dark_unknown.bin"

lands_of_danger_and_despair:
        .incbin "map_danger_and_despair.bin"

        .byte   $F2,$E9,$EE,$F4,$8D,$A0,$E1
        .byte   $A5
