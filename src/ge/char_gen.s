;-------------------------------------------------------------------------------
;
; char_gen.s
;
;
;-------------------------------------------------------------------------------

.include "milib.inc"
.include "stlib.inc"

.export character_generation

.import clear_text_area_below_cursor
.import draw_border
.import main_menu
.import save_character

selected_character  := $C4F8

        .setcpu "6502"

.segment "CODE_CHAR_GEN"

;-----------------------------------------------------------
;                   character_generation
;
; Allows the user to create a character. First they will be
; allowed to distrubute 30 points across six attribute.
; Then they can select their race. Next they can choose
; their sex. After that, the may select their class.
;-----------------------------------------------------------

character_generation:
        stx     selected_character
        jsr     st_set_text_window_full
        jsr     draw_border

        ldy     #$00
        ldx     #$08
        jsr     mi_print_text_at_x_y
        
        .byte   $0E," Character Generation ",$18,"~",$00
        
        jsr     clear_text_area_below_cursor



        lda     #<(mi_player_save_data + 2)             ; Copy the new character template into the player save location in memory
        sta     @dest
        lda     #>(mi_player_save_data + 2)
        sta     @dest + 1
        
        lda     #<(new_char_template + 2)
        sta     @source
        lda     #>(new_char_template + 2)
        sta     @source + 1

@loop:
@source         := * + 1
        lda     $FFFF
@dest           := * + 1
        sta     $FFFF

        inc     @source                                 ; Increment the source address
        bne     @inc_dest
        inc     @source + 1

@inc_dest:
        inc     @dest                                   ; Increment the destination address
        bne     @check_done
        inc     @dest + 1

@check_done:
        lda     @source                                 ; Keep going until we've copied $8a bytes
        cmp     #<(new_char_template + $8a)
        bne     @loop
        lda     @source + 1
        cmp     #>(new_char_template + $8a)
        bne     @loop



        jsr     display_attributes

        lda     #$1E                                    ; Give the player 30 points to distribute
        sta     points_to_distribute

        ldx     #$01                                    ; Select the first attribute
        stx     selected_attribute

        ldy     #$0F                                    ; Print the instructions
        jsr     mi_print_text_at_x_y
        
        .byte   " Move cursor with up and down arrows,~"
        .byte   " increase and decrease attributes~"
        .byte   " with left and right arrows.~"
        .byte   " Press RETURN when finished,~"
        .byte   " or space bar to go back to main menu.",$00

@attribute_loop:
        jsr     display_attributes

        lda     #$63                                    ; Hide the cursor
        sta     CUR_X

        jsr     st_read_input                           ; y := user input
        tay

        lda     selected_attribute                      ; x := 2 * selected_attribute
        asl     a
        tax

        cpy     #$20                                    ; Did user press space?
        bne     @check_press_left
        jmp     main_menu                               ; If so, go back to the main menu

@check_press_left:
        cpy     #$3A                                    ; Did the user press LEFT?
        bne     @check_press_right

        lda     mi_player_hits,x                        ; If so, is the current attribute value equal to 10?
        cmp     #$0A
        beq     @attribute_loop                         ; If so, ignore

        dec     mi_player_hits,x                        ; Lower the attribute by one and return one point to distribute
        inc     points_to_distribute
        bne     @attribute_loop


@check_press_right:
        cpy     #$3B                                    ; Did the user press RIGHT?
        bne     @check_press_down

        lda     points_to_distribute                    ; Are there any points left to distribute?
        beq     @attribute_loop                         ; If not, ignore

        lda     mi_player_hits,x                        ; Is the attribute already equal to 30?
        cmp     #$19
        bcs     @attribute_loop                         ; If so, ignore

        inc     mi_player_hits,x                        ; Increase the attribute by one and remove a point to distrubute
        dec     points_to_distribute
        bpl     @attribute_loop


@check_press_down:                                      ; Did the user press DOWN?
        cpy     #$2F
        bne     @check_press_up

        inc     selected_attribute                      ; Select the next attribute

        lda     selected_attribute                      ; If the last attribute was already selected, go back to the first attribute
        cmp     #$07
        bcc     @attribute_loop
        lda     #$01
        sta     selected_attribute
        beq     @attribute_loop


@check_press_up:
        cpy     #$40                                    ; Did the user press UP?
        bne     @check_press_return

        dec     selected_attribute                      ; Select the previous attribute

        bne     @attribute_loop                         ; If the first attribute was already selected, go to the last attribute
        lda     #$06
        sta     selected_attribute
        bne     @attribute_loop

@check_press_return:
        cpy     #$0D                                    ; Did the user press RETURN?
        bne     @attribute_loop

        ldy     points_to_distribute                    ; Are there points left to distribute?
        beq     select_race

        jsr     mi_play_error_sound_and_read_input      ; If not, play an error sound and wait for more input
        jmp     @attribute_loop




;-----------------------------------------------------------

select_race:
        sty     selected_attribute                      ; selected_attribute := 0
        jsr     display_attributes                      ; Remove the header from the attribute display

        jsr     clear_text_area_below_cursor

        ldy     #$12                                    ; Print race options
        ldx     #$0B
        jsr     mi_print_text_at_x_y

        .byte   "a) Human|",$7F
        .byte   $0B,"b) Elf|",$7F
        .byte   $0B,"c) Dwarf|",$7F
        .byte   $0B,"d) Bobbit",$00

        ldy     #$10
        ldx     #$02
        jsr     mi_print_text_at_x_y
        
        .byte   "Select thy race: ",$00

@race_loop:
        jsr     st_read_input

        cmp     #$41                                    ; Is the input in the range of 'A' - 'D'?
        bcc     @race_loop
        cmp     #$45
        bcs     @race_loop

        sec                                             ; Store the selected race
        sbc     #$40
        sta     mi_player_race

        ldy     #$0C                                    ; Add the selected race to the display
        ldx     #$0D
        jsr     mi_print_text_at_x_y
        
        .byte   "Race  ",$00

        ldx     mi_player_race
        jsr     mi_print_string_entry_x
        .addr   mi_race_name_table

        jsr     clear_text_area_below_cursor

        lda     mi_player_race                          ; Did the user select human?
        cmp     #$01
        bne     @check_elf

        lda     mi_player_intelligence                  ; If so, increase their intelligence by 5
        clc
        adc     #$05
        sta     mi_player_intelligence
        bne     select_sex

@check_elf:
        cmp     #$02                                    ; Did the user select elf?
        bne     @check_dwarf

        lda     mi_player_agility                       ; If so, increase their agility by 5
        clc
        adc     #$05
        sta     mi_player_agility
        bne     select_sex

@check_dwarf:
        cmp     #$03                                    ; Did the user select dwarf?
        bne     @bobbit

        lda     mi_player_strength                      ; If so, increase their strength by 5
        clc
        adc     #$05
        sta     mi_player_strength
        bne     select_sex

@bobbit: 
        lda     mi_player_wisdom                        ; Must have selected bobbit; increase their wisdom by 5...
        clc
        adc     #$0A
        sta     mi_player_wisdom
        lda     mi_player_strength                      ; ...but lower their strength by 5
        sec
        sbc     #$05
        sta     mi_player_strength



;-----------------------------------------------------------

select_sex:
        jsr     display_attributes                      ; Update the attributes based on the selected race

        ldy     #$12                                    ; Display the sex options
        ldx     #$0B
        jsr     mi_print_text_at_x_y
        
        .byte   "a) Male|",$7F
        .byte   $0B,"b) Female",$00

        ldy     #$10
        ldx     #$02
        jsr     mi_print_text_at_x_y
        
        .byte   "Select thy sex: ",$00

@sex_loop:
        jsr     st_read_input

        cmp     #$41                                    ; Is the input in the range of 'A' - 'B'?
        bcc     @sex_loop
        cmp     #$43
        bcs     @sex_loop

        sec                                             ; If so, store the selecte sex
        sbc     #$41
        sta     mi_player_sex

        ldy     #$0D                                    ; Display the selected sex
        ldx     #$0E
        jsr     mi_print_text_at_x_y
        
        .byte   "Sex  ",$00

        ldx     mi_player_sex
        jsr     mi_print_string_entry_x
        .addr   sex_table



;-----------------------------------------------------------

        jsr     clear_text_area_below_cursor            ; Select the class options
        ldy     #$12
        ldx     #$0B
        jsr     mi_print_text_at_x_y
        
        .byte   "a) Fighter|",$7F
        .byte   $0B,"b) Cleric|",$7F
        .byte   $0B,"c) Wizard|",$7F
        .byte   $0B,"d) Thief",$00

        ldy     #$10
        ldx     #$02
        jsr     mi_print_text_at_x_y
        
        .byte   "Select thy class: ",$00

@class_loop:
        jsr     st_read_input                           ; Is the input in the range 'A' - 'D'?
        cmp     #$41
        bcc     @class_loop
        cmp     #$45
        bcs     @class_loop

        sec                                             ; Store the selected class
        sbc     #$40
        sta     mi_player_class

        ldy     #$0E                                    ; Display the selected class
        ldx     #$0C
        jsr     mi_print_text_at_x_y

        .byte   "Class  ",$00

        ldx     mi_player_class
        jsr     mi_print_string_entry_x
        .addr   mi_class_name_table

        lda     mi_player_class                         ; Did the user select fighter?
        cmp     #$01
        bne     @check_cleric

        lda     mi_player_strength                      ; If so, increase strength by 10...
        clc
        adc     #$0A
        sta     mi_player_strength

        lda     mi_player_agility                       ; ...and agility by 10
        clc
        adc     #$0A
        sta     mi_player_agility
        bne     b9252

@check_cleric:
        cmp     #$02                                    ; Did the user select cleric?
        bne     @check_wizard

        lda     mi_player_wisdom                        ; If so, increase wisdom by 10
        clc
        adc     #$0A
        sta     mi_player_wisdom
        bne     b9252

@check_wizard:
        cmp     #$03                                    ; Did the user select wizard?
        bne     @thief

        lda     mi_player_intelligence                  ; If so, increase intelligence by 10
        clc
        adc     #$0A
        sta     mi_player_intelligence
        bne     b9252

@thief:
        lda     mi_player_agility                       ; Player must have selected thief, so increase agility by 10
        clc
        adc     #$0A
        sta     mi_player_agility

b9252:  jsr     display_attributes
        jsr     st_get_random_number
        sta     mi_w8264
        jsr     st_get_random_number
        sta     mi_w8265
        ldy     #$10
        ldx     #$02
        jsr     mi_print_text_at_x_y

        .byte   "Enter thy name: ",$00
        
        jsr     clear_text_area_below_cursor
        lda     #$00
        sta     w93EA
b9281:  jsr     st_read_input
        ldx     w93EA
        cmp     #$0D
        bne     b92A1
        txa
        beq     b9281
        dec     CUR_Y
        jsr     clear_text_area_below_cursor
        lda     #$0B
        sta     CUR_X
        lda     #$03
        sta     CUR_Y
        jsr     mi_print_player_name
        jmp     save_character

b92A1:  cmp     #$3A
        beq     b92A9
        cmp     #$14
        bne     b92B9
b92A9:  dex
        bmi     b9281
        stx     w93EA
        lda     #$00
        sta     mi_player_name,x
        dec     CUR_X
        jmp     b9281

b92B9:  cpx     #$00
        bne     b92D1
        cmp     #$41
        bcc     b9281
        cmp     #$5B
        bcs     b9281
b92C5:  sta     mi_player_name,x
        inc     w93EA
        jsr     mi_print_char
        jmp     b9281

b92D1:  cpx     #$0D
        bcs     b9281
        cmp     #$20
        bcc     b9281
        cmp     #$40
        beq     b9281
        cmp     #$2F
        beq     b9281
        cmp     #$41
        bcc     b92C5
        cmp     #$5B
        bcs     b92C5
        ldy     mi_player_sex,x
        cpy     #$20
        beq     b92C5
        ora     #$20
        bne     b92C5



.segment "CODE_S9359"

;-----------------------------------------------------------
;                     display_attributes
;
;-----------------------------------------------------------

display_attributes:
        lda     #$00
        sta     mi_w85BE
        sta     mi_current_attribute

        ldx     #$05                                    ; Move the cursor to (5, 3)
        stx     CUR_X
        ldy     #$03
        sty     CUR_Y

        lda     selected_attribute                      ; If no attribute is selected, skip the header
        beq     @skip_header

        jsr     mi_print_text                           ; Tell the user how many points are left to distribute
        
        .byte   "Points left to distribute: ",$00

        lda     points_to_distribute
        jsr     mi_print_short_int

@skip_header:
        dec     CUR_X_MAX                               ; Clear the rest of the line except the last character
        jsr     st_clear_to_end_of_text_row_a
        inc     CUR_X_MAX

        jsr     mi_print_crlf_col_1                     ; Advance to the next line

@loop:  inc     mi_current_attribute

        inc     CUR_Y                                   ; Advance to the next line

        ldx     #$0A                                    ; Move cursor to column 10
        stx     CUR_X

        lda     #$20                                    ; Print the '>' next to the currently selected attribute
        ldx     mi_current_attribute
        cpx     selected_attribute
        bne     @print_prefix

        lda     #$0E
@print_prefix:
        jsr     mi_print_char

        jsr     mi_print_string_entry_x                 ; Print the attribute name
        .addr   mi_attribute_table

        lda     #$2E                                    ; Print '.'s until we reach column 26
        sta     mi_w85BE
@loop_periods:
        jsr     mi_print_char
        ldx     CUR_X
        cpx     #$1A
        bcc     @loop_periods

        lda     mi_current_attribute                    ; Print the value for the attribute
        asl     a
        tax
        lda     mi_player_hits,x
        jsr     mi_print_short_int

        lda     #$20                                    ; Print the '<' after the currently selected attribute
        ldx     mi_current_attribute
        cpx     selected_attribute
        bne     @print_suffix
        lda     #$18
@print_suffix:
        jsr     mi_print_char

        cpx     #$06                                    ; Go through all six attributes
        bcc     @loop

        rts









.segment "DATA_CHAR_GEN"

points_to_distribute:
        .byte   $00,$00
selected_attribute:
        .byte   $00
w93EA:  .byte   $00



sex_table:
        .byte   "mal",$E5
        .byte   "femal",$E5



new_char_template:
        .byte   $CA,$01,$00,$00,$FF,$FF,$27,$21
        .byte   $00,$00,$00,$00,$00,$01,$01,$00
        .byte   $01,$01,$00,$00,$00,$00,$01,$02
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$01,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$01,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$FF,$FF,$FF,$FF
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$96,$00,$0A,$00,$0A,$00,$0A
        .byte   $00,$0A,$00,$0A,$00,$0A,$00,$64
        .byte   $00,$01,$00,$01,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$95
        .byte   $C8,$00,$00,$00,$E8,$03,$E8,$03
        .byte   $00,$FF,$EF,$BE,$00,$00,$00,$00
        .byte   $00,$00
