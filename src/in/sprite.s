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

.import car
.import d7684
.import d765D

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

@loop:  sta     sprite_0_image,x        ; Erase all sprite images
        sta     sprite_0_image + $0100,x
        inx
        bne     @loop

        ldx     #$12                    ; Set $6540-$6552 to $03 and $6582-$6594 to $00
@loop2: lda     #$03                    ; (this seems to get overwritten below)
        sta     sprite_3_image,x
        lda     #$00
        sta     sprite_4_image + 2,x
        dex
        bpl     @loop2

        ldx     #$07                    ; Set up pointers so the VIC can locate sprite images
@loop3: lda     sprite_pointers,x
        sta     sprite_0_ptr,x
        dex
        bpl     @loop3

        lda     #$00                    ; Set hi bit of x coord of all sprites to 0
        sta     VIC_SPR_HI_X

        lda     #$1E                    ; Draw sprites 0, 5, 6, and 7 in front of screen content
        sta     VIC_SPR_BG_PRIO         ; Draw sprites 1, 2, 3, and 4 behind screen content

        ldx     #$0F                    ; Set X/Y coordinates and colors for all sprites
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

        lda     intro_loop_counter      ; Every 16 times through the intro, do something (knight)
        and     #$0F
        beq     @skip_knight

        ldx     #$26                    ; Copy $765D-$7683 to $64C0-$64E6
@loop5: lda     d765D,x
        sta     sprite_5_image,x
        lda     d7684,x                 ; Copy $7684-$76AA to $6500-$6526
        sta     sprite_5b_image,x
        dex
        bpl     @loop5
        lda     #$00
        sta     $85
        rts

@skip_knight:
        ldx     #$0E                    ; Copy $7518-$7526 to $64C0 and $6500
@loop6: lda     car,x
        sta     sprite_5_image,x
        sta     sprite_5b_image,x
        dex
        bpl     @loop6

        lda     #$FF
        sta     $85
        lda     #$B2                    ; Set sprite 5 Y position
        sta     VIC_SPR5_Y
        lda     #$02                    ; Set sprite 5 color to red
        sta     VIC_SPR5_COLOR
        rts

intro_loop_counter:
        .byte   $00

sprite_coordinates:
        .byte   $44,$C4,$00,$00,$00,$00,$53,$A5
        .byte   $60,$A5,$00,$A8,$00,$00,$00,$00

sprite_colors:
        .byte   $01,$01,$0A,$00,$00,$01,$01,$01

sprite_pointers:
        .byte   $90,$91,$92,$95,$96,$93,$97,$97




