;-------------------------------------------------------------------------------
;
; draw.s
;
; Routine for drawing the world to the main viewport.
;
;-------------------------------------------------------------------------------

.include "stlib.inc"

.export draw_world

.export tile_images

.import animate_water
.import buffer_input
.import scan_input
.import swap_bitmaps

.import bitmap_y_offset_hi
.import bitmap_y_offset_lo

.import scrmem_y_offset_hi
.import scrmem_y_offset_lo


castle_flag_hi          := tile_images + $89
castle_flag_lo          := tile_images + $8A
towne_flag_hi           := tile_images + $C3
towne_flag_lo           := tile_images + $C4
ship_flag_l_hi          := tile_images + $182
ship_flag_l_lo          := tile_images + $183
ship_flag_r_hi          := tile_images + $18A
ship_flag_r_lo          := tile_images + $18B

PLAYER_X                := $20
PLAYER_Y                := $21
SCREEN_Y                := $45
VIEW_X                  := $46
VIEW_Y                  := $47
TMP_X                   := $48
TMP_ACC                 := $49
WORLD_PTR               := $4C
TILE_COLOR              := $5E
BITMAP_PTR_HI           := $60
BITMAP_PTR_LO           := $62
SCREEN_MEM_PTR          := $64
WORLD_BUFFER            := $66      ; 19 bytes

random_data             := $B700

        .setcpu "6502"

.segment "DATA_178B"

water_ctr:
        .byte   $01
castle_flag_ctr:
        .byte   $03
towne_flag_ctr:
        .byte   $02

monster_anim_ctr:
        .byte   $01

.segment "CODE_DRAW"

;-----------------------------------------------------------
;                        draw_world
;
; Draws the world into the main viewport.
;-----------------------------------------------------------

draw_world:
        lda     #$08                                    ; SCREEN_Y := 8
        sta     SCREEN_Y

        sec                                             ; VIEW_X := PLAYER_X - 9
        lda     PLAYER_X
        sbc     #$09
        sta     VIEW_X

        sec                                             ; VIEW_Y := PLAYER_Y - 4
        lda     PLAYER_Y
        sbc     #$04
        sta     VIEW_Y

@loop:  jsr     scan_input                              ; Scan and buffer any input where the high bit is set
        bpl     @buffer_world_view_row
        jsr     buffer_input

@buffer_world_view_row:
        lda     VIEW_Y                                  ; If VIEW_Y >= 64 (or < 0) then fill the world buffer with water
        cmp     #$40
        bcs     @fill_buffer_with_water

        lsr     a                                       ; WORLD_PTR := $6400 + (VIEW_Y * 64)
        sta     WORLD_PTR + 1
        lda     #$00
        ror     a
        lsr     WORLD_PTR + 1
        ror     a
        sta     WORLD_PTR
        lda     WORLD_PTR + 1
        adc     #$64
        sta     WORLD_PTR + 1

        ldx     #$00                                    ; x := 0
        ldy     VIEW_X                                  ; y := VIEW_X

@loop_x:                                                ; Loop through every tile in the world view row (19 tiles)
        cpy     #$40                                    ; if y (x world coordinate) < 64 and >= 0 then buffer the tile
        bcc     @b1CD2
        lda     #$00                                    ; Otherwise advance to the next tile
        beq     @advance_to_next_world_column



@fill_buffer_with_water:
        ldx     #$12                                    ; Fill the world buffer with water (tile 0)
        lda     #$00
@loop_fill_water:
        sta     WORLD_BUFFER,x
        dex
        bpl     @loop_fill_water
        bmi     @fix_avatar_tile



@b1CD2: lda     (WORLD_PTR),y                           ; Get the current tile from the world map

        and     #$7E                                    ; Filter out the top and bottom bits

        cmp     #$20                                    ; If the value is less than 0x20 (tile 16), then store it and continue
        bcc     @advance_to_next_world_column       

        cmp     #$59                                    ; If the value is greater than or equal to 0x59, store it and continue
        bcs     @advance_to_next_world_column

        stx     TMP_X                                   ; Randomly add two to the tile number to animate the monster tiles
        sta     TMP_ACC
        inc     monster_anim_ctr
        ldx     monster_anim_ctr
        lda     random_data,x
        and     #$02                            
        adc     TMP_ACC
        ldx     TMP_X



@advance_to_next_world_column:
        lsr     a                                       ; Store the current tile into the world buffer (after dividing by two)
        sta     WORLD_BUFFER,x

        inx                                             ; Advance to the next tile
        iny

        cpx     #$13                                    ; Keep going until we've buffered 19 tiles
        bcc     @loop_x



@fix_avatar_tile:
        lda     VIEW_Y                                  ; If the current row is the row the player is on, replace the center tile with the avatar tile image
        inc     VIEW_Y
        cmp     PLAYER_Y
        bne     @draw_world_row
        lda     avatar_tile
        lsr     a
        sta     WORLD_BUFFER + 9



@draw_world_row:
        ldx     SCREEN_Y                                ; BITMAP_PTR_HI := memory location of top left corner of last tile in the current row
        lda     bitmap_y_offset_lo,x
        clc
        adc     #$28
        sta     BITMAP_PTR_HI
        lda     bitmap_y_offset_hi,x
        adc     #$01
        eor     BM_ADDR_MASK
        sta     BITMAP_PTR_HI + 1

        lda     BITMAP_PTR_HI                           ; BITMAP_PTR_LO := memory location eight pixels below BITMAP_PTR_HI
        adc     #$40
        sta     BITMAP_PTR_LO
        lda     BITMAP_PTR_HI + 1
        adc     #$01
        sta     BITMAP_PTR_LO + 1

        lda     SCREEN_Y                                ; SCREEN_MEM_PTR := screen memory location of top left corner of the current row
        lsr     a
        lsr     a
        lsr     a
        tay
        lda     scrmem_y_offset_lo,y
        sta     SCREEN_MEM_PTR
        lda     scrmem_y_offset_hi,y
        ldx     BM_ADDR_MASK
        beq     @set_srn_ptr_hi
        clc
        adc     #$5C
@set_srn_ptr_hi:
        sta     SCREEN_MEM_PTR + 1

        ldx     #$12                                    ; Loop through all 19 tiles, from right to left
@loop_row:
        lda     WORLD_BUFFER,x                          ; Get the next tile

        tay                                             ; Get the color for the tile
        lda     tile_colors,y
        sta     TILE_COLOR

        lda     tile_addr_lo,y                          ; Get the address for the top and bottom halves of the tile
        sta     @tile_addr_top
        clc
        adc     #$10
        sta     @tile_addr_bottom
        lda     tile_addr_hi,y
        sta     @tile_addr_top + 1
        adc     #$00
        sta     @tile_addr_bottom + 1

        ldy     #$0F                                    ; Copy the 32 bytes for the tile (2 pairs of 16 bytes)
@loop_tile:
@tile_addr_top  := * + 1
        lda     tile_images,y
        sta     (BITMAP_PTR_HI),y
@tile_addr_bottom   := * + 1
        lda     tile_images,y
        sta     (BITMAP_PTR_LO),y
        dey
        bpl     @loop_tile

        txa                                             ; y := 2x + 1
        asl     a
        tay
        iny

        lda     TILE_COLOR                              ; Put the color of the tile into the four bytes of screen memory
        sta     (SCREEN_MEM_PTR),y
        iny
        sta     (SCREEN_MEM_PTR),y
        tya
        clc
        adc     #$28
        tay
        lda     TILE_COLOR
        sta     (SCREEN_MEM_PTR),y
        dey
        sta     (SCREEN_MEM_PTR),y

        lda     BITMAP_PTR_HI                           ; Move the bitmap pointers 16 pixels to the left
        sec
        sbc     #$10
        sta     BITMAP_PTR_HI
        lda     BITMAP_PTR_HI + 1
        sbc     #$00
        sta     BITMAP_PTR_HI + 1

        lda     BITMAP_PTR_LO
        sec
        sbc     #$10
        sta     BITMAP_PTR_LO
        lda     BITMAP_PTR_LO + 1
        sbc     #$00
        sta     BITMAP_PTR_LO + 1

        dex                                             ; Keep going until we've completed the row
        bpl     @loop_row

        lda     SCREEN_Y                                ; Move the screen draw pointer 16 pixels down
        clc
        adc     #$10
        sta     SCREEN_Y

        lda     SCREEN_Y                                ; Keep going until we've reached the bottom of the viewport
        cmp     #$98
        bcs     @update_screen
        jmp     @loop



@update_screen:
        jsr     swap_bitmaps

        dec     water_ctr                               ; Update the water every two frames
        bne     @update_castle
        lda     #$02
        sta     water_ctr
        ldy     #$00
        jsr     animate_water

@update_castle:
        dec     castle_flag_ctr                         ; Update the castle flag every three frames
        bne     @update_towne
        lda     #$03
        sta     castle_flag_ctr
        ldx     castle_flag_hi
        ldy     castle_flag_lo
        sty     castle_flag_hi
        stx     castle_flag_lo

@update_towne:
        dec     towne_flag_ctr                          ; Update the towne flag every two frames
        bne     @update_ship
        lda     #$02
        sta     towne_flag_ctr
        ldx     towne_flag_hi
        ldy     towne_flag_lo
        sty     towne_flag_hi
        stx     towne_flag_lo

@update_ship:
        ldx     ship_flag_r_hi                          ; Update the ship flag every frame
        ldy     ship_flag_r_lo
        sty     ship_flag_r_hi
        stx     ship_flag_r_lo
        ldx     ship_flag_l_hi
        ldy     ship_flag_l_lo
        sty     ship_flag_l_hi
        stx     ship_flag_l_lo

        ; continued in scan_and_buffer_input



.segment "DATA_TILES"

tile_images:
        .incbin "tiles.bin"



.segment "DATA_TILE_DATA"

tile_addr_lo:
        .byte   $00,$20,$40,$60,$80,$A0,$C0,$E0
        .byte   $00,$20,$40,$60,$80,$A0,$C0,$E0
        .byte   $00,$20,$40,$60,$80,$A0,$C0,$E0
        .byte   $00,$20,$40,$60,$80,$A0,$C0,$E0
        .byte   $00,$20,$40,$60,$80,$A0,$C0,$E0
        .byte   $00,$20,$40,$60,$80,$A0,$C0,$E0
        .byte   $00,$20,$40,$60,$80,$A0,$C0,$E0
        .byte   $00,$20,$40,$60,$80,$A0,$C0,$E0

tile_addr_hi:
        .byte   $0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C
        .byte   $0D,$0D,$0D,$0D,$0D,$0D,$0D,$0D
        .byte   $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E
        .byte   $0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F
        .byte   $10,$10,$10,$10,$10,$10,$10,$10
        .byte   $11,$11,$11,$11,$11,$11,$11,$11
        .byte   $12,$12,$12,$12,$12,$12,$12,$12
        .byte   $13,$13,$13,$13,$13,$13,$13,$13

tile_colors:
        .byte   $60,$50,$50,$F0,$10,$10,$10,$F0
        .byte   $10,$10,$10,$10,$10,$10,$10,$10
        .byte   $10,$10,$50,$50,$10,$10,$10,$10
        .byte   $10,$10,$10,$10,$50,$50,$10,$10
        .byte   $50,$50,$10,$10,$10,$10,$10,$10
        .byte   $10,$10,$10,$10,$10,$10,$30,$A0



.segment "DATA_AVATAR_TILE"

avatar_tile:
        .byte   $10
