.include "mi.inc"
.include "st.inc"
.include "hello.inc"

.export cmd_attack
.export cmd_board
.export cmd_cast
.export cmd_east
.export cmd_enter
.export cmd_fire
.export cmd_inform_search
.export cmd_north
.export cmd_pass
.export cmd_quit_save
.export cmd_ready
.export cmd_south
.export cmd_west
.export cmd_xit

.import command_routine_table
.import tile_descriptions
.import blocked_messages
.import signpost_text
.import world_signposts
.import signpost_attributes
.import signpost_quests
.import weapon_ranges
.import total_player_vechicles
.import signpost_cache
.import tile_cache
.import wA144
.import wA145

r3888                   := $3888
continent_map           := $6400
continent_addresses     := $B000
mob_hit_points          := $BD00

PROCESSOR_PORT          := $01
POS_X                   := $20
POS_Y                   := $21
zp22                    := $22
zp23                    := $23
zp24                    := $24
zp25                    := $25
DRAW_START_X            := $26
DRAW_START_Y            := $27
DRAW_END_X              := $28
DRAW_END_Y              := $29
zp2C                    := $2C
zp2D                    := $2D
zp36                    := $36
zp37                    := $37
zp38                    := $38
zp39                    := $39
zp3A                    := $3A
zp3C                    := $3C
zp3D                    := $3D
zp3F                    := $3F
zp43                    := $43
zp_mob_index            := $44
zp46                    := $46
zp47                    := $47
zp48                    := $48
zp49                    := $49
zp4C                    := $4C
zp4D                    := $4D
TMP_PTR                 := $60
TMP_PTR2                := $62

.segment "ZZZ"

;-----------------------------------------------------------
;-----------------------------------------------------------

ou_main:
        lda     #$30                                    ; Expose all RAM
        sta     PROCESSOR_PORT

        ldx     #$0D                                    ; Copy 3328 bytes from $D000-$DCFF to $B000-$BCFF
        lda     #$00
        sta     TMP_PTR
        sta     TMP_PTR2
        lda     #$D0
        sta     TMP_PTR + 1
        lda     #$B0
        sta     TMP_PTR2 + 1
        ldy     #$00

@loop_copy:
        lda     (TMP_PTR),y
        sta     (TMP_PTR2),y
        iny
        bne     @loop_copy
        inc     TMP_PTR + 1
        inc     TMP_PTR2 + 1
        dex
        bne     @loop_copy

        lda     #$36                                    ; Enable I/O and KERNAL areas
        sta     PROCESSOR_PORT


        lda     #$C1                                    ; Configure input options (fire = 'A')
        sta     st_joystick_fire_key_equiv
        lda     #$02
        sta     st_key_repeat_rate_10ths

        lda     mi_player_position_x                    ; Copy player location into zero-page variables
        sta     POS_X
        lda     mi_player_position_y
        sta     POS_Y

        lda     #$60                                    ; Set up screen swapping
        sta     BM2_ADDR_MASK
        sta     BM_ADDR_MASK
        jsr     st_copy_screen_2_to_1

        ldx     #$00                                    ; Use the default command table
        stx     mi_command_table_override + 1

        lda     mob_hit_points
        bne     b8CF0
        jsr     s9A10
b8CF0:  jsr     decompress_continent_map

        lda     mi_player_hits                          ; If the player has no hit points...
        ora     mi_player_hits + 1
        beq     no_hits                                 ; ...then they are dead



main_loop:
        ldx     #$FF                                    ; Reset stack
        txs

        jsr     mi_print_text                           ; Prompt for input
        .byte   "|",$0E,$00

        jsr     set_avatar_vehicle_tile                 ; Make sure correct vehicle is displayed for the player

b8D07:  jsr     mi_update_stats                         ; Update the display with player stats

        lda     mi_player_hits                          ; If the player has no hit points...
        ora     mi_player_hits + 1
        beq     no_food_or_hits
        lda     mi_player_food                          ; ...or food...
        ora     mi_player_food + 1
        beq     no_food_or_hits                         ; ...then they are dead

        jsr     read_key
        bne     b8D31
        ldy     #$05
        lda     #$50
        jsr     mi_s863C
        jsr     s9A2F
        lda     CUR_X
        cmp     #$02
        bcc     b8D07
        bcs     main_loop


b8D31:  jsr     mi_decode_and_print_command_a
        bcs     b8D45
        lda     command_routine_table,x
        sta     w8D43
        lda     command_routine_table + 1,x
        sta     w8D44
w8D43           := * + 1
w8D44           := * + 2
        jsr     mi_do_nothing
b8D45:  jsr     s9A2F
        jmp     main_loop


no_food_or_hits:
        jsr     mi_player_died                          ; Inform the player they are dead

no_hits:
        ldx     #$0A                                    ; Delay for a time period
@delay: jsr     st_delay_a_squared
        dex
        bpl     @delay

        jsr     s97E0
        stx     POS_X
        sty     POS_Y
        jsr     s9A10
        lda     #$00
        ldx     mi_player_current_vehicle
        beq     b8D72
        sta     mi_player_current_vehicle
        ldy     mi_player_inventory_vehicles,x
        beq     b8D72
        dec     mi_player_inventory_vehicles,x
b8D72:  ldx     #$0F
b8D74:  sta     mi_player_inventory_weapons,x
        dex
        bne     b8D74
        sta     mi_player_equipped_armor
        sta     mi_player_equipped_weapon
        sta     mi_player_equipped_spell
        jsr     mi_print_text
        .asciiz "~Attempting resurrection!"
b8DA0:  inc     mi_player_hits
        jsr     update_stats_and_delay
        lda     mi_player_hits
        cmp     #$63
        bcc     b8DA0
b8DAD:  inc     mi_player_food
        jsr     update_stats_and_delay
        lda     mi_player_food
        cmp     #$63
        bcc     b8DAD
        jsr     mi_reset_buffers
        lda     #$0A
        jsr     st_queue_sound
        jmp     main_loop



;-----------------------------------------------------------
;                  update_stats_and_delay
;
; Updates the screen with player stats, then delays for a
; fixed time period.
;
; Input:
;
; Output:
;-----------------------------------------------------------

update_stats_and_delay:
        jsr     mi_update_stats
        lda     #$68
        jsr     st_delay_a_squared
        jmp     st_wait_for_raster



;-----------------------------------------------------------
;                         read_key
;
; Waits for keyboard input from the user. Returns if no key
; is pressed for 128 screen update cycles (about 2 seconds).
;
; Input:
;
; Output:
;    a - the key pressed by the user, or 0 if no key was
;        pressed.
;-----------------------------------------------------------

read_key:
        ldx     #$80
@loop:  jsr     st_draw_world_and_get_input
        bne     @done
        dex
        bne     @loop
@done:  tax
        rts



;-----------------------------------------------------------
;-----------------------------------------------------------

cmd_pass:
        ldy     #$05
        lda     #$50
        jmp     mi_j863A

        .byte   $A9,$00,$85,$4C,$A5,$23,$4A,$66
        .byte   $4C,$4A,$66,$4C,$69,$64,$85,$4D
        .byte   $A4,$22,$60



;-----------------------------------------------------------
;                      read_direction
;
; Waits for the user to press a direction key and returns 
; the entered direction.
;
; Input:
;
; Output:
;    carry - set if no valid direction was entered
;    zp22  - player x coordinate
;    zp23  - player y coordinate
;    zp24  - target x vector
;    zp25  - target y vector
;-----------------------------------------------------------

read_direction:
        jsr     mi_print_text
        .asciiz ": "

        jsr     read_key

        ldx     #$03                                    ; Check which direction key was pressed
@loop:  cmp     mi_command_decode_table,x
        bne     @next_x

        stx     zp24                                    ; Cache the direction

        jsr     mi_print_string_entry_x2                ; Print the selected direction
        .addr   mi_command_table

        ldx     POS_X                                   ; Cache the player location
        ldy     POS_Y
        stx     zp22
        sty     zp23

        ldx     #$00
        ldy     #$00

        dec     zp24                                    ; North?
        bmi     @is_north

        dec     zp24                                    ; South?
        bmi     @is_south

        dec     zp24                                    ; East?
        bmi     @is_east

        dex                                             ; Must be west

@store_target_direction:
        stx     zp24
        sty     zp25
        clc
        rts

@is_north:
        dey
        bne     @store_target_direction

@is_south:
        iny
        bne     @store_target_direction

@is_east:
        inx
        bne     @store_target_direction

@next_x:
        dex
        bpl     @loop

        jsr     mi_print_first_string_entry             ; Print "nothing"
        .addr   mi_r882E

        sec
        rts



;-----------------------------------------------------------
;                        get_target
;
; Gets the target of an action given a starting coordinate,
; direction, and range.
;
; Input:
;    zp22  - start x coordinate
;    zp23  - start y coordinate
;    zp24  - target x vector
;    zp25  - target y vector
;    wA145 - range
;
; Output:
;    a     - target tile
;    carry - set if no target was found
;-----------------------------------------------------------

get_target:
        lda     zp22                                    ; Update target X coordinate
        clc
        adc     zp24
        sta     zp22
        tax

        lda     zp23                                    ; Update target Y coordinate
        clc
        adc     zp25
        sta     zp23
        tay

        jsr     get_tile
        cmp     #$03
        beq     @done

        jsr     get_target_mob
        bcc     @done

        dec     wA145                                   ; Loop until we're out of range
        bne     get_target
        sec

@done:  rts



;-----------------------------------------------------------
;                      get_target_mob
;
; Retrieves information about the target mob.
;
; Input:
;    zp22  - target x coordinate
;    zp23  - target y coordinate
;
; Output:
;    a                      - target tile
;    y                      - the x coordinate of the target
;    carry                  - set if no target was found
;    mi_player_target_type  - the target mob type
;    mi_player_target_index - the index of the target mob
;    zp4C                   - Address of the world map row 
;                             where the target is located
;-----------------------------------------------------------

get_target_mob:
        ldx     mi_player_mob_count
        beq     @done

@loop:  dex

        lda     mi_player_mob_x_coords,x
        cmp     zp22
        bne     @next_x

        lda     mi_player_mob_continent_y_coords,x
        and     #$3F
        cmp     zp23
        bne     @next_x

        lda     mi_player_mob_types,x                   ; Make sure mob type is between 0x20 and 0x5a
        cmp     #$20
        bcc     @next_x        
        cmp     #$5A
        bcs     @next_x

        lsr     a                                       ; Store the target type and index
        lsr     a
        adc     #$FE
        sta     mi_player_target_type
        stx     zp_mob_index
        stx     mi_player_target_index

        jsr     get_mob_location_in_memory              ; Retrieve mob location on map in memory
        clc
        rts

@next_x:
        txa
        bne     @loop

@done:  sec
        rts



;-----------------------------------------------------------
;                         cmd_attack
;
; Handler for the attack command.
;
; Input:
;
; Output:
;-----------------------------------------------------------

cmd_attack:
        jsr     mi_print_text                           ; Write the weapon used to attack
        .asciiz "with "

        ldx     mi_player_equipped_weapon
        jsr     mi_print_string_entry_x2
        .addr   mi_weapon_abbr_table

        ldx     mi_player_equipped_weapon
        lda     weapon_ranges,x
        bne     @valid_weapon
        jmp     mi_cmd_invalid



@valid_weapon:
        sta     wA145                                   ; Get direction from user
        jsr     read_direction
        bcc     @valid_direction
        rts



@no_target:
        jsr     mi_print_text                           ; Tell the user they missed
        .asciiz "~Miss!"
        rts



@valid_direction:
        lda     #$06
        jsr     st_queue_sound

        jsr     get_target
        bcs     @no_target

        lda     #$5E                                    ; Draw attack icon on target
        sta     (zp4C),y
        jsr     st_draw_world

        jsr     get_cached_mob_location_in_memory       ; Restore mob icon on target
        lda     mi_player_mob_types,x
        sta     (zp4C),y

        lda     mi_player_agility                       ; Check random number against 128 + player agility
        clc                                             ; to see if they hit or miss
        adc     #$80
        sta     zp43
        jsr     st_get_random_number
        cmp     zp43
        bcc     @is_hit

        jsr     mi_print_text
        .asciiz "~Missed"

        jmp     print_target_name

@is_hit:
        lda     mi_player_equipped_weapon               ; Get random number in range of 1 to 
        asl     a                                       ; (8 * wpn_id + strength / 2) + 1
        asl     a                                       ; to determine damage
        asl     a
        adc     mi_player_strength
        jsr     mi_get_random_number_a
        lsr     a
        clc
        adc     #$01

do_damage_to_target:
        sta     mi_w81C1

        lda     #$00
        sta     mi_number_padding

        ldx     zp_mob_index
        lda     mob_hit_points,x
        sec
        sbc     mi_w81C1
        beq     do_target_killed
        bcc     do_target_killed
        sta     mob_hit_points,x

        jsr     mi_print_text                           ; Tell the player that they hit the target
        .asciiz "~Hit"

        jsr     print_target_name

        lda     CUR_X                                   ; If the cursor is too far to the right, skip to the next line
        cmp     #$15
        bcc     @print_damage
        jsr     mi_print_crlf_col_1

@print_damage:
        lda     mi_w81C1                                ; Print the amount of damage done
        jsr     mi_print_short_int
        jsr     mi_print_text
        .asciiz " damage"

        ; continued in play_hit_target_sound



;-----------------------------------------------------------
;                    play_hit_target_sound
;
; Handler for the attack command.
;
; Input:
;
; Output:
;-----------------------------------------------------------

play_hit_target_sound:
        lda     #$02                                    ; Play hit target sound and return
        jmp     st_play_sound_a



do_target_killed:
        jsr     mi_print_text                           ; Tell the player that they killed their target
        .asciiz "~Killed"

        jsr     print_target_name
        jsr     play_hit_target_sound

        ldx     mi_player_target_type                   ; x := mob type
        ldy     mi_mob_treasure_table,x                 ; y := potential treasure
        lda     mob_data_table,y                        ; a := experience
        lsr     a

        cmp     #$02                                    ; Generate random number based on experience table
        bcc     @update_player_xp
        jsr     mi_get_random_number_a

@update_player_xp:
        adc     mi_player_experience                    ; Grant the player experience points
        sta     mi_player_experience
        bcc     @calculate_treasure
        inc     mi_player_experience + 1

@calculate_treasure:
        tya                                             ; Generate random treasure in range of 10 + (0 -> 4 * treasure)
        asl     a
        asl     a
        jsr     mi_get_random_number_a
        clc
        adc     #$0A

        pha                                             ; Print the treasure amount for the user
        tax
        lda     #$00
        jsr     mi_to_decimal_a_x
        lda     zp3C
        and     #$0F
        beq     @print_silver
        jsr     print_digit_and_text
        .asciiz "copper! "

@print_silver:
        lda     zp3C
        lsr     a
        lsr     a
        lsr     a
        lsr     a
        beq     @print_gold
        jsr     print_digit_and_text
        .asciiz "silver! "

@print_gold:
        lda     zp3D
        beq     @update_player_money
        jsr     print_digit_and_text
        .asciiz "gold!"

@update_player_money:
        pla
        clc
        adc     mi_player_money
        sta     mi_player_money
        bcc     @done
        inc     mi_player_money + 1

@done:  jsr     s9024
        jmp     remove_player_target



;-----------------------------------------------------------
;                   print_digit_and_text
;
; Prints the digit stored in the accumulator followed by
; the text immediately following the call to this method.
;
; Input:
;    a - the digit to print
;
; Output:
;-----------------------------------------------------------

print_digit_and_text:
        pha
        lda     CUR_X
        cmp     #$15
        bcc     b8FDE
        jsr     mi_print_crlf_col_1
b8FDE:  pla
        jsr     mi_print_digit
        inc     CUR_X
        jmp     mi_print_text



;-----------------------------------------------------------
;                     print_target_name
;
; Prints the name of the player's target preceeded by the
; word "the" and followed by an exclamation point.
;
; Input:
;
; Output:
;-----------------------------------------------------------

print_target_name:
        jsr     mi_print_text
        .asciiz " the "

        ldx     mi_player_target_type
        jsr     mi_print_string_entry_x2
        .addr   mi_world_monster_table

        jsr     mi_print_text
        .asciiz "! "

        rts



remove_player_target:
        ldx     mi_player_target_index
        cpx     mi_player_mob_count
        bcs     b9022
        lda     mi_player_mob_types,x
        cmp     #$20
        bcc     b9022
        cmp     #$5A
        bcs     b9022
        jsr     remove_player_vehicle_x
        ldx     #$00
        stx     mi_player_target_type
        stx     zp_mob_index
        dex
        stx     mi_player_target_index
        clc
        rts

b9022:  sec
        rts



;-----------------------------------------------------------
;-----------------------------------------------------------

s9024:  lda     mi_player_experience
        cmp     #$10
        lda     mi_player_experience + 1
        sbc     #$27
        bcc     b903A
        lda     #$0F
        sta     mi_player_experience
        lda     #$27
        sta     mi_player_experience + 1
b903A:  lda     mi_player_money
        cmp     #$10
        lda     mi_player_money + 1
        sbc     #$27
        bcc     b9050
        lda     #$0F
        sta     mi_player_money
        lda     #$27
        sta     mi_player_money + 1
b9050:  jmp     mi_update_stats



;-----------------------------------------------------------
;                        cmd_board
;
; Command handler for when the player wishes to board a
; vehicle.
;
; Input:
;
; Output:
;-----------------------------------------------------------

cmd_board:
        lda     mi_player_current_vehicle               ; If the player is already in a vehicle...
        beq     @not_in_vehicle
        jsr     mi_cursor_to_col_1                      ; ...then they have to get out first.
        jsr     mi_print_text
        .asciiz "X-it thy craft first!"

        jmp     mi_play_error_sound_and_reset_buffers

@not_in_vehicle:
        jsr     get_player_position_and_tile            ; Get the tile under the player

        cmp     #$10                                    ; If there is no vehicle currently at the player location...
        bcs     @no_vehicle_found
        cmp     #$08
        bcs     @vehicle_found
@no_vehicle_found:
        jsr     mi_cursor_to_col_1                      ; ...then there is nothing for them to board here
        jsr     mi_print_text
        .asciiz "nothing to Board!"
        jmp     mi_play_error_sound_and_reset_buffers



@vehicle_found:
        and     #$07                                    ; If the tile is a time machine...
        cmp     #$07
        bcc     @update_player_vehicle

        lda     #$0A                                    ; ...then override the vehicle to be a time machine

@update_player_vehicle:
        sta     mi_player_current_vehicle
        pha

        jsr     remove_vehicle_at_player_location       ; Remove the vehicle from the world map

        jsr     set_avatar_vehicle_tile
        jsr     st_draw_world

        pla

        cmp     #$03                                    ; If the vehicle is a horse or cart, print that the player is mounting it
        bcs     @print_vehicle_name
        jsr     mi_cursor_to_col_1
        jsr     mi_print_text
        .asciiz "Mount "

@print_vehicle_name:
        jsr     print_current_vehicle                   ; Print the vehicle name

        lda     mi_player_current_vehicle
        cmp     #$06
        beq     @board_space_shuttle
        bcs     @board_time_machine
        rts

@board_space_shuttle:
        lda     #$0F                                    ; Change keyboard repeat rate and...
        sta     st_key_repeat_rate_10ths
        lda     #$05                                    ; ...load the SP module
@load_module:
        jmp     load_module_a

@board_time_machine:
        lda     mi_player_gems                          ; Check if the player has all gems
        beq     @missing_gem
        lda     mi_player_gems + 1
        beq     @missing_gem
        lda     mi_player_gems + 2
        beq     @missing_gem
        lda     mi_player_gems + 3
        beq     @missing_gem

        lda     #$06                                    ; Load the TM module
        bne     @load_module

@missing_gem:
        jsr     mi_store_text_area                      ; Describe the time machine
        jsr     st_clear_main_viewport
        jsr     st_set_text_window_main
        sta     BM2_ADDR_MASK
        jsr     mi_reduce_text_window_size
        jsr     mi_print_text
        .byte   "||||",$7F
        .byte   $03,"Entering the craft, thou dost|",$7F
        .byte   $03,"remark upon four holes marked:||",$7F
        .byte   $0D,"o  o  o  o|",$7F
        .byte   $0D,"R  G  B  W||"
        .byte   $00

        lda     mi_player_gems                          ; Does the player have ANY gems?
        ora     mi_player_gems + 1
        ora     mi_player_gems + 2
        ora     mi_player_gems + 3
        bne     do_describe_missing_gems

        jsr     mi_print_text                           ; The player has no gems, so give no hints
        .byte   $7F
        .byte   $02,"Thou canst not determine how to|",$7F
        .byte   $02,"operate the craft at this time."
        .byte   $00



;-----------------------------------------------------------
;-----------------------------------------------------------

s91BB:  lda     #$60
        sta     BM2_ADDR_MASK
        jsr     st_swap_bitmaps
        jsr     mi_restore_text_area
        jsr     mi_reset_buffers_and_wait_for_input
        jmp     mi_wait_for_input



;-----------------------------------------------------------
;                 do_describe_missing_gems
;
;
; Input:
;
; Output:
;-----------------------------------------------------------

do_describe_missing_gems:
        lda     mi_player_gems                          ; If the player has a red gem, draw it
        beq     @no_red_gems
        ldx     #$59                                    ; x := 89
        lda     #$20                                    ; Red
        jsr     draw_gem_a_x

@no_red_gems:
        lda     mi_player_gems + 1                      ; If the player has a green gem, draw it
        beq     @no_green_gems
        ldx     #$71                                    ; x := 113
        lda     #$50                                    ; Green
        jsr     draw_gem_a_x

@no_green_gems:
        lda     mi_player_gems + 2                      ; If the player has a blue gem, draw it
        beq     @no_blue_gems
        ldx     #$89                                    ; x := 137
        lda     #$60                                    ; Blue
        jsr     draw_gem_a_x

@no_blue_gems:
        lda     mi_player_gems + 3                      ; If the player has a white gem, draw it
        beq     @no_white_gems
        ldx     #$A1                                    ; x := 161
        lda     #$10                                    ; White
        jsr     draw_gem_a_x

@no_white_gems:
        jsr     mi_print_text                           ; Tell the player they're missing some gems
        .byte   $7F,$05,"Thou hast not all the gems|"
        .byte   $7F,$04,"needed to operate thy craft!"
        .byte   $00

        jmp     s91BB



;-----------------------------------------------------------
;                      draw_gem_a_x
;
; Draws a gem of the given color at the given location. Gems
; are drawn as a 4x6 colored square.
;
; Input:
;    a - color
;    x - x coordinate
;
; Output:
;-----------------------------------------------------------

draw_gem_a_x:
        stx     zp46                                    ; zp46 := x

        inx                                             ; x += 4
        inx
        inx
        inx

        stx     zp47                                    ; zp47 := x

        ldy     #$39                                    ; DRAW_START_Y := 57
        sty     DRAW_START_Y
        jsr     st_set_draw_color
        jsr     draw_three_gem_lines

        ; continued in draw_three_gem_lines below


;-----------------------------------------------------------
;-----------------------------------------------------------

draw_three_gem_lines:
        jsr     draw_gem_line
        jsr     draw_gem_line

        ; continued in draw_gem_line below



;-----------------------------------------------------------
;-----------------------------------------------------------

draw_gem_line:
        ldx     zp46                                    ; DRAW_START_X := zp46
        stx     DRAW_START_X
        ldx     zp47                                    ; x := zp47
        inc     DRAW_START_Y                            ; DRAW_START_Y++
        ldy     DRAW_START_Y                            ; y := DRAW_START_Y
        jmp     st_draw_line_x_y



;-----------------------------------------------------------
;                      load_module_a
;
; Stores the player outdoor data into a cache at $D000, then
; loads the module specified in the accumulator.
;
; Input:
;    a - the module to load.
;
; Output:
;-----------------------------------------------------------

load_module_a:
        ldx     POS_X                                   ; Store player position
        ldy     POS_Y
        stx     mi_player_position_x
        sty     mi_player_position_y

        pha

        lda     #$30
        sta     PROCESSOR_PORT

        ldx     #$0D                                    ; Set temp pointers to $B000 and $D000
        lda     #$00
        sta     TMP_PTR
        sta     TMP_PTR2

        lda     #$B0
        sta     TMP_PTR + 1
        lda     #$D0
        sta     TMP_PTR2 + 1

        ldy     #$00                                    ; Copy from $B000 to $D000
@loop:  lda     (TMP_PTR),y
        sta     (TMP_PTR2),y
        iny
        bne     @loop
        inc     TMP_PTR + 1
        inc     TMP_PTR2 + 1
        dex
        bne     @loop

        lda     #$36
        sta     PROCESSOR_PORT

        pla

        jmp     mi_load_module_a



;-----------------------------------------------------------
;                       cmd_cast
;
; Handler for the cast spell command.
;
; Input:
;
; Output:
;-----------------------------------------------------------

cmd_cast:
        jsr     mi_print_equipped_spell

        ldx     mi_player_equipped_spell                ; Is the player casting Prayer?
        bne     @check_spell_inventory

        jmp     @cast_prayer



@check_spell_inventory:
        lda     mi_player_inventory_spells,x            ; Does the player have the spell in inventory?
        bne     @has_spell

        jsr     mi_print_text
        .asciiz "~You've used up that spell!"
        jmp     mi_spell_failed



@has_spell:
        cpx     #$03                                    ; Are they casting Magic Missile?
        beq     @not_dungeon_spell
        cpx     #$0A                                    ; ...or are they casting Kill?
        beq     @not_dungeon_spell

        dec     mi_player_inventory_spells,x

        jsr     mi_print_text
        .asciiz "~Failed, dungeon spell only!"
        jmp     mi_spell_failed



@not_dungeon_spell:
        jsr     read_direction                          ; Get the direction from the player
        bcc     @do_cast_spell
        jmp     main_loop                               ; If no direction picked, cancel



@do_cast_spell:
        lda     #$0A                                    ; Play the cast spell sound
        jsr     st_queue_sound

        ldx     mi_player_equipped_spell                ; Update spell inventory
        dec     mi_player_inventory_spells,x

        cpx     #$0A                                    ; Print the appropriate spell incantation
        ldx     #$00
        bcc     @print_incantation
        inx
@print_incantation:
        jsr     mi_print_string_entry_x2
        .addr   @spell_incantations

        ldx     #$03
        stx     wA145

        dex                                             ; Is the player a cleric?
        cpx     mi_player_class
        beq     @spell_hit

        lda     #$80                                    ; Use player's wisdom to check if they hit (roll under 128 + wisdom)
        clc
        adc     mi_player_wisdom
        sta     zp43
        jsr     st_get_random_number
        cmp     zp43
        bcc     @spell_hit

        jsr     mi_print_text
        .asciiz "Failed!"

@spell_failed:
        jsr     mi_spell_failed
        jmp     main_loop



@spell_missed:
        jsr     mi_print_text
        .asciiz "Miss!"
        jmp     @spell_failed



@spell_hit:
        jsr     get_target                              ; Is there a valid target?
        bcs     @spell_missed

        lda     #$5C                                    ; Display spell hit icon on target
        sta     (zp4C),y
        jsr     st_draw_world

        jsr     get_cached_mob_location_in_memory       ; Restore mob icon on target
        lda     mi_player_mob_types,x
        sta     (zp4C),y

        lda     mi_player_equipped_spell                ; Did they cast kill or magic missle?
        cmp     #$03
        beq     @hit_with_magic_missile

        lda     #$FF                                    ; Kill always hits for 255 damage...
        jmp     do_damage_to_target



@hit_with_magic_missile:
        lda     mi_player_intelligence                  ; Roll random number in range of (1..int)
        jsr     mi_get_random_number_a                  ; (result stored in zp43)
        inc     zp43

        lda     zp43

        ldx     mi_player_equipped_weapon               ; Is the current weapon an amulet, wand, staff, or triangle?
        cpx     #$08
        bcc     @do_damage
        cpx     #$0C
        bcs     @do_damage

        asl     a                                       ; Double the damage

        cpx     #$09                                    ; If the weapon is not a wand...
        beq     @do_damage

        clc                                             ; Add the random number again (total of triple damage)
        adc     zp43

        cpx     #$08                                    ; Is the weapon an amulet?
        bne     @do_damage

        lsr     a                                       ; Double the damage again (total of six times damage)

@do_damage:
        jmp     do_damage_to_target



@spell_incantations:
        .byte   "~",$22,"DELCIO-ERE-UI!",$22,$A0
        .byte   "~",$22,"INTERFICIO-NUNC!",$22,$A0



@cast_prayer:
        jsr     mi_print_text
        .byte   "~",$22,"POTENTIS-LAUDIS!",$22,$00

        lda     #$0A                                    ; Spell spell casting sound
        jsr     st_queue_sound

        ldy     #$0F                                    ; If the player has less than 15 hitpoints...
        lda     mi_player_hits + 1
        bne     @check_food
        cpy     mi_player_hits
        bcc     @check_food
        beq     @check_food

        sty     mi_player_hits                          ; ...set their hitpoints to 15

@shazam:
        jsr     mi_print_text
        .asciiz " Shazam!"

        rts

@check_food:
        lda     mi_player_food + 1                      ; If the player has less than 15 food...
        bne     @attempt_remove_monster
        cpy     mi_player_food
        bcc     @attempt_remove_monster
        beq     @attempt_remove_monster

        sty     mi_player_food                          ; ...set their food to 15

        bne     @shazam

@attempt_remove_monster:
        jsr     st_get_random_number                    ; 25% chance to work...
        and     #$03
        bne     @no_effect

        jsr     remove_player_target                    ; Remove the target the player last attacked, if they still exist
        bcs     @no_effect

        jsr     mi_print_text
        .asciiz "~Monster removed!"

        rts



@no_effect:
        jmp     mi_no_effect



;-----------------------------------------------------------
;                 get_new_vehicle_tile_x_y
;
; Retrieves the tile at the given location if a new vehicle
; can be placed there, or return #$FF if a new vehicle can
; not be placed there.
;
; Input:
;    x - continent x position
;    y - continent y position
;
; Output:
;    a - tile type at position, or #$FF if a vehicle can not
;        be placed at the location.
;-----------------------------------------------------------

get_new_vehicle_tile_x_y:
        lda     total_player_vechicles                  ; Can the player own any more vehicles?
        cmp     #$35
        bcs     @invalid_location

        jsr     get_tile                                ; Is the tile water or grass?
        cmp     #$03
        bcs     @invalid_location
        inc     total_player_vechicles
        rts

@invalid_location:
        lda     #$FF
        rts



invalid_enter_target:
        jmp     mi_cmd_invalid



;-----------------------------------------------------------
;                          cmd_enter
;
; Handler for the Enter command.
;
; Input:
;
; Output:
;-----------------------------------------------------------

cmd_enter:
        ldx     POS_X                                   ; Store player position
        ldy     POS_Y
        stx     mi_player_position_x
        sty     mi_player_position_y

        jsr     get_player_position_and_tile            ; Get tile at current player location

        cmp     #$04                                    ; Can the tile be entered (only tiles 4-7)?
        bcc     invalid_enter_target
        cmp     #$08
        bcs     invalid_enter_target

        jsr     mi_print_text                           ; Tell the player what they're entering
        .asciiz "ing..."

        jsr     cmd_inform_search                       ; Display the name of the current location

        lda     tile_cache                              ; Is the tile a signpost?
        cmp     #$05
        bne     @check_castle

        lda     mi_player_world_feature                 ; Figure out which signpost
        ldx     #$07
@signpost_loop:
        cmp     world_signposts,x
        beq     @enter_signpost
        dex
        bpl     @signpost_loop
        rts

@check_castle:
        cmp     #$04                                    ; Is the tile a castle?
        bne     @check_towne

        lda     #$01                                    ; Change keyboard repeat rate
        sta     st_key_repeat_rate_10ths
        lda     #$04                                    ; Load the CA module
        bne     @load_module

@check_towne:
        cmp     #$06                                    ; Is the tile a towne?
        bne     @load_dungeon

        jsr     update_player_vehicle_counters

        ldx     POS_X                                   ; Look up the tiles at locations where new vehicles could potentially be placed
        ldy     POS_Y
        dey
        jsr     get_new_vehicle_tile_x_y
        sta     mi_player_new_vehicle_north
        iny
        dex
        jsr     get_new_vehicle_tile_x_y
        sta     mi_player_new_vehicle_west
        inx
        inx
        jsr     get_new_vehicle_tile_x_y
        sta     mi_player_new_vehicle_east
        dex
        iny
        jsr     get_new_vehicle_tile_x_y
        sta     mi_player_new_vehicle_south

        lda     #$01                                    ; Change keyboard repeat rate
        sta     st_key_repeat_rate_10ths
        lda     #$03                                    ; Load the TW module
        bne     @load_module

@load_dungeon:
        lda     #$02                                    ; Load the DN module
@load_module:
        jmp     load_module_a



@enter_signpost:
        stx     signpost_cache
        jsr     mi_set_main_view_text_area
        ldx     signpost_cache

        jsr     mi_print_string_entry_x2
        .addr   signpost_text

        jsr     mi_restore_text_area
        jsr     mi_reset_buffers

        ldx     signpost_cache                          ; Is there a possible quest for this signpost?
        ldy     signpost_quests,x
        bmi     @no_signpost_quest

        lda     mi_player_signpost_quests,y             ; Is the player currently on this quest?
        beq     @no_signpost_quest
        bmi     @no_signpost_quest

        lda     #$FF                                    ; If so, flag the quest as completed
        sta     mi_player_signpost_quests,y

        jsr     mi_print_text                           ; Let the player know
        .asciiz "}A Quest is completed!"
        jsr     flash_main_view_text_border

@no_signpost_quest:
        ldx     signpost_cache
        lda     signpost_attributes,x
        bne     @raise_attribute
        cpx     #$04
        bne     @done
        cpx     mi_player_last_signpost
        beq     @no_effect

        ldx     #$00                                    ; Find the first weapon the player does not own
@next_weapon:
        inx
        lda     mi_player_inventory_weapons,x
        beq     @give_player_weapon
        cpx     #$0F
        bcc     @next_weapon

@no_effect:
        jsr     mi_no_effect
        jmp     @done

@give_player_weapon:
        lda     #$01
        sta     mi_player_inventory_weapons,x

        stx     zp46                                    ; Tell the player what they found...
        jsr     mi_print_text
        .asciiz "~You find a"
        ldx     zp46

        cpx     #$03
        beq     @print_n
        cpx     #$08
        bne     @print_weapon_name

@print_n:
        lda     #$6E
        jsr     mi_print_char

@print_weapon_name:
        inc     CUR_X
        ldx     zp46
        jsr     mi_print_string_entry_x2
        .addr   mi_weapon_table

        lda     #$21
        jsr     mi_print_char

@flash_border_and_finish:
        jsr     flash_main_view_text_border
@done:  lda     signpost_cache
        sta     mi_player_last_signpost
        jmp     mi_reset_buffers_and_wait_for_input

@branch_no_effect:
        jmp     @no_effect

@raise_attribute:
        cpx     mi_player_last_signpost                 ; Do nothing if the player hasn't been to another signpost yet
        beq     @branch_no_effect

        sta     zp46
        asl     a
        tax
        lda     mi_player_hits,x
        sta     zp47

        sec                                             ; Is the attribute already at 99?
        lda     #$63
        sbc     mi_player_hits,x
        bcc     @branch_no_effect

        adc     #$08                                    ; Increase attribute by (99 + 8 - current value) / 10
        jsr     mi_div_a_by_10
        adc     mi_player_hits,x
        cmp     #$63                                    ; Cap it at 99
        bcc     @update_attribute
        lda     #$63
@update_attribute:
        sta     mi_player_hits,x

        sec                                             ; Did it actually increase?
        sbc     zp47
        beq     @branch_no_effect

        pha                                             ; If so, inform the player by how much
        jsr     mi_print_text
        .asciiz "}Thou dost gain "
        pla
        
        jsr     mi_print_digit
        
        inc     CUR_X
        ldx     zp46
        jsr     mi_print_string_entry_x2
        .addr   mi_attribute_table
        
        jmp     @flash_border_and_finish



;-----------------------------------------------------------
;                flash_main_view_text_border
;
; Highlights the main view text border in white, plays a
; sound, then restores the border color to blue.
;
; Input:
;
; Output:
;-----------------------------------------------------------

flash_main_view_text_border:
        lda     #$10                                    ; Draw main view text border in white
        jsr     mi_draw_main_view_text_border

        lda     #$0A
        jsr     st_play_sound_a

        jsr     delay_for_e6_squared

        jsr     mi_draw_main_view_text_border_blue      ; Change main view text color to blue



;-----------------------------------------------------------
;                  delay_for_e6_squared
;
; Pauses the game briefly.
;
; Input:
;
; Output:
;-----------------------------------------------------------

delay_for_e6_squared:
        lda     #$E6
        jmp     st_delay_a_squared



;-----------------------------------------------------------
;                         cmd_fire
;
; Handler for the Fire command.
;
; Input:
;
; Output:
;-----------------------------------------------------------

cmd_fire:
        ldx     mi_player_current_vehicle

        cpx     #$04                                    ; Is the player in a frigate?
        bne     @is_aircar

        jsr     mi_print_text
        .asciiz "cannons"

        jmp     @get_direction



@is_aircar:
        cpx     #$05                                    ; Is the player in an aircar?
        beq     @fire_lasers

        jsr     mi_print_text                           ; No other vehicle has a weapon...
        .asciiz "what"

        jmp     mi_cmd_invalid



@fire_lasers:
        jsr     mi_print_text
        .asciiz "lasers"

@get_direction:
        jsr     read_direction
        bcc     @do_fire
        rts



@no_target_found:
        jsr     mi_print_text
        .byte   "~Miss!"
        .byte   $00
        rts



@do_fire:
        lda     #$0C                                    ; Play the fire cannon sound
        jsr     st_queue_sound

        lda     #$03                                    ; Find the target in the given direction
        sta     wA145
        jsr     get_target
        bcs     @no_target_found

        lda     #$5E                                    ; Display the attack icon over the target
        sta     (zp4C),y
        jsr     st_draw_world
        jsr     get_cached_mob_location_in_memory

        lda     mi_player_mob_types,x                   ; Restore the mob icon
        sta     (zp4C),y

        jsr     st_get_random_number                    ; 20% chance to miss...
        cmp     #$33
        bcs     @target_hit

        jsr     mi_print_text
        .asciiz "~Missed"
        jmp     print_target_name



@target_hit:
        ldx     mi_player_current_vehicle               ; Calculate the damage to the target
        lda     mob_data_table,x                        ; Look up maximum damage for vehicle
        jsr     mi_get_random_number_a                  ; Get a random number in the appropriate range, then add 30
        adc     #$1E
        jmp     do_damage_to_target



;-----------------------------------------------------------
;-----------------------------------------------------------

cmd_quit_save:
        ldx     POS_X
        ldy     POS_Y
        stx     mi_player_position_x
        sty     mi_player_position_y
        jsr     mi_store_text_area
b965B:  jsr     save_selected_character
        jsr     mi_check_drive_status
        bcs     b965B
        jsr     mi_print_text
        .byte   " saved."
        .byte   $00
        jmp     st_clear_to_end_of_text_row_a



;-----------------------------------------------------------
;-----------------------------------------------------------

cmd_ready:
        jsr     read_key
        jmp     mi_get_item_to_ready



;-----------------------------------------------------------
;-----------------------------------------------------------

cmd_xit:lda     mi_player_current_vehicle
        bne     b9688
        jsr     mi_print_text
        .byte   " what"
        .byte   $00
        jmp     mi_cmd_invalid

b9688:  jsr     get_player_position_and_tile
        cmp     #$03
        bcc     b96B6
b968F:  jsr     mi_cursor_to_col_1
        jsr     mi_print_text
        .byte   "Thou canst not leave it here!"



        .byte   $00
        jmp     mi_play_error_sound_and_reset_buffers

b96B6:  ldx     POS_X
        ldy     POS_Y
        lda     mi_player_current_vehicle
        cmp     #$07
        bcc     b96C3
        lda     #$07
b96C3:  ora     #$08
        jsr     add_vehicle_to_map
        bcs     b968F
        lda     #$00
        sta     mi_player_current_vehicle
        rts



;-----------------------------------------------------------
;                    get_player_position
;
; Retrieves the players current location on the current
; continent.
;
;
; Input:
;
; Output:
;       x - player X coordinate
;       y - player Y coordinate
;-----------------------------------------------------------

get_player_position:
        ldx     POS_X
        ldy     POS_Y
        clc
        rts



;-----------------------------------------------------------
;                         cmd_north
;
; Command handler for when the player wishes to move north.
;
; Input:
;
; Output:
;-----------------------------------------------------------

cmd_north:
        jsr     get_player_position                     ; Read the players current location

        dey                                             ; Update coordinate to one space to the north

        bcc     b96EC



;-----------------------------------------------------------
;                         cmd_south
;
; Command handler for when the player wishes to move south.
;
; Input:
;
; Output:
;-----------------------------------------------------------

cmd_south:
        jsr     get_player_position                     ; Read the players current location

        iny                                             ; Update coordinate to one space to the south

        bcc     b96EC



;-----------------------------------------------------------
;                         cmd_east
;
; Command handler for when the player wishes to move east.
;
; Input:
;
; Output:
;-----------------------------------------------------------

cmd_east:
        jsr     get_player_position                     ; Read the players current location

        inx                                             ; Update coordinate to one space to the east

        bcc     b96EC



;-----------------------------------------------------------
;                         cmd_west
;
; Command handler for when the player wishes to move west.
;
; Input:
;
; Output:
;-----------------------------------------------------------

cmd_west:
        jsr     get_player_position                     ; Read the players current location

        dex                                             ; Update coordinate to one space to the west

b96EC:  jsr     mi_cursor_to_col_1                      ; Move the cursor to column 1

        stx     zp2C                                    ; Store where we want to move to in temporary locations
        sty     zp2D

        lda     mi_player_current_vehicle               ; If the current vehicle is a shuttle or time machine...
        cmp     #$06
        bcc     @not_space_ship

        jsr     mi_print_text                           ; ...then the player can not move
        .asciiz "Can't travel on land!"

        jmp     @play_blocked_sound

@not_space_ship:
        jsr     get_tile                                ; Get the tile at the target location

        tax
        bne     @not_water                                   

        lda     mi_player_current_vehicle               ; Is the player in a vehicle that than move over water?
        cmp     #$03
        bcs     @move_player
        bcc     @blocked


@not_water:
        ldx     #$01
        cmp     #$03                                    ; If the target tile is mountains...
        beq     @blocked                                ; ...then the player is blocked

        cmp     #$10                                    ; If the target tile has a monster...
        bcs     @monster                                ; ...then the player is blocked

        inx                                             ; If the target tile is forest...
        cmp     #$02
        bne     @not_forest
        lda     mi_player_current_vehicle               ; ...and the vehicle is an air car...
        cmp     #$05
        beq     @blocked                                ; ...then the player is blocked

@not_forest:
        ldx     mi_player_current_vehicle               ; If the vehicle is a raft...
        cpx     #$03
        beq     @raft_or_frigate
        cpx     #$04                                    ; ...or a frigate...
        bne     @move_player
@raft_or_frigate:
        jsr     mi_print_string_entry_x                 ; ...then they can not move on land
        .addr   mi_transport_table
        ldx     #$03
@blocked:
        jsr     mi_print_string_entry_x2                ; Tell the player why they can not go there
        .addr   blocked_messages
@play_blocked_sound:
        lda     #$0E
        jmp     mi_play_sound_and_reset_buffers_a

@monster:
        pha                                             ; Tell the player what is in the way...
        jsr     mi_print_text
        .asciiz "Blocked by a"
        pla

        sec                                             ; x := (tile - 4) / 2
        sbc     #$04
        lsr     a
        tax

        cpx     #$0E                                    ; If the tile is an evil trent...
        beq     @print_n
        cpx     #$10                                    ; ...an orc...
        beq     @print_n
        cpx     #$13                                    ; ...or an evil ranger...
        bne     @no_n
@print_n:
        lda     #'n'                                    ; ...print an 'n'
        jsr     mi_print_char

@no_n:  inc     CUR_X                                   ; Advance the cursor

        cpx     #$14                                    ; If the cursor is too far to the right...
        bne     @print_monster_name
        jsr     mi_print_crlf_col_1                     ; ...then advance to the next line

@print_monster_name:
        jsr     mi_print_string_entry_x2                ; Print the monster name
        .addr   mi_world_monster_table

        lda     #'!'
        jsr     mi_print_char
        jmp     @play_blocked_sound



@move_player:
        ldx     zp2C                                    ; Update the player location with the new coordinates
        ldy     zp2D
        stx     POS_X
        sty     POS_Y

        jsr     check_and_update_continent
        ldx     mi_player_current_vehicle
        bne     b97AA
        jsr     mi_increase_high_bytes
        ldx     #$00
b97AA:  ldy     r97BD,x
        lda     r97C7,x
        ldx     mi_player_current_vehicle
        cpx     #$03
        bcs     b97BA
        jmp     mi_s863C

b97BA:  jmp     mi_j863A

r97BD:  .byte   $50,$43,$36,$29,$21,$14,$07,$00
        .byte   $00,$00
r97C7:  .byte   $00,$86,$71,$57,$43,$29,$14,$00
        .byte   $00,$00,$00,$A9,$00,$85,$3F,$20
        .byte   $44,$9D,$F0,$04,$C6,$3F,$D0,$F7
        .byte   $60



;-----------------------------------------------------------
;-----------------------------------------------------------

s97E0:  lda     #$00
        sta     zp3F
b97E4:  jsr     s9D44
        beq     b97F1
        cmp     #$08
        bcs     b97F1
        cmp     #$03
        bne     b97F5
b97F1:  dec     zp3F
        bne     b97E4
b97F5:  rts



;-----------------------------------------------------------
;                 check_and_update_continent
;
; Checks to see if the player has moved past the edge of
; the current continent, and if so, moves them to the next
; continent.
;
; Input:
;
; Output:
;-----------------------------------------------------------

check_and_update_continent:
        lda     POS_X
        bmi     @x_coord_is_negative
        cmp     #$4A                                    ; If x coordinate >= 74 (10 past right edge)...
        bcc     @check_y_coordinate
        bcs     @next_continent                         ; ...go to the next continent

@x_coord_is_negative:
        cmp     #$F6                                    ; If x coordinate < -10...
        bcs     @check_y_coordinate
        bcc     @previous_continent                     ; ...go to the previous continent

@check_y_coordinate:
        lda     POS_Y
        bmi     @y_coord_is_negative
        cmp     #$4A                                    ; If the y coordinate >= 74 (10 past bottom edge)...
        bcc     @stay_same_continent
        bcs     @skip_previous_continent                ; ...skip back two continents

@y_coord_is_negative:
        cmp     #$F6                                    ; If y coordinate < -10...
        bcc     @skip_next_continent                    ; ...skip ahead two continents

@stay_same_continent:
        rts

@next_continent:
        inc     mi_player_continent
        lda     #$F6                                    ; Put player off the west coast
        sta     POS_X
        bne     @done

@previous_continent:
        dec     mi_player_continent
        lda     #$48                                    ; Put player off the east coast
        sta     POS_X
        bne     @done

@skip_previous_continent:
        dec     mi_player_continent
        dec     mi_player_continent
        lda     #$FB                                    ; Put player off the north coast
        sta     POS_Y
        bne     @done

@skip_next_continent:
        inc     mi_player_continent
        inc     mi_player_continent
        lda     #$43                                    ; Put player off the south coast
        sta     POS_Y

@done:  jsr     s9A10



;-----------------------------------------------------------
;                decompress_continent_map
;
; Decompresses the map for the current continent, and places
; any player owned vehicles on the map.
;
; Input:
;
; Output:
;-----------------------------------------------------------

decompress_continent_map:
        lda     mi_player_continent                     ; Make sure mi_player_continent is in the range 0-3
        and     #$03
        sta     mi_player_continent

        asl     a                                       ; x := mi_player_continent * 2
        tax

        lda     continent_addresses,x                   ; source (zp36) := continent_addresses + word at (continent_addresses + x)
        adc     #<continent_addresses
        sta     zp36
        lda     continent_addresses + 1,x
        adc     #>continent_addresses
        sta     zp37

        lda     #$00                                    ; target (zp38) := $6400
        sta     zp38
        lda     #$64
        sta     zp39

        ldy     #$00
@copy_loop:
        lda     (zp36),y                                ; If the current source byte is zero...
        beq     @done_decompressing                     ; ...then we are done

        lsr     a                                       ; x := source / 8 (top five bits)
        lsr     a
        lsr     a
        tax
        
        lda     (zp36),y                                ; a : = 2 * (source % 8) (bottom three bits)
        and     #$07
        asl     a

@write_next_byte:
        sta     (zp38),y                                ; *zp38++ := a
        inc     zp38
        bne     @next_x
        inc     zp39

@next_x:
        dex                                             ; Write out x bytes
        bne     @write_next_byte

        inc     zp36                                    ; Advance source pointer
        bne     @copy_loop
        inc     zp37
        bne     @copy_loop


@done_decompressing:
        lda     mi_player_continent                     ; mi_player_continent_mask := mi_player_continent * 64
        lsr     a
        ror     a
        ror     a
        sta     mi_player_continent_mask

        ldx     mi_player_mob_count                 ; If the player has vehicles...
        beq     @add_new_vehicles

@next_vehicle:
        dex                                             ; ...place them on the map

        lda     mi_player_mob_continent_y_coords,x      ; If the vehicle is not on the current continent...
        and     #$C0
        cmp     mi_player_continent_mask
        bne     @wrong_continent                        ; ...skip it
        
        jsr     get_mob_location_in_memory

        lda     (zp4C),y                                ; Copy the tile in the location into the character data
        sta     mi_player_mob_tiles,x

        lda     mi_player_mob_types,x                   ; Place the vehicle on the map
        sta     (zp4C),y

@wrong_continent:
        txa
        bne     @next_vehicle

@add_new_vehicles:
        stx     zp3F

        ldx     POS_X                                   ; Place any new vehicles the player acquired to the north
        ldy     POS_Y
        dey
        lda     mi_player_new_vehicle_north
        jsr     validate_then_add_vehicle_to_map

        ldx     POS_X                                   ; Place any new vehicles the player acquired to the west
        ldy     POS_Y
        dex
        lda     mi_player_new_vehicle_west
        jsr     validate_then_add_vehicle_to_map

        ldx     POS_X                                   ; Place any new vehicles the player acquired to the east
        ldy     POS_Y
        inx
        lda     mi_player_new_vehicle_east
        jsr     validate_then_add_vehicle_to_map

        ldx     POS_X                                   ; Place any new vehicles the player acquired to the south
        ldy     POS_Y
        iny
        lda     mi_player_new_vehicle_south
        jsr     validate_then_add_vehicle_to_map

        ldx     #$03                                    ; Update player data to remove any vehicles we just added
        lda     #$FF
@loop_new_vehicles:
        sta     mi_player_new_vehicle_north,x
        dex
        bpl     @loop_new_vehicles

        jsr     update_player_vehicle_counters

        lda     mi_player_new_time_machine              ; If the player just acquired a time machine...
        beq     b9910

        lda     mi_player_inventory_vehicles + 10       ; ...and the player does not already have seven time machines...
        cmp     #$07
        bcs     b9910

@find_new_location:
        jsr     st_get_random_number                    ; ...then randomly place it on the map in the top-left corner
        and     #$07
        tay
        iny

        jsr     st_get_random_number
        and     #$07
        tax
        inx

        jsr     get_tile                                ; If the randomly picked location is a plains tile...
        cmp     #$02
        beq     b990B                                   ; ...place the time machine there.

        dec     zp3F
        bne     @find_new_location

b990B:  lda     #$0F                                    ; Add the time machine to the map
        jsr     add_vehicle_to_map

b9910:  lda     #$00                                    ; Clear the add time machine flag
        sta     mi_player_new_time_machine

        rts



;-----------------------------------------------------------
;            update_player_vehicle_counters
;
; Updates all the vehicle counts in the player save data.
;
; Input:
;
; Output:
;-----------------------------------------------------------

update_player_vehicle_counters:
        lda     #$00                                    ; Reset all player vehicle counts to zero
        ldx     #$0A
@loop_reset:
        sta     mi_player_inventory_vehicles,x
        dex
        bne     @loop_reset

        sta     total_player_vechicles

        ldx     mi_player_current_vehicle               ; If the player is currently in a vehicle...
        beq     @not_in_vehicle
        inc     mi_player_inventory_vehicles,x          ; ...update its counter
        inc     total_player_vechicles

@not_in_vehicle:
        ldy     mi_player_mob_count                 ; If the player owns any vehicles (that they are not in)...
        beq     @done
@loop:  dey                                             ; ...update their counters

        lda     mi_player_mob_types,y               ; Get the next vehicle type ID

        cmp     #$20                                    ; Skip any vehicles where the type ID is out of range
        bcs     @skip
        cmp     #$12
        bcc     @skip

        inc     total_player_vechicles

        lsr     a
        cmp     #$0F                                    ; If the vehicle is a time machine...
        bcc     @not_time_machine
        lda     #$12                                    ; ...tweak the ID value accordingly

@not_time_machine:
        tax                                             ; Update the vehicle counter
        inc     mi_player_inventory_vehicles - 8,x
@skip:  tya
        bne     @loop

@done:  rts



;-----------------------------------------------------------
;-----------------------------------------------------------

s9951:  lda     mi_player_mob_count
        cmp     #$41
        bcs     b9987
        jsr     st_get_random_number
        cmp     #$0C
        bcc     b996A
        and     #$3F
        cmp     mi_player_experience + 1
        bcs     b9987
        and     #$07
        bne     b9987
b996A:  sta     zp36
        jsr     st_get_random_number
        and     #$07
        beq     b9987
        asl     a
        sta     zp22
b9976:  lda     #$0F
        jsr     mi_get_random_number_a
        tax
        lda     mi_r7A57,x
        cmp     zp22
        bcc     b9988
        dec     zp36
        bne     b9976
b9987:  rts

b9988:  ldy     #$00
        cpx     #$04
        bcc     b9996
        ldy     #$02
        cpx     #$09
        bcc     b9996
        ldy     #$01
b9996:  sty     zp23
        stx     mi_player_target_type
        txa
        asl     a
        adc     #$10
        sta     zp22
        lda     POS_X
        sbc     #$09
        bpl     b99A9
        lda     #$00
b99A9:  sta     DRAW_START_X
        lda     POS_X
        adc     #$09
        sta     DRAW_END_X
        lda     POS_Y
        sbc     #$04
        bpl     b99B9
        lda     #$00
b99B9:  sta     DRAW_START_Y
        lda     POS_Y
        adc     #$04
        sta     DRAW_END_Y
b99C1:  jsr     s9D44
        cmp     zp23
        bne     b99C1
        cpx     DRAW_START_X
        bcc     b99DD
        cpx     DRAW_END_X
        bcs     b99DD
        cpy     DRAW_START_Y
        bcc     b99DD
        cpy     DRAW_END_Y
        bcs     b99DD
        dec     zp3A
        bne     b99C1
        rts

b99DD:  lda     zp22
        jsr     add_vehicle_to_map
        bcs     b9A04
        lda     mi_player_experience + 1
        ldx     mi_player_target_type
        ldy     mi_r7A57,x
        adc     mob_data_table,y
        lsr     a
        cmp     #$05
        bcc     b99FE
        pha
        jsr     mi_get_random_number_a
        pla
        sec
        adc     zp43
        ror     a
b99FE:  ldx     mi_player_mob_count
        sta     mob_hit_points - 1,x
b9A04:  rts



mob_data_table:
        .byte   $00,$0A,$14,$1E,$28,$32,$3C,$46
        .byte   $50,$5A,$64



;-----------------------------------------------------------
;-----------------------------------------------------------

s9A10:  ldx     mi_player_mob_count
        beq     b9A27
b9A15:  dex
        lda     mi_player_mob_types,x
        cmp     #$20
        bcc     b9A24
        cmp     #$5A
        bcs     b9A24
        jsr     remove_player_vehicle_x
b9A24:  txa
        bne     b9A15
b9A27:  stx     mi_player_target_type
        dex
        stx     mob_hit_points
        rts



;-----------------------------------------------------------
;-----------------------------------------------------------

s9A2F:  jsr     s9951
        ldx     mi_player_mob_count
        beq     b9A4C
b9A37:  dex
        stx     zp_mob_index
        lda     mi_player_mob_types,x
        cmp     #$20
        bcc     b9A48
        cmp     #$5A
        bcs     b9A48
        jsr     s9B3E
b9A48:  ldx     zp_mob_index
        bne     b9A37
b9A4C:  rts

r9A4D:  .byte   $00,$80,$AA,$00,$80,$C0,$E6,$E6
        .byte   $E6,$E6,$E6
j9A58:  jsr     st_get_random_number
        ldx     mi_player_current_vehicle
        cmp     r9A4D,x
        bcc     b9A4C
        ldx     zp_mob_index
        lda     mi_player_mob_types,x
        ldy     #$00
        cmp     #$30
        bcc     b9A7A
        ldy     #$01
        cmp     #$38
        beq     b9A78
        cmp     #$40
        bne     b9A7A
b9A78:  ldy     #$02
b9A7A:  sty     wA144
        lda     #$00
        sta     zp24
        sta     zp25
        lda     mi_player_mob_x_coords,x
        sta     zp22
        lda     POS_X
        bmi     b9A96
        cmp     zp22
        bcc     b9A96
        beq     b9A98
        inc     zp24
        bcs     b9A98
b9A96:  dec     zp24
b9A98:  lda     mi_player_mob_continent_y_coords,x
               and     #$3F
b9A9D:  sta     zp23
        lda     POS_Y
        bmi     b9AAD
        cmp     zp23
        bcc     b9AAD
        beq     b9AAF
        inc     zp25
        bcs     b9AAF
b9AAD:  dec     zp25
b9AAF:  jsr     st_get_random_number
        bmi     b9AB9
        jsr     s9AEE
        bcc     b9ACB
b9AB9:  ldx     zp22
        lda     zp23
        clc
        adc     zp25
        tay
        jsr     b9AF6
        bcc     b9ACB
        jsr     s9AEE
        bcs     b9AED
b9ACB:  jsr     get_cached_mob_location_in_memory
        lda     mi_player_mob_tiles,x
        sta     (zp4C),y
        lda     zp2C
        sta     mi_player_mob_x_coords,x
        lda     zp2D
        ora     mi_player_continent_mask
        sta     mi_player_mob_continent_y_coords,x
        jsr     get_mob_location_in_memory
        lda     (zp4C),y
        sta     mi_player_mob_tiles,x
        lda     mi_player_mob_types,x
        sta     (zp4C),y
b9AED:  rts



;-----------------------------------------------------------
;-----------------------------------------------------------

s9AEE:  ldy     zp23
        lda     zp22
        clc
        adc     zp24
        tax
b9AF6:  cpx     #$40
        bcs     b9B23
        cpy     #$40
        bcs     b9B23
        cpx     POS_X
        bne     b9B06
        cpy     POS_Y
        beq     b9B23
b9B06:  jsr     get_tile
        cmp     #$08
        bcs     b9B13
        cmp     #$04
        bcc     b9B13
        lda     #$01
b9B13:  cmp     wA144
        beq     b9B25
        cmp     #$02
        bne     b9B23
        lda     wA144
        cmp     #$01
        beq     b9B25
b9B23:  sec
        rts

b9B25:  stx     zp2C
        sty     zp2D
        clc
        rts



;-----------------------------------------------------------
;-----------------------------------------------------------

s9B2B:  tay
        beq     b9B3D
        bmi     b9B33
        ldy     #$01
        rts

b9B33:  ldy     #$FF
        sta     w9B3C
        lda     #$00
        sec
w9B3C           := * + 1
        sbc     #$00
b9B3D:  rts



;-----------------------------------------------------------
;-----------------------------------------------------------

s9B3E:  ldx     zp_mob_index
        lda     mi_player_mob_x_coords,x
        sta     zp22
        sec
        sbc     POS_X
        jsr     s9B2B
        sty     zp48
        sta     zp24
        lda     mi_player_mob_continent_y_coords,x
               and     #$3F
        sta     zp23
        sec
        sbc     POS_Y
        jsr     s9B2B
        sty     zp49
        sta     zp25
        tay
        lda     zp24
        beq     b9B70
        cpy     #$00
        beq     b9B6F
        cpy     zp24
        bne     b9B8B
        iny
b9B6F           := * + 1
        cmp     #$A8
b9B70:  cpy     #$02
        bcc     b9BAF
        cpy     #$04
        bcs     b9B8B
        lda     mi_player_mob_types,x
        cmp     #$28
        beq     b9B8E
        cmp     #$2C
        beq     b9B8E
        cmp     #$38
        beq     b9B8E
        cmp     #$58
        beq     b9B8E
b9B8B:  jmp     j9A58

b9B8E:  lda     #$02
        sta     wA145
b9B93:  sec
        lda     zp22
        sbc     zp48
        tax
        sec
        lda     zp23
        sbc     zp49
        tay
        stx     zp22
        sty     zp23
        jsr     get_tile
        cmp     #$03
        beq     b9B8B
        dec     wA145
        bne     b9B93
b9BAF:  jsr     mi_print_tab
        ldx     zp_mob_index
        stx     mi_player_target_index
        lda     mi_player_mob_types,x
        lsr     a
        lsr     a
        adc     #$FE
        sta     mi_player_target_type
        tax
        jsr     mi_print_string_entry_x
        .addr   mi_world_monster_table
        jsr     mi_print_text
        .byte   " attacks! "

        .byte   $00
        lda     #$04
        jsr     st_queue_sound
        lda     #$5E
        sta     st_avatar_tile
        jsr     st_draw_world
        lda     mi_player_stamina
        lsr     a
        sta     zp43
        lda     mi_player_equipped_armor
        asl     a
        asl     a
        asl     a
        adc     zp43
        sta     zp43
        sec
        lda     #$C8
        sbc     zp43
        sta     zp43
        jsr     st_get_random_number
        cmp     zp43
        bcc     b9C17
        lda     CUR_X
        cmp     #$17
        bcc     b9C09
        jsr     mi_print_crlf_col_1
b9C09:  jsr     mi_print_text
        .byte   "Missed!"
        .byte   $00
        jmp     j9C71

b9C17:  lda     CUR_X
        cmp     #$1A
        bcc     b9C20
        jsr     mi_print_crlf_col_1
b9C20:  jsr     mi_print_text
        .byte   "Hit! "
        .byte   $00
        lda     CUR_X
        cmp     #$15
        bcc     b9C32
        jsr     mi_print_crlf_col_1
b9C32:  ldx     mi_player_target_type
        lda     mi_mob_treasure_table,x
        asl     a
        jsr     mi_get_random_number_a
        clc
        adc     #$01
        sta     mi_w81C1
        jsr     mi_print_short_int
        jsr     mi_print_text
        .byte   " damage"
        .byte   $00
        lda     mi_player_hits
        sec
        sbc     mi_w81C1
        sta     mi_player_hits
        lda     mi_player_hits + 1
        sbc     #$00
        bpl     b9C66
        lda     #$00
        sta     mi_player_hits
b9C66:  sta     mi_player_hits + 1
        jsr     mi_update_stats
        lda     #$02
        jsr     st_play_sound_a
j9C71:  jsr     set_avatar_vehicle_tile
        jmp     st_draw_world



;-----------------------------------------------------------
;           get_cached_mob_location_in_memory
;
; Retrieves the memory location of the cached mob on
; the world map. After calling this method, '(zp4C),y' will
; point to the tile on the world map where the mob is
; located.
;
; Input:
;       zp_mob_index - mob entry index
;
; Output:
;       y - the x coordinate of the mob
;    zp4C - Address of the world map row where the mob
;           is located
;-----------------------------------------------------------

get_cached_mob_location_in_memory:
        ldx     zp_mob_index

        ; continued in get_mob_location_in_memory



;-----------------------------------------------------------
;                get_mob_location_in_memory
;
; Retrieves the memory location of the specified mob on
; the world map. After calling this method, '(zp4C),y' will
; point to the tile on the world map where the mob is
; located.
;
; Input:
;       x - mob entry index
;
; Output:
;       y - the x coordinate of the mob
;    zp4C - Address of the world map row where the mob
;           is located
;-----------------------------------------------------------

get_mob_location_in_memory:
        lda     #$00                                    ; zp4C := 0
        sta     zp4C

        lda     mi_player_mob_continent_y_coords,x
               and     #$3F
        lsr     a
        ror     zp4C
        lsr     a
        ror     zp4C
        adc     #$64
        sta     zp4D
        ldy     mi_player_mob_x_coords,x
        rts



;-----------------------------------------------------------
;            validate_then_add_vehicle_to_map
;
; Ensures that the accumulator holds a valid vehicle tile
; ID, then calls add_vehicle_to_map. If it does not, then
; this does nothing.
;
; Input:
;       a - vehicle tile ID
;       x - x coordinate
;       y - y coordinate
;
; Output:
;-----------------------------------------------------------

validate_then_add_vehicle_to_map:
        cmp     #$08                                    ; If a >= 8 and < 16
        bcc     done
        cmp     #$10
        bcc     add_vehicle_to_map                      ; ...then call add_vehicle_to_map
        rts

        .byte   $48,$20,$D2,$97,$68,$4C,$A6,$9C
        .byte   $48,$20,$E0,$97,$68



;-----------------------------------------------------------
;                    add_vehicle_to_map
;
; Adds a player vehicle to the map and to the player save
; data. If the player already owns 80 vehicles, then this
; does nothing.
;
; Input:
;       a - vehicle tile ID
;       x - x coordinate
;       y - y coordinate
;
; Output:
;-----------------------------------------------------------

add_vehicle_to_map:
        cpx     #$40                                    ; Make sure coordinates are in correct range
        bcs     done
        cpy     #$40
        bcs     done

        stx     zp46                                    ; Cache the X coordinate to free the x register

        ldx     mi_player_mob_count                 ; If the player already owns 80 vehicles...
        cpx     #$50
        bcs     done                                    ; ...then we are done

        asl     a                                       ; Store the vehicle type
        sta     mi_player_mob_types,x

        pha                                             ; Store the vehicle location
        tya
        ora     mi_player_continent_mask
        sta     mi_player_mob_continent_y_coords,x
               lda     zp46
        sta     mi_player_mob_x_coords,x

        jsr     get_mob_location_in_memory          ; Get the tile at the vehicle location and store it
        lda     (zp4C),y
        sta     mi_player_mob_tiles,x

        pla                                             ; Update the map with the new vehicle tile
        sta     (zp4C),y

        inc     mi_player_mob_count                 ; Update the vehicle count

        clc
done:   rts



;-----------------------------------------------------------
;              remove_vehicle_at_player_location
;
; Removes the vehicle information from the player data for
; the vehicle at the players current location on the world
; map.
;
; Input:
;
; Output:
;       a - the removed vehicle type
;       x - vehicle entry index
;-----------------------------------------------------------

remove_vehicle_at_player_location:
        ldx     POS_X                                   ; Get the players current location
        ldy     POS_Y

        cpx     #$40                                    ; If the current location is invalid...
        bcs     done
        cpy     #$40
        bcs     done                                    ; ...then we are done

        stx     zp46                                    ; zp46 := player x coordinate

        tya
        ora     mi_player_continent_mask                ; a := mi_player_continent_mask | player y coordinate

        ldx     mi_player_mob_count                 ; Find the appropriate vehicle location entry in the player save data
@loop:
        dex
        bmi     done
        cmp     mi_player_mob_continent_y_coords,x      ; If the y coordinate/continent does not match...
        bne     @loop
        ldy     mi_player_mob_x_coords,x            ; ...and the x coordinate does not match
        cpy     zp46
        bne     @loop                                   ; ...then keep looking

        ; at this point, x has the vehicle entry index

        ; continued in remove_player_vehicle_x



;-----------------------------------------------------------
;                  remove_player_vehicle_x
;
; Removed the given vehicle entry from the player
; information.
;
; Input:
;       x - vehicle entry index
;
; Output:
;       a - the removed vehicle type
;       x - vehicle entry index
;-----------------------------------------------------------

remove_player_vehicle_x:
        lda     mi_player_mob_continent_y_coords,x      ; If the vehicle is on the current continent...
        and     #$C0
        cmp     mi_player_continent_mask
        bne     b9D0E

        jsr     get_mob_location_in_memory          ; ...restore the original tile on the world map
        lda     mi_player_mob_tiles,x
        sta     (zp4C),y

b9D0E:  lda     mi_player_mob_types,x               ; zp3A := the removed vehicle type
        sta     zp3A

        stx     zp46                                    ; zp46 := the removed vehicle index

        dec     mi_player_mob_count                 ; Reduce the vehicle counter

        bne     @next_vehicle                           ; If no more vehicles are left...
        rts                                             ; ...then we are done

@loop:  lda     mi_player_mob_x_coords + 1,x        ; Shift all vehicle entries after the removed vehicle up
        sta     mi_player_mob_x_coords,x
        lda     mi_player_mob_continent_y_coords + 1,x
        sta     mi_player_mob_continent_y_coords,x
        lda     mi_player_mob_types + 1,x
        sta     mi_player_mob_types,x
        lda     mi_player_mob_tiles + 1,x
        sta     mi_player_mob_tiles,x

        lda     mob_hit_points + 1,x
        sta     mob_hit_points,x

        inx
@next_vehicle:
        cpx     mi_player_mob_count                 ; If that was not the last vehicle...
        bcc     @loop                                   ; ...keep going

        ldx     zp46                                    ; x := the removed vehicle index
        lda     zp3A                                    ; a := the removed vehicle type

        rts



;-----------------------------------------------------------
;-----------------------------------------------------------

s9D44:  jsr     st_get_random_number
        and     #$3F
        tay
        jsr     st_get_random_number
        and     #$3F
        tax



;-----------------------------------------------------------
;                         get_tile
;
; Gets the tile at the given location.
;
; Input:
;       x - the x coordinate
;       y - the y coordinate
;
; Output:
;       a - the tile at the given coordinate
;-----------------------------------------------------------

get_tile:
        lda     #$00

        cpy     #$40                                    ; if x or y >= 64, then we're done
        bcs     @done
        cpx     #$40
        bcs     @done

        tya                                             ; Cache the y value
        sta     @restore_y + 1

        lsr     a                                       ; zp4C := $6400 + (y << 6)
        sta     zp4D
        lda     #<continent_map
        ror     a
        lsr     zp4D
        ror     a
        sta     zp4C

        lda     zp4D
        adc     #>continent_map
        sta     zp4D

        txa                                             ; Read byte at zp4C + x
        tay
        lda     (zp4C),y

@restore_y:
        ldy     #$00

@done:  lsr     a                                       ; The values in the world map are all shifted one bit, so shift it back
        rts



;-----------------------------------------------------------
;               get_player_position_and_tile
;
; Returns the players current location and which tile is
; currently under the player.
;
; Input:
;
; Output:
;       a - tile under the player
;       x - x coordinate of player
;       y - y coordinate of player
;   tile_cache - tile under the player
;-----------------------------------------------------------

get_player_position_and_tile:
        ldx     POS_X
        ldy     POS_Y
        jsr     get_tile
        sta     tile_cache
        rts



;-----------------------------------------------------------
;                      cmd_inform_search
;
; Command handler for the Inform and Search command.
;
; Input:
;
; Output:
;-----------------------------------------------------------

cmd_inform_search:
        jsr     mi_print_tab
        jsr     get_player_position_and_tile            ; a := tile_cache := tile at player location

        cmp     #$03                                    ; If the tile is mountains...
        beq     @over_mountains                         ; ...treat it the same as plains

        cmp     #$08                                    ; If tile is a vehicle...
        bcc     @cache_tile
        lda     POS_Y                                   ; ...get the tile from the vehicle tile cache instead
        ora     mi_player_continent_mask
        ldx     mi_player_mob_count
@loop:  cmp     mi_player_mob_continent_y_coords - 1,x
        bne     @next_vehicle
        ldy     mi_player_mob_x_coords - 1,x
        cpy     POS_X
        bne     @next_vehicle
        lda     mi_player_mob_tiles - 1,x
        lsr     a
        bpl     @cache_tile
@next_vehicle:  dex
        bne     @loop

@over_mountains:
        lda     #$01                                    ; Treat tile as plains
@cache_tile:
        sta     tile_cache                              ; Store tile in cache

        cmp     #$04                                    ; If the tile is water, plains, or forest...
        bcs     @special_tile

        tax                                             ; ...then inform the player as such
        jsr     mi_print_string_entry_x2
        .addr   tile_descriptions

        ldx     tile_cache                              ; x := cached tile

        dex                                             ; If tile is plains...
        bne     @done

        ldx     mi_player_continent                     ; ...append the continent name
        jsr     mi_print_string_entry_x2
        .addr   mi_land_name_table

@done:  rts



@special_tile:
        cmp     #$06                                    ; If the tile is a town...
        bne     @find_feature

        jsr     mi_print_text                           ; ...print prefix for the town name
        .asciiz "the city of "

@find_feature:
        lda     mi_player_continent_mask                ; Go through all the world features and find the one
        ora     POS_Y                                   ; whose location matches the players
        ldx     #$53
@loop_features:
        cmp     mi_world_feature_continent_y_coords,x
        bne     @next_feature
        ldy     mi_world_feature_x_coords,x
        cpy     POS_X
        beq     @print_feature
@next_feature:
        dex
        bpl     @loop_features
        stx     mi_player_world_feature
        rts



@print_feature:
        stx     mi_player_world_feature

        jsr     mi_print_string_entry_x2
        .addr   mi_world_feature_table

        rts



;-----------------------------------------------------------
;                  print_current_vehicle
;
; Prints the name of the players current vehicle.
;
; Input:
;
; Output:
;-----------------------------------------------------------

print_current_vehicle:
        ldx     mi_player_current_vehicle
        jsr     mi_print_string_entry_x2
        .addr   mi_transport_table
        rts



;-----------------------------------------------------------
;                 set_avatar_vehicle_tile
;
; Updates the avatar tile to the appropriate image for the
; vehicle that the player is currently travelling in. If
; the vehicle is invalid, automatically places the player
; on foot.
;
; Input:
;
; Output:
;-----------------------------------------------------------

set_avatar_vehicle_tile:
        lda     mi_player_current_vehicle               ; If vehicle ID >= 11...
        cmp     #$0B
        bcc     @valid_vehicle
        lda     #$00                                    ; ...then it is not valid - put player on foot
        sta     mi_player_current_vehicle

@valid_vehicle:
        cmp     #$07                                    ; If the player is in a time machine...
        bcc     @not_time_machine
        lda     #$0A                                    ; ...update the vehicle ID as such
        sta     mi_player_current_vehicle
        lda     #$07

@not_time_machine:
        ora     #$08                                    ; Convert vehicle ID to the corresponding tile image ID
        asl     a
        sta     st_avatar_tile

        rts
