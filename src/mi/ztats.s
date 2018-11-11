;-------------------------------------------------------------------------------
;
; ztats.s
;
; Command handler for display all player character stats.
;
;-------------------------------------------------------------------------------

.include "st.inc"

.export mi_cmd_ztats

.export next_row_or_column
.export draw_border_and_restore_text_area

.import mi_cursor_to_col_0
.import mi_print_char
.import mi_print_player_name
.import mi_print_short_int
.import mi_print_string_entry_x
.import mi_print_text
.import mi_print_text_at_x_y
.import mi_print_x_chars
.import mi_restore_text_area
.import mi_store_text_area

.import draw_border
.import print_2_digits
.import print_digit
.import print_long_int
.import mi_print_string_entry_x2
.import reduce_text_window_size
.import swap_screens_and_press_space
.import to_decimal_a_x

.import mi_player_class
.import mi_player_current_vehicle
.import mi_player_enemy_vessels
.import mi_player_equipped_armor
.import mi_player_equipped_spell
.import mi_player_equipped_weapon
.import mi_player_experience
.import mi_player_gems
.import mi_player_hits
.import mi_player_inventory_armor
.import mi_player_inventory_spells
.import mi_player_inventory_vehicles
.import mi_player_inventory_weapons
.import mi_player_money
.import mi_player_race
.import mi_player_sex

.import mi_attribute_table
.import mi_class_name_table
.import mi_number_padding
.import mi_race_name_table
.import mi_selected_item

.import bm_addr_mask_cache

.import armor_table
.import gem_table
.import spell_table
.import vehicle_table
.import mi_weapon_table

dec_lo          := $3C
dec_mid         := $3D
string_entry    := $46

        .setcpu "6502"

.segment "CODE_ZTATS"

;-----------------------------------------------------------
;                       mi_cmd_ztats
;
; Display full information about the player character.
;-----------------------------------------------------------

mi_cmd_ztats:
        jsr     st_clear_main_viewport                  ; Clear the screen

        jsr     mi_store_text_area                      ; Cache the view area so we can tweak it

        jsr     st_set_text_window_main                 ; Make the main viewport the text window, but indent all sides by one
        jsr     reduce_text_window_size

        ldx     #$0C

        ldy     #$00                                    ; Disable number padding
        sty     mi_number_padding

        lda     BM2_ADDR_MASK                           ; Disable screen paging
        sta     bm_addr_mask_cache
        sty     BM2_ADDR_MASK

        jsr     mi_print_text_at_x_y                    ; Display player name
        .byte   $0E," Inventory ",$18
        .asciiz "||Player: "

        jsr     mi_print_player_name

        jsr     mi_print_text                           ; Display character level
        .asciiz "|A level "

        ldx     mi_player_experience                    ; Level = floor(experience / 1000) + 1
        lda     mi_player_experience + 1
        jsr     to_decimal_a_x
        lda     dec_mid
        lsr     a
        lsr     a
        lsr     a
        lsr     a
        clc
        adc     #$01
        jsr     mi_print_short_int

        inc     CUR_X                                   ; Display character sex
        lda     mi_player_sex
        beq     @male
        jsr     mi_print_text
        .asciiz "fe"

@male:  jsr     mi_print_text
        .asciiz "male "

        ldx     mi_player_race                          ; Display character race
        jsr     mi_print_string_entry_x2
        .addr   mi_race_name_table

        inc     CUR_X                                   ; Display character class
        ldx     mi_player_class
        jsr     mi_print_string_entry_x2
        .addr   mi_class_name_table

        jsr     set_text_window_ztats                   ; Clear the display for page 1 of the ztats

        dec     CUR_Y                                   ; Display attribute names
        ldx     #$00                                    ; (hits, str, agi, sta, chr, wis, and int)
        stx     mi_selected_item
@loop_attributes:
        stx     string_entry

        txa                                             ; y := x * 2
        asl     a
        tay

        ldx     mi_player_hits,y
        lda     mi_player_hits + 1,y

        bne     @print_attribute_name                   ; Do not display the attribute if its value is zero
        cpx     #$00
        beq     @skip_attribute

@print_attribute_name:
        jsr     print_string_entry_and_long_ax          ; Display the attribute name and value
        .addr   mi_attribute_table

@skip_attribute:
        ldx     string_entry                            ; Loop through all seven attributes
        inx
        cpx     #$07
        bcc     @loop_attributes

        ldx     mi_player_money                         ; Convert money to decimal
        lda     mi_player_money + 1
        jsr     to_decimal_a_x

        lda     dec_lo                                  ; Display the ones digit as copper coins
        and     #$0F
        beq     @no_copper                              ; Skip if the ones digit is zero

        jsr     next_row_or_column
        jsr     mi_print_text
        .asciiz "Copper pence...."

        lda     dec_lo
        jsr     print_digit

@no_copper:
        lda     dec_lo                                  ; Display the tens digit as silver coins
        lsr     a
        lsr     a
        lsr     a
        lsr     a
        beq     @no_silver                              ; Skip if the ones digit is zero

        pha
        jsr     next_row_or_column
        jsr     mi_print_text
        .asciiz "Silver pieces..."

        pla
        jsr     print_digit

@no_silver:
        lda     dec_mid                                 ; Display hundreds and thousands digits as gold crowns
        beq     @no_gold

        jsr     next_row_or_column
        jsr     mi_print_text
        .asciiz "Gold Crowns...."

        lda     dec_mid                                 ; If there are more than 10 gold crowns...
        cmp     #$10
        bcs     @print_2_digit_gold                     ; ...then print a two digit value

        lda     #'.'                                    ; Otherwise, add an extra pad character...
        jsr     mi_print_char
        lda     dec_mid                                 ; ...and print a one digit value
        jsr     print_digit
        jmp     @no_gold

@enemy_vessels_str:
        .byte   "Enemy vessel",$F3

@print_2_digit_gold:
        jsr     print_2_digits

@no_gold:
        lda     mi_player_enemy_vessels                 ; Display the number of enemy vessels
        beq     @no_enemy_vessels

        ldx     #$00
        stx     string_entry
        jsr     print_string_entry_and_short_a
        .addr   @enemy_vessels_str

@no_enemy_vessels:
        lda     mi_player_equipped_armor                ; Display armor counts and which is equipped
        sta     mi_selected_item
        ldx     #$01
@loop_armor:
        stx     string_entry
        lda     mi_player_inventory_armor,x
        beq     @no_armor
        jsr     print_string_entry_and_short_a
        .addr   armor_table
@no_armor:
        ldx     string_entry
        inx
        cpx     #$06                                    ; Loop through all five armor types
        bcc     @loop_armor

        lda     mi_player_current_vehicle               ; Display vehicle counts and which is currently being used
        sta     mi_selected_item
        ldx     #$01
@loop_vehicles:
        stx     string_entry
        lda     mi_player_inventory_vehicles,x
        beq     @no_vehicle
        jsr     print_string_entry_and_short_a
        .addr   vehicle_table
@no_vehicle:
        ldx     string_entry
        inx
        cpx     #$0B                                    ; Loop through all 10 vehicle types
        bcc     @loop_vehicles

        ldx     #$00                                    ; Display gem counts
        stx     mi_selected_item
@loop_gems:
        stx     string_entry
        lda     mi_player_gems,x
        beq     @no_gem
        jsr     print_string_entry_and_short_a
        .addr   gem_table
@no_gem:
        ldx     string_entry
        inx
        cpx     #$04                                    ; Loop through all four gems
        bcc     @loop_gems

        lda     mi_player_equipped_weapon               ; Display weapon counts and which is currently equipped
        sta     mi_selected_item
        ldx     #$01
@loop_weapons:
        stx     string_entry
        lda     mi_player_inventory_weapons,x
        beq     @no_weapon
        jsr     print_string_entry_and_short_a
        .addr   mi_weapon_table
@no_weapon:
        ldx     string_entry
        inx
        cpx     #$10                                    ; Loop through all fifteen weapons
        bcc     @loop_weapons

        lda     mi_player_equipped_spell                ; Display spell counts and which is currently equipped
        sta     mi_selected_item
        ldx     #$01
@loop_spells:
        stx     string_entry
        lda     mi_player_inventory_spells,x
        beq     @no_spell
        jsr     print_string_entry_and_short_a
        .addr   spell_table
@no_spell:
        ldx     string_entry
        inx
        cpx     #$0B                                    ; Loop through all 10 spells
        bcc     @loop_spells

        jsr     swap_screens_and_press_space            ; Update the screen

draw_border_and_restore_text_area:
        jsr     draw_border                             ; Redraw the border and restore the original text area
        jmp     mi_restore_text_area



;-----------------------------------------------------------
;                   next_row_or_column
;
; Advance the cursor to the next row or column. If the
; cursor is already at the end of the second column, wait
; for the user to press space, then clear the screen and
; move the cursor to the top-left.
;-----------------------------------------------------------

next_row_or_column:
        ldx     #$00                                    ; Advance to the start of the next line
        stx     CUR_X
        ldy     CUR_Y
        iny

        cpy     #$12                                    ; If we have passed row 18...
        bcc     @done

        ldy     CUR_Y_MIN                               ; ...advance to the next column

        lda     #$12
        sta     CUR_X_MAX
        adc     CUR_X_OFF

        cmp     #$26                                    ; If we were already on the second column...
        bcs     @wait_for_next_page                     ; ...wait for the user, then start a new screen

        sta     CUR_X_OFF
@done:  sty     CUR_Y
        rts

@wait_for_next_page:
        ldx     #$0D                                    ; Print "more" at the bottom of the screen
        ldy     #$12
        jsr     mi_print_text_at_x_y
        .asciiz "more"

        jsr     swap_screens_and_press_space            ; Update the screen, then wait for the user

        lda     #$00                                    ; Reset screen swapping
        sta     BM2_ADDR_MASK

        inc     CUR_X                                   ; Cache the text window
        jsr     mi_store_text_area

        ; continued in set_text_window_ztats



;-----------------------------------------------------------
;                  set_text_window_ztats
;
; Sets the text window so the top-left corner is at (2, 5)
; and make the width 36 x 14. Then, clears the text window.
;-----------------------------------------------------------

set_text_window_ztats:
        lda     #$05
        sta     CUR_Y_MIN
        lsr     a
        sta     CUR_X_OFF
        lda     #$24
        sta     CUR_X_MAX
        lda     #$13
        sta     CUR_Y_MAX
        jmp     st_clear_text_window



;-----------------------------------------------------------
;             print_string_entry_and_short_a
;
; Prints a string entry, followed by padding and a short
; integer value. The address of the string table should
; immediately follow the call to this method. The entry
; to print should be stored in the 'string_entry' variable
; in zero page, and the value should be in the accumulator.
;-----------------------------------------------------------

print_string_entry_and_short_a:
        tax
        lda     #$00

        ; continued in print_string_entry_and_long_ax



;-----------------------------------------------------------
;             print_string_entry_and_long_ax
;
; Prints a string entry, followed by padding and a long
; integer value. The address of the string table should
; immediately follow the call to this method. The entry
; to print should be stored in the 'string_entry' variable
; in zero page, the high byte of the value should be in the
; accumulator, and the low byte in the x register. If the
; value in 'mi_selected_item' matches the value in
; 'string_entry', then the item name will have a dot
; printed next to it.
;-----------------------------------------------------------

print_string_entry_and_long_ax:
        pha                                             ; Push a and x onto the stack
        txa
        pha

        jsr     next_row_or_column                      ; Advance to the next row

        lda     #$03                                    ; Position the cursor
        sta     CUR_X

        ldx     #$09                                    ; Print enough '.'s to fill the row
        lda     #'.'
        sta     mi_number_padding
        jsr     mi_print_x_chars

        pla                                             ; Pull x and a fromt he stack
        tax
        pla

        jsr     print_long_int                          ; Print the value

        jsr     mi_cursor_to_col_0                      ; Move the cursor back to the beginning of the line

        ldx     string_entry
        lda     mi_selected_item                        ; If an item is selected...
        beq     @print_string
        cpx     mi_selected_item                        ; ...and the current item is selected...
        bne     @print_string

        lda     #$1B                                    ; ...print a dot
        jsr     mi_print_char

@print_string:
        jmp     mi_print_string_entry_x                 ; Print the string entry



