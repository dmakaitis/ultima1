.include "kernel.inc"
.include "st.inc"

.export mi_cmd_ztats
.export mi_command_table_override
.export mi_current_attribute
.export mi_s863C

.export bm_addr_mask_cache
.export command_decode_table

.export move_cursor_back_to_last_character

.import mi_cursor_to_col_0
.import mi_player_food
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
.import print_digit
.import print_long_int
.import print_string_entry_x
.import to_decimal_a_x

.import reduce_text_window_size

.import armor_table
.import gem_table
.import mi_attribute_table
.import mi_class_name_table
.import mi_number_padding
.import mi_player_class
.import mi_player_experience
.import mi_player_hits
.import mi_player_money
.import mi_player_race
.import mi_player_sex
.import mi_race_name_table
.import spell_table
.import transport_table
.import weapon_table

.import r81EA
.import mi_w81EE
.import mi_w81EF
.import mi_w81F0
.import mi_w81F1
.import r81F2
.import mi_w81F8
.import r8208
.import mi_w8213
.import r822B
.import w824F
.import w8250
.import w8259

BITMAP_PTR      := $36

dec_lo          := $3C
dec_mid         := $3D
string_entry    := $46

        .setcpu "6502"

.segment        "CODE_ZZZ": absolute

        .byte   $2F,$55,$31,$2E,$50,$4C,$41,$59
        .byte   $45,$52,$2F,$55,$31,$2E,$56,$41
        .byte   $52,$53,$00,$00,$00

bm_addr_mask_cache:
        .byte   $00

mi_current_attribute:
        .byte   $00

w81C5:  .byte   $05
w81C6:  .byte   $50

mi_command_table_override:
        .byte   $00,$00

command_decode_table:
        .byte   $40,$2F,$3B,$3A,$20,$41,$42,$43         ; 25 bytes
        .byte   $44,$45,$46,$47,$48,$49,$4B,$4E
        .byte   $4F,$51,$52,$53,$54,$55,$56,$58
        .byte   $5A



.segment "CODE_ZZZ2"

print_2_digits:
        pha
        lsr     a
        lsr     a
        lsr     a
        lsr     a
        jsr     print_digit
        pla



.segment "CODE_ZZZ3"

        .byte   $A0,$FF,$38,$C8,$E9,$0A,$B0,$FB
        .byte   $98,$60,$85,$43,$20,$70,$16,$C5
        .byte   $43,$90,$04,$E5,$43,$B0,$F8,$C9
        .byte   $00,$85,$43,$60,$20,$73,$16,$A5
        .byte   $56,$60,$20,$77,$87,$A0,$3D,$8C
        .byte   $FC,$85,$20,$D5,$1E,$EA,$EA,$EA
        .byte   $C9,$00,$D0,$08,$20,$A0,$16,$CE
        .byte   $FC,$85,$D0,$EE,$60,$40



.segment "CODE_ZZZ4"

        .byte   $18,$B0



;-----------------------------------------------------------
;                           mi_s863C
;
; Seems to handle reducing food periodically, as well as
; increasing something else related to the player.
;-----------------------------------------------------------

mi_s863C:
        sec                                             ; Set carry flag

        sty     w81C5
        sta     w81C6

        bcc     @check_food_timer                                   ; If carry flag is clear...
        lda     #$00                                    ; ...play "step" sound
        jsr     st_queue_sound

@check_food_timer:
        sed                                             ; Put CPU in decimal mode

        sec
        lda     w8259
        sbc     w81C5
        sta     w8259
        bcs     @increase_something

        lda     mi_player_food                          ; If there is no food left...
        ora     mi_player_food + 1
        beq     @increase_something                     ; ...then do not decrease the food supply

        lda     mi_player_food                          ; Otherwise, decrease food
        bne     @decrease_food_low
        dec     mi_player_food + 1
@decrease_food_low:
        dec     mi_player_food

@increase_something:
        clc
        lda     w824F
        adc     w81C6
        sta     w824F
        bcs     @increase_high_bytes

        cld                                             ; Put CPU back in binary mode

        rts


@increase_high_bytes:
        sed
        sec
        ldx     #$00
@loop_increase:
        lda     w8250,x
        adc     #$00
        sta     w8250,x
        inx
        bcs     @loop_increase

        cld                                             ; Put CPU back in binary mode

        rts



.segment "CODE_ZZZ5"

;-----------------------------------------------------------

        .byte   $AE,$EE,$81,$20,$2D,$84,$88,$78
        .byte   $60

move_cursor_back_to_last_character:
        lda     CUR_Y                                   ; x := 8 * cursor Y coordinate
        asl     a
        asl     a
        asl     a
        tax

@loop_left:
        ldy     CUR_X                                   ; y := cursor X coordinate

        beq     @done                                   ; if y != 0 then we are done.

        dey                                             ; y -= 1

        lda     st_bitmap_y_offset_lo,x                 ; Get bitmap memory address of (CUR_X - 1, CUR_Y)
        clc
        adc     st_bitmap_x_offset_lo,y
        sta     BITMAP_PTR
        lda     st_bitmap_y_offset_hi,x
        eor     BM_ADDR_MASK
        adc     st_bitmap_x_offset_hi,y
        sta     BITMAP_PTR + 1

        ldy     #$07                                    ; See if any text is currently being displayed at CUR_X, CUR_Y
        lda     #$00

@loop_character:
        ora     (BITMAP_PTR),y
        bne     @done                                   ; If something is there, then we are done

        dey
        bpl     @loop_character

        dec     CUR_X                                   ; Move cursor left one and...
        bne     @loop_left                              ; ...if we are not at the left edge keep going

@done:  rts

        .byte   $20,$8E,$84,$7D,$48,$6D,$6D,$6D
        .byte   $6D,$2E,$2E,$2E,$20,$6E,$6F,$20
        .byte   $65,$66,$66,$65,$63,$74,$3F,$00
        .byte   $A9,$08,$D0,$0A




.segment "CODE_ZZZ6"

;-----------------------------------------------------------

        .byte   $20,$0C,$87,$A9,$04,$85,$30,$85
        .byte   $2E,$A9,$10,$85,$31,$A9,$20,$85
        .byte   $2F,$20,$52,$16,$20,$F3,$83,$A9
        .byte   $60,$20,$8B,$16,$20,$C9,$87,$A2
        .byte   $04,$A0,$12,$86,$26,$84,$27,$A2
        .byte   $FA,$20,$91,$16,$A6,$26,$A0,$6D
        .byte   $20,$91,$16,$A2,$04,$A4,$27,$20
        .byte   $91,$16,$A6,$26,$A0,$12,$20,$91
        .byte   $16,$A5,$5C,$45,$5D,$85,$5C,$60
        .byte   $48,$A9,$07,$85,$32,$68,$A2,$03
        .byte   $DD,$F5,$87,$F0,$03,$CA,$D0,$F8
        .byte   $8A,$0A,$A8,$B9,$FA,$87,$48,$B9
        .byte   $F9,$87,$48,$20,$2D,$84,$2E,$88
        .byte   $20,$4F,$16,$E6,$32,$60,$53,$57
        .byte   $41,$F4,$87,$00,$88,$0F,$88,$1E
        .byte   $88,$AD,$EE,$81,$20,$49,$88,$0A
        .byte   $08,$82,$88,$78,$8D,$EE,$81,$60
        .byte   $AD,$EF,$81,$20,$49,$88,$0F,$F8
        .byte   $81,$7C,$77,$8D,$EF,$81,$60,$AD
        .byte   $F0,$81,$20,$49,$88,$05,$F2,$81
        .byte   $D4,$78,$8D,$F0,$81,$60,$6E,$6F
        .byte   $74,$68,$69,$6E,$E7,$73,$70,$65
        .byte   $6C,$6C,$BA,$77,$65,$61,$70,$6F
        .byte   $6E,$BA,$61,$72,$6D,$6F,$75,$72
        .byte   $BA,$85,$46,$68,$8D,$B5,$83,$68
        .byte   $8D,$B6,$83,$20,$AC,$83,$8D,$0B
        .byte   $89,$20,$AC,$83,$85,$41,$20,$AC
        .byte   $83,$85,$42,$20,$AC,$83,$8D,$07
        .byte   $89,$20,$AC,$83,$8D,$08,$89,$AD
        .byte   $B6,$83,$48,$AD,$B5,$83,$48,$20
        .byte   $0C,$87,$20,$5E,$16,$A2,$0E,$A0
        .byte   $00,$A5,$5D,$8D,$C3,$81,$84,$5D
        .byte   $20,$8A,$84,$0E,$20,$52,$65,$61
        .byte   $64,$79,$20,$18,$00,$20,$52,$16
        .byte   $AC,$0B,$89,$A2,$01,$B1,$41,$F0
        .byte   $01,$E8,$88,$D0,$F8,$86,$43,$38
        .byte   $A9,$14,$E5,$43,$4A,$85,$33,$A9
        .byte   $61,$8D,$BF,$88,$A0,$00,$98,$48
        .byte   $A9,$0D,$85,$32,$20,$8E,$84,$61
        .byte   $29,$20,$00,$68,$20,$02,$89,$A8
        .byte   $E6,$33,$CC,$0B,$89,$B0,$0A,$EE
        .byte   $BF,$88,$C8,$B1,$41,$D0,$DF,$F0
        .byte   $F1,$20,$01,$87,$AD,$C3,$81,$85
        .byte   $5D,$20,$64,$16,$20,$76,$16,$48
        .byte   $20,$D6,$8A,$38,$68,$E9,$41,$F0
        .byte   $11,$30,$0C,$CD,$0B,$89,$90,$02
        .byte   $D0,$05,$A8,$B1,$41,$D0,$02,$A4
        .byte   $46,$98,$AA,$48,$20,$26,$84,$00
        .byte   $00,$68,$60,$0A



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
        jsr     print_string_entry_x
        .addr   mi_race_name_table

        inc     CUR_X                                   ; Display character class
        ldx     mi_player_class
        jsr     print_string_entry_x
        .addr   mi_class_name_table

        jsr     set_text_window_ztats                   ; Clear the display for page 1 of the ztats

        dec     CUR_Y                                   ; Display attribute names
        ldx     #$00                                    ; (hits, str, agi, sta, chr, wis, and int)
        stx     mi_current_attribute
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
        lda     r822B
        beq     b8A4F
        ldx     #$00
        stx     string_entry
        jsr     print_string_entry_and_short_a
        .addr   @enemy_vessels_str
b8A4F:  lda     mi_w81F0
        sta     mi_current_attribute
        ldx     #$01
b8A57:  stx     string_entry
        lda     r81F2,x
        beq     b8A63
        jsr     print_string_entry_and_short_a
        .addr   armor_table
b8A63:  ldx     string_entry
        inx
        cpx     #$06
        bcc     b8A57
        lda     mi_w81F1
        sta     mi_current_attribute
        ldx     #$01
b8A72:  stx     string_entry
        lda     mi_w8213,x
        beq     b8A7E
        jsr     print_string_entry_and_short_a
        .addr   transport_table
b8A7E:  ldx     string_entry
        inx
        cpx     #$0B
        bcc     b8A72
        ldx     #$00
        stx     mi_current_attribute
b8A8A:  stx     string_entry
        lda     r81EA,x
        beq     b8A96
        jsr     print_string_entry_and_short_a
        .addr   gem_table
b8A96:  ldx     string_entry
        inx
        cpx     #$04
        bcc     b8A8A
        lda     mi_w81EF
        sta     mi_current_attribute
        ldx     #$01
b8AA5:  stx     string_entry
        lda     mi_w81F8,x
        beq     b8AB1
        jsr     print_string_entry_and_short_a
        .addr   weapon_table
b8AB1:  ldx     string_entry
        inx
        cpx     #$10
        bcc     b8AA5
        lda     mi_w81EE
        sta     mi_current_attribute
        ldx     #$01
b8AC0:  stx     string_entry
        lda     r8208,x
        beq     b8ACC
        jsr     print_string_entry_and_short_a
        .addr   spell_table
b8ACC:  ldx     string_entry
        inx
        cpx     #$0B
        bcc     b8AC0
        jsr     swap_screens_and_press_space
        jsr     draw_border
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
        bcs     b8AF8                                   ; ...wait for the user, then start a new screen

        sta     CUR_X_OFF
@done:  sty     CUR_Y
        rts

b8AF8:  ldx     #$0D                                    ; Print "more" at the bottom of the screen
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



;-----------------------------------------------------------
;             print_string_entry_and_long_ax
;
; Prints a string entry, followed by padding and a long
; integer value. The address of the string table should
; immediately follow the call to this method. The entry
; to print should be stored in the 'string_entry' variable
; in zero page, the high byte of the value should be in the
; accumulator, and the low byte in the x register.
;-----------------------------------------------------------

print_string_entry_and_long_ax:
        pha
        txa
        pha
        jsr     next_row_or_column
        lda     #$03
        sta     CUR_X
        ldx     #$09
        lda     #$2E
        sta     mi_number_padding
        jsr     mi_print_x_chars
        pla
        tax
        pla
        jsr     print_long_int
        jsr     mi_cursor_to_col_0
        ldx     string_entry
        lda     mi_current_attribute
        beq     b8B53
        cpx     mi_current_attribute
        bne     b8B53
        lda     #$1B
        jsr     mi_print_char
b8B53:  jmp     mi_print_string_entry_x



;-----------------------------------------------------------
;               swap_screens_and_press_space
;
; Swaps the bitmap screens, then waits for the user to
; press space to continue.
;-----------------------------------------------------------

swap_screens_and_press_space:
        lda     bm_addr_mask_cache
        sta     BM2_ADDR_MASK
        jsr     st_swap_bitmaps
        jsr     st_copy_screen_2_to_1
        jsr     mi_restore_text_area

        ; continued in press_space_to_continue



.segment "CODE_ZZZ7"

        .byte   $60,$20,$8E,$84,$20,$6F,$66,$66
        .byte   $00,$60,$AD,$38,$16,$49,$FF,$8D
        .byte   $38,$16,$8D,$E7,$81,$F0,$EA,$20
        .byte   $8E,$84,$20,$6F,$6E,$00,$60
