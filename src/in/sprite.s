;-------------------------------------------------------------------------------
;
; sprite.s
;
; Sprite setup and teardown routines.
;
;-------------------------------------------------------------------------------

.include "c64.inc"
.include "kernel.inc"
.include "global.inc"
.include "in.inc"

.import knight_frame_0
.import knight_frame_1
.import car

.export enable_sprites
.export disable_sprites
.export setup_sprites

.export intro_loop_counter

        .setcpu "6502"

.segment "CODE_SPRITE"

;-----------------------------------------------------------
;                     enable_sprites
;
; Configures VIC screen memory to $6000, bitmap memory to
; $4000, and enables all sprites.
;-----------------------------------------------------------

enable_sprites:
        lda     #$80            ; Set screen memory to $6000-$63FF, and bitmap memory to $4000-$5FFF
        sta     VIC_VIDEO_ADR
        lda     #$96            
        sta     CIA2_PRA
        lda     #$FF            ; Enable all sprites
        sta     VIC_SPR_ENA
        rts




;-----------------------------------------------------------
;                     disable_sprites
;
; Configures VIC screen memory to $0400, bitmap memory to
; $2000, and disables all sprites.
;-----------------------------------------------------------

disable_sprites:
        lda     #$18            ; Set screen memory to $0400-$07FF, and bitmap memory to $2000-$3FFF
        sta     VIC_VIDEO_ADR
        lda     #$97
        sta     CIA2_PRA
        lda     #$00            ; Disable all sprites
        sta     VIC_SPR_ENA
        rts




;-----------------------------------------------------------
;                       setup_sprites
;
; Initializes sprites for the intro page. Specifically, it
; does the following:
;
; - initialize animation counters
; - erases all sprite images
; - sets up pointers to sprite images in video memory
; - set initial location of all sprites
; - set whether each sprite should appear in front or
;   behind screen content
; - set colors for all sprites
;-----------------------------------------------------------

setup_sprites:
        lda     #$00
        sta     $7B
        sta     horse_anim_index
        sta     frame_ctr
        sta     $7C
        sta     $7E
        sta     $82
        sta     $83
        sta     sprite_5_ctr
        sta     $87
        tax

@loop:  sta     sprite_0_image,x        ; Erase all sprite images (64 * 8 = 512 bytes)
        sta     sprite_0_image + $0100,x
        inx
        bne     @loop

        ldx     #$12                    ; Set $6540-$6552 to $03 and $6582-$6594 to $00
@loop2: lda     #$03                    ; (this seems to get overwritten below, so what
        sta     sprite_3_image,x        ; is this for?)
        lda     #$00
        sta     sprite_4_image + 2,x
        dex
        bpl     @loop2

        ldx     #$07                    ; Set up pointers to tell the VIC where sprite images
@loop3: lda     sprite_pointers,x       ; are located in bitmap memory
        sta     sprite_0_ptr,x
        dex
        bpl     @loop3

        lda     #$00                    ; Set hi bit of x coord of all sprites to 0
        sta     VIC_SPR_HI_X

        lda     #$1E                    ; Draw sprites 0, 5, 6, and 7 in front of screen content
        sta     VIC_SPR_BG_PRIO         ; Draw sprites 1, 2, 3, and 4 behind screen content

        ldx     #$0F                    ; Initialize X/Y coordinates and colors for all sprites
@sprite_position_loop:
        lda     sprite_coordinates,x
        sta     VIC_SPR0_X,x
        cpx     #$08
        bcs     @skip_set_color
        lda     sprite_colors,x
        sta     VIC_SPR0_COLOR,x
@skip_set_color:
        dex
        bpl     @sprite_position_loop

        ldx     #$3F                    ; Make sprites 3 and 4 solid squares
        lda     #$FF
@loop4: sta     sprite_3_image,x
        sta     sprite_4_image,x
        dex
        bpl     @loop4

        lda     intro_loop_counter      ; Every 16 times through the intro, do the car animation
        and     #$0F
        beq     @init_car

        ldx     #$26                    ; Load knight frames into sprite memory
@loop5: lda     knight_frame_0,x
        sta     sprite_5_image,x
        lda     knight_frame_1,x
        sta     sprite_5b_image,x
        dex
        bpl     @loop5

        lda     #$00                    ; Clear car flag so knight is properly animated
        sta     car_flag
        rts

@init_car:
        ldx     #$0E                    ; Replace knight images with car image
@loop6: lda     car,x
        sta     sprite_5_image,x
        sta     sprite_5b_image,x
        dex
        bpl     @loop6

        lda     #$FF                    ; Set car flag so car is properly animated
        sta     car_flag
        lda     #$B2                    ; Set sprite 5 Y position (10 pixels below knight position)
        sta     VIC_SPR5_Y
        lda     #$02                    ; Set sprite 5 color to red (knight is white)
        sta     VIC_SPR5_COLOR
        rts

intro_loop_counter:
        .byte   $00

sprite_coordinates:
        .byte   $44,$C4
        .byte   $00,$00
        .byte   $00,$00
        .byte   $53,$A5
        .byte   $60,$A5
        .byte   $00,$A8
        .byte   $00,$00
        .byte   $00,$00

sprite_colors:
        .byte   $01,$01,$0A,$00,$00,$01,$01,$01

sprite_pointers:
        .byte   $90,$91,$92,$95,$96,$93,$97,$97




