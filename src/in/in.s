;-------------------------------------------------------------------------------
;
; in.s
;
;-------------------------------------------------------------------------------


.include "c64.inc"
.include "kernel.inc"
.include "global.inc"

.import draw_text
.import erase_text_area

.import horse_frame_ptrs
.import horse_anim_frames
.import d7B3B
.import d7B6B
.import d7A0B
.import d7AA3
.import d7835
.import d780D
.import d76B5
.import d78A0
.import title_logo
.import studio_logo
.import d7518
.import d7684
.import d765D
.import intro_backdrop

.export temp_ptr
.export bitmap_row_addr_table_low
.export bitmap_row_addr_table_high
.export bitmap_col_offset_table_low
.export bitmap_col_offset_table_high

        .setcpu "6502"

;-------------------------------------------------------------------------------
;
; The load address for this file is always set to $2000, but is ignored. The
; actual location where this code should be loaded into memory is $6800.
;
;-------------------------------------------------------------------------------

.segment    "LOADADDR"

        .addr   $2000




temp_ptr                        := $60
temp_ptr2                       := $62

frame_ctr                       := $79
horse_anim_index                := $7A
pause_ctr                       := $86

bitmap_row_addr_table_low       := $1200
bitmap_row_addr_table_high      := $12C0

bitmap_col_offset_table_low     := $15B0
bitmap_col_offset_table_high    := $15D8

bitmap_memory                   := $4000
screen_memory                   := $6000

sprite_0_ptr                    := screen_memory + $03F8
sprite_1_ptr                    := screen_memory + $03F9
sprite_2_ptr                    := screen_memory + $03FA
sprite_3_ptr                    := screen_memory + $03FB
sprite_4_ptr                    := screen_memory + $03FC
sprite_5_ptr                    := screen_memory + $03FD
sprite_6_ptr                    := screen_memory + $03FE
sprite_7_ptr                    := screen_memory + $03FF

sprite_0_image                  := bitmap_memory + $40 * $90    ; $6400
sprite_1_image                  := bitmap_memory + $40 * $91    ; $6440
sprite_2_image                  := bitmap_memory + $40 * $92    ; $6480
sprite_3_image                  := bitmap_memory + $40 * $95    ; $6540
sprite_4_image                  := bitmap_memory + $40 * $96    ; $6580
sprite_5_image                  := bitmap_memory + $40 * $93    ; $64C0
sprite_5b_image                 := bitmap_memory + $40 * $94    ; $6500
sprite_6_image                  := bitmap_memory + $40 * $97    ; $65C0
sprite_7_image                  := bitmap_memory + $40 * $97    ; $65C0

.code

main:   jmp     decompress_image




exit_intro:
        jsr     disable_sprites

        lda     #>bitmap_memory         ; Fill memory $4000 to $63FF with zeros
        sta     temp_ptr + 1            ; (erase intro graphics)
        lda     #<bitmap_memory
        sta     temp_ptr
        tay
        ldx     #$24
@loop:  sta     (temp_ptr),y
        iny
        bne     @loop
        inc     temp_ptr + 1
        dex
        bne     @loop

        ldx     #$0D                    ; Load MI at $7400
        jsr     load_file_cached
        jmp     mi_main                 ; Execute MI




decompress_image:
        lda     #<bitmap_memory         ; Write to bitmap memory at $4000
        sta     store_vector
        lda     #>bitmap_memory
        sta     store_vector + 1
        lda     #<intro_backdrop        ; Read from compressed image data
        sta     load_vector
        lda     #>intro_backdrop
        sta     load_vector + 1

@decompress_loop:
        jsr     lda_and_advance
        cmp     #$DA
        beq     build_bitmap_row_addr_table
        cmp     #$00                    ; If the next byte is $00, $10, $FF, $E6, $16, or
        beq     @store_run              ; $50, then it is a run and the following byte contains
        cmp     #$10                    ; the number of times the value should be repeated
        beq     @store_run
        cmp     #$FF
        beq     @store_run
        cmp     #$E6
        beq     @store_run
        cmp     #$16
        beq     @store_run
        cmp     #$50
        beq     @store_run

        jsr     sta_and_advance
        jmp     @decompress_loop

@store_run:
        pha
        jsr     lda_and_advance
        tax
        pla
@loop:  jsr     sta_and_advance
        dex
        bne     @loop
        jmp     @decompress_loop




;-----------------------------------------------------------
;                       lda_and_advance
;
; Loads the value stored at the memory location pointed to 
; by 'load_vector' into the accumulator, then advances
; 'load_vector' by one.
;-----------------------------------------------------------

lda_and_advance:
load_vector     := * + 1
        lda     intro_backdrop
        inc     load_vector
        bne     @exit
        inc     load_vector + 1
@exit:  rts




;-----------------------------------------------------------
;                       sta_and_advance
;
; Stores the value in the accumulator into the memory
; location pointed to by 'store_vector', then advances
; 'store_vector' by one.
;-----------------------------------------------------------

sta_and_advance:
store_vector    := * + 1
        sta     bitmap_memory
        inc     store_vector
        bne     @exit
        inc     store_vector + 1
@exit:  rts




        ; Initialize data in $1200-$12BF, and $12C0-$137F to become a lookup table to
        ; find the address in memory where each row of pixels starts in the bitmap display.
        ;
        ; The bytes starting at $1200 contain the least significant byte of the address
        ; for each of 192 rows of pixels, starting with the top row.
        ;
        ; The bytes starting at $12C0 contain the most significant byte of the address
        ; for each row of pixels.
        ;
        ; The addresses are stored assuming the bitmap is located at $2000 in memory, so
        ; a constant would need to be added if the bitmap is located elsewhere (for
        ; example, add $2000 if the bitmap is located at $4000, as it is in the intro).

build_bitmap_row_addr_table:
        lda     #$00
        sta     bitmap_row_addr_table_low
        lda     #$20
        sta     bitmap_row_addr_table_high
        ldx     #$00
@loop:  lda     bitmap_row_addr_table_low,x
        clc
        adc     #$01
        inx
        sta     bitmap_row_addr_table_low,x                 
        and     #$07
        bne     @copy_next_high_byte

        dex
        lda     bitmap_row_addr_table_high,x
        clc
        adc     #$01
        inx
        sta     bitmap_row_addr_table_high,x
        lda     bitmap_row_addr_table_low,x
        and     #$F0
        clc
        adc     #$40
        sta     bitmap_row_addr_table_low,x
        bcc     @check_if_done
        inc     bitmap_row_addr_table_high,x
        jmp     @check_if_done

@copy_next_high_byte:
        dex
        lda     bitmap_row_addr_table_high,x
        inx
        sta     bitmap_row_addr_table_high,x

@check_if_done:
        cpx     #$BF
        bne     @loop




        ; Initializes data in $15B0-$15D7 and $15D8-$15FF to become a lookup table to
        ; find the offset in memory from the start of a row of pixels to a particular
        ; column in that row. The first entry in each table is used to find the left-
        ; most column, and the last entry to find the right-most column. Each table
        ; contains 40 entries, since each byte in memory contains 8 pixels (8 * 40 = 320).
        ;
        ; The table starting at $15B0 contains the least significant byte, and the
        ; the table starting at $15D8 contains the most significant byte.

build_bitmap_col_offset_table:
        lda     #$38
        sta     $5E
        lda     #$01
        sta     $5F
        ldx     #$27
@loop:  lda     $5E
        sta     bitmap_col_offset_table_low,x
        sec
        sbc     #$08
        sta     $5E
        lda     $5F
        sta     bitmap_col_offset_table_high,x
        sbc     #$00
        sta     $5F
        dex
        bpl     @loop




animate_intro_screen:
        inc     intro_loop_counter
        jsr     erase_sword_area
        jsr     erase_text_area
        jsr     setup_sprites
        jsr     enable_sprites
        jsr     update_horse_animation

        jsr     draw_studio_logo        ; Display "Origin Systems Presents"
        lda     #$00
        jsr     draw_text
        jsr     wait_6_seconds

        jsr     erase_text_area         ; Display "A new release of..."
        lda     #$01
        jsr     draw_text
        jsr     s6C17
        jsr     wait_6_seconds

        jsr     erase_text_area         ; Display "Lord British's..."
        lda     #$02
        jsr     draw_text
        jsr     wait_6_seconds
        jsr     wait_6_seconds

        jsr     erase_text_area         ; Animate "Ultima I"
        jsr     draw_title_logo
        jsr     s6A37
        jsr     wait_6_seconds
        jsr     s6AE0

        lda     #$20                    ; Pause for $400 frames (about 17 seconds), checking
        sta     pause_ctr               ; for keypresses every $20 frames (about half a second)
@pause_loop:
        lda     #$20
        sta     wait_frames_ctr
        jsr     wait_frames
        dec     pause_ctr
        bne     @pause_loop

        jsr     disable_sprites         ; Display the large Origin logo (still at $2000), and restart the intro
        lda     #$10                    ; Check for keypresses every quarter second ($10 frames), and stay here
        sta     pause_ctr               ; for a total of 4 seconds (256 frames).
@origin_loop:
        lda     #$10
        sta     wait_frames_ctr
        jsr     wait_for_key_press
        dec     pause_ctr
        bpl     @origin_loop
        jmp     animate_intro_screen




j6955:  jmp     j6955




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
        sta     $84
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
@loop6: lda     d7518,x
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




;-----------------------------------------------------------
;-----------------------------------------------------------

s6A37:  lda     #$00
        sta     temp_ptr
        sta     temp_ptr2
        tay
        lda     #$40
        sta     temp_ptr + 1
        lda     #$80
        sta     temp_ptr2 + 1
        ldx     #$20
b6A48:  lda     (temp_ptr),y
        sta     (temp_ptr2),y
        iny
        bne     b6A48
        inc     temp_ptr + 1
        inc     temp_ptr2 + 1
        dex
        bne     b6A48
        rts




;-----------------------------------------------------------
;                     draw_studio_logo
;
; Draws the Ultima logo on the screen from (152,56) to
; (256,77)
;-----------------------------------------------------------

draw_studio_logo:
        lda     #<studio_logo           ; Reset load address to start of data
        sta     @load_address
        lda     #>studio_logo
        sta     @load_address + 1

        ldx     #$38                    ; Copy onto rows 56 through 77

@next_x:ldy     #$13                    ; Get address for pixel (152,56)
        lda     bitmap_row_addr_table_low,x
        clc
        adc     bitmap_col_offset_table_low,y
        sta     temp_ptr
        lda     bitmap_row_addr_table_high,x
        adc     bitmap_col_offset_table_high,y
        adc     #$20
        sta     temp_ptr + 1

        ldy     #$00
@next_y:
@load_address   := * + 1
        lda     studio_logo             ; Copy 104 pixel wide row
        sta     (temp_ptr),y

        inc     @load_address           ; Advance the load address by 1
        bne     @same_page
        inc     @load_address + 1

@same_page:
        tya
        clc
        adc     #$08
        tay
        cpy     #$68
        bcc     @next_y

        inx                             ; Advance to next row
        cpx     #$4D
        bcc     @next_x
        rts




;-----------------------------------------------------------
;                       draw_title_logo
;
; Draws the title logo at (88, 48). The logo is 184 pixels
; wide and 48 pixels high.
;-----------------------------------------------------------

draw_title_logo:
        ldx     #$30                    ; Calculate address of (88, 48) and put in temp_ptr2
        ldy     #$0B
        lda     bitmap_row_addr_table_low,x
        clc
        adc     bitmap_col_offset_table_low,y
        sta     temp_ptr2
        lda     bitmap_row_addr_table_high,x
        adc     bitmap_col_offset_table_high,y
        adc     #$20
        sta     temp_ptr2 + 1

        lda     #<title_logo            ; Get starting address of Ultima logo
        sta     temp_ptr
        lda     #>title_logo
        sta     temp_ptr + 1

        ldx     #$06

b6AB7:  ldy     #$00                    ; Copy a 184x8 pixel block
@next_y:lda     (temp_ptr),y
        sta     (temp_ptr2),y
        iny
        cpy     #$B8
        bcc     @next_y

        lda     temp_ptr                ; Advance source pointer by 184 bytes
        clc
        adc     #$B8
        sta     temp_ptr
        lda     temp_ptr + 1
        adc     #$00
        sta     temp_ptr + 1

        lda     temp_ptr2               ; Advance target pointer by 320 bytes
        clc
        adc     #$40
        sta     temp_ptr2
        lda     temp_ptr2 + 1
        adc     #$01
        sta     temp_ptr2 + 1
        dex
        bne     b6AB7
        rts




;-----------------------------------------------------------
;-----------------------------------------------------------

s6AE0:  lda     #$70
        sec
        sbc     $7C
        tax
        lda     #$B5
        sta     d6B1D
        lda     #$76
        sta     d6B1E
        lda     #$A0
        sta     d6B1A
        lda     #$78
        sta     d6B1B
b6AFA:  ldy     #$1E
        lda     bitmap_row_addr_table_low + $14,x
        clc
        adc     bitmap_col_offset_table_low,y
        sta     temp_ptr
        sta     temp_ptr2
        lda     bitmap_row_addr_table_high + $14,x
        adc     bitmap_col_offset_table_high,y
        adc     #$20
        sta     temp_ptr + 1
        adc     #$40
        sta     temp_ptr2 + 1
        ldy     #$00
b6B17:  lda     (temp_ptr2),y
d6B1A           := * + 1
d6B1B           := * + 2
        and     d78A0
d6B1D           := * + 1
d6B1E           := * + 2
        ora     d76B5
        sta     (temp_ptr),y
        inc     d6B1D
        bne     b6B29
        inc     d6B1E
b6B29:  inc     d6B1A
        bne     b6B31
        inc     d6B1B
b6B31:  tya
        clc
        adc     #$08
        tay
        cpy     #$18
        bcc     b6B17
        inx
        cpx     #$71
        bcc     b6AFA
        lda     #$08
        sta     wait_frames_ctr
        jsr     wait_frames
        inc     $7C
        lda     $7C
        cmp     #$70
        bcs     b6B52
        jmp     s6AE0
b6B52:  ldx     #$54
        lda     #$0D
        sta     d6B78
        lda     #$78
        sta     d6B79
b6B5E:  ldy     #$1E
        lda     bitmap_row_addr_table_low + $14,x
        clc
        adc     bitmap_col_offset_table_low,y
        sta     temp_ptr2
        lda     bitmap_row_addr_table_high + $14,x
        adc     bitmap_col_offset_table_high,y
        adc     #$60
        sta     temp_ptr2 + 1
        ldy     #$00
b6B75:  lda     (temp_ptr2),y
d6B78           := * + 1
d6B79           := * + 2
        ora     d780D
        sta     (temp_ptr2),y
        inc     d6B78
        bne     b6B84
        inc     d6B79
b6B84:  tya
        clc
        adc     #$08
        tay
        cpy     #$18
        bcc     b6B75
        inx
        cpx     #$5F
        bcc     b6B5E
        lda     #$FF
        sta     $83
b6B96:  lda     #$35
        sta     d6BC2
        lda     #$78
        sta     d6BC3
        ldx     $7E
b6BA2:  ldy     #$1E
        lda     bitmap_row_addr_table_low + $68,x
        clc
        adc     bitmap_col_offset_table_low,y
        sta     temp_ptr
        sta     temp_ptr2
        lda     bitmap_row_addr_table_high + $68,x
        adc     bitmap_col_offset_table_high,y
        adc     #$20
        sta     temp_ptr + 1
        adc     #$40
        sta     temp_ptr2 + 1
        ldy     #$00
b6BBF:  lda     (temp_ptr2),y
d6BC2           := * + 1
d6BC3           := * + 2
        ora     d7835
        sta     (temp_ptr),y
        inc     d6BC2
        bne     b6BCE
        inc     d6BC3
b6BCE:  tya
        clc
        adc     #$08
        tay
        cpy     #$18
        bcc     b6BBF
        inx
        cpx     #$1D
        bcc     b6BA2
        lda     #$10
        sta     wait_frames_ctr
        jsr     wait_frames
        inc     $7E
        lda     $7E
        cmp     #$1D
        bcc     b6B96
        rts




;-----------------------------------------------------------
;                       erase_sword_area
;
; Erases (sets to zero) the bitmap from (240,20) to
; (271,116).
;-----------------------------------------------------------

erase_sword_area:
        ldx     #$60

@calculate_next_address:
        ldy     #$1E                    ; Calculate address of (240, x)
        lda     bitmap_row_addr_table_low + $14,x
        clc
        adc     bitmap_col_offset_table_low,y
        sta     temp_ptr
        lda     bitmap_row_addr_table_high + $14,x
        adc     bitmap_col_offset_table_high,y
        adc     #$20
        sta     temp_ptr + 1

        ldy     #$00
@loop:  lda     #$00                    ; Erase an 32x8 block
        sta     (temp_ptr),y
        tya
        clc
        adc     #$08
        tay
        cpy     #$18
        bne     @loop

        dex
        bpl     @calculate_next_address
        rts




;-----------------------------------------------------------
;-----------------------------------------------------------

s6C17:  lda     #$FE
        sta     $7F
        lda     #$7C
        sta     $80
        lda     #$00
        sta     $81
        lda     #$1E
        sta     VIC_SPR_BG_PRIO
b6C28:  lda     #$0A
        sta     wait_frames_ctr
        jsr     wait_frames
        ldx     $81
        inx
        cpx     #$03
        bcc     b6C39
        ldx     #$00
b6C39:  stx     $81
        lda     d6CCB,x
        tax
        ldy     #$2F
b6C41:  lda     d7AA3,x
        sta     sprite_1_image,y
        lda     d7A0B,x
        sta     sprite_2_image,y
        dex
        dey
        bpl     b6C41
        lda     $80
        sta     VIC_SPR1_Y
        sta     VIC_SPR2_Y
        lda     $7F
        clc
        adc     #$40
        sta     VIC_SPR1_X
        lda     VIC_SPR_HI_X
        and     #$FD
        bcc     b6C6A
        ora     #$02
b6C6A:  sta     VIC_SPR_HI_X
        lda     $7F
        clc
        adc     #$44
        sta     VIC_SPR2_X
        lda     VIC_SPR_HI_X
        and     #$FB
        bcc     b6C7E
        ora     #$04
b6C7E:  sta     VIC_SPR_HI_X
        lda     $81
        bne     b6C91
        dec     $80
        lda     $7F
        cmp     #$48
        bcs     b6C91
        inc     $80
        inc     $80
b6C91:  lda     $7F
        cmp     #$10
        bne     b6C9C
        lda     #$18
        sta     VIC_SPR_BG_PRIO
b6C9C:  dec     $7F
        dec     $7F
        bne     b6C28
        ldx     #$2F
b6CA4:  lda     d7B6B,x
        sta     sprite_1_image,x
        lda     d7B3B,x
        sta     sprite_2_image,x
        dex
        bpl     b6CA4
        lda     #$40
        sta     VIC_SPR2_X
        lda     #$47
        sta     VIC_SPR1_X
        lda     #$6E
        sta     VIC_SPR1_Y
        sta     VIC_SPR2_Y
        lda     #$FF
        sta     $82
        rts
        rts
d6CCB:  .byte   $2F,$5F,$8F




;-----------------------------------------------------------
;                       wait_6_seconds
;
; Pauses for 6 seconds (240 frames), while updating
; animations, then checks to see if the user is pressing a
; key to exit the intro page.
;
; This is a convenience method for putting $F0 into
; 'wait_frames_ctr', then calling 'wait_frames'.
;-----------------------------------------------------------

wait_6_seconds:
        lda     #$F0                    ; Set number of frames to pause for keypress to $F0
        sta     wait_frames_ctr




;-----------------------------------------------------------
;                       wait_frames
;
; Pauses for the number of frames stored in
; 'wait_frames_ctr', while updating animations, then
; checks to see if the user is pressing a key to exit the
; intro page.
;-----------------------------------------------------------

wait_frames:
        lda     VIC_CTRL1               ; Wait for raster to return to top of screen
        bpl     wait_frames
@wait_for_raster:
        lda     VIC_HLINE
        bne     @wait_for_raster

        inc     frame_ctr
        jsr     s6D2B
        jsr     update_horse_animation
        jsr     set_6444
        jsr     s6DA9
        dec     wait_frames_ctr
        bne     wait_frames
        beq     check_for_key_press




;-----------------------------------------------------------
;                   wait_for_key_press
;
; Waits for a short period, then checks to see if the user
; is pressing a key. If they are, exit the intro.
;
; The amount of delay before checking for a key press is
; set by placing a value in 'wait_frames_ctr'.
;-----------------------------------------------------------

wait_for_key_press:
        lda     VIC_CTRL1               ; Wait until raster line is past row 255
        bpl     wait_for_key_press
@wait_for_raster:
        lda     VIC_HLINE               ; Wait until raster line is back at top
        bne     @wait_for_raster

        ldx     #$00                    ; Delay
@delay: pha
        pla
        inx
        bne     @delay
        dec     wait_frames_ctr
        bne     wait_for_key_press

check_for_key_press:
        jsr     KERNEL_SCNKEY           ; Is the user pressing a key?
        jsr     KERNEL_GETIN
        cmp     #$00
        beq     @wait_for_user          ; If not, keep waiting
        jmp     exit_intro

@wait_for_user:
        rts

wait_frames_ctr:
        .byte   $40




;-----------------------------------------------------------
;                         set_6444
;
; Sets the byte at $6444 to either a $07 or $06, depending
; on the value stored in the 'frame_ctr' ($79).
;-----------------------------------------------------------

set_6444:
        lda     $82
        beq     @exit
        ldx     #$07
        lda     frame_ctr
        lsr
        lsr
        cmp     #$08
        bcc     @b6D27
        ldx     #$06
@b6D27: stx     sprite_1_image + 4
@exit:  rts




;-----------------------------------------------------------
;-----------------------------------------------------------

s6D2B:  lda     frame_ctr
        and     #$03
        beq     b6D32
        rts
b6D32:  inc     $7D
        lda     $7D
        cmp     #$09
        bcc     b6D3E
        lda     #$00
        sta     $7D
b6D3E:  tax
        inc     $7B
        lda     $7B
        and     #$07
        sta     $7B
        tay
        lda     d6D67,y
        tay
        lda     d6D6F,x
        sta     screen_memory,y
        lda     frame_ctr
        and     #$1F
        bne     b6D66
        lda     $51CD
        pha
        lda     $51CE
        sta     $51CD
        pla
        sta     $51CE
b6D66:  rts
d6D67:  .byte   $04,$0C,$20,$31,$48,$64,$68,$7E
d6D6F:  .byte   $10,$30,$10,$60,$30,$70,$00,$A0
        .byte   $10,$30,$00,$60,$30,$70,$10,$A0




;-----------------------------------------------------------
;                    update_horse_animation
;
; Selects the next frame of the horse animation to load into
; sprite 0. 
;-----------------------------------------------------------

update_horse_animation:
        lda     frame_ctr
        and     #$3F
        bne     return_from_routine

        inc     horse_anim_index        ; Select the next frame of animation
        ldx     horse_anim_index
        lda     horse_anim_frames,x
        bpl     @in_range

        lda     #$00                    ; Loop back to the first animation frame
        sta     horse_anim_index

@in_range:
        asl                             ; Get the pointer to the sprite image for the frame
        tax
        lda     horse_frame_ptrs,x
        sta     temp_ptr
        lda     horse_frame_ptrs + 1,x
        sta     temp_ptr + 1
        ldy     #$29
@loop:  lda     (temp_ptr),y
        sta     sprite_0_image,y
        dey
        bpl     @loop

return_from_routine:
        rts




;-----------------------------------------------------------
;-----------------------------------------------------------

s6DA9:  lda     $83
        beq     return_from_routine
        lda     intro_loop_counter
        and     #$03
        bne     return_from_routine
        lda     frame_ctr
        and     #$07
        bne     return_from_routine
        lda     $84
        and     #$01
        clc
        adc     #$93
        sta     sprite_5_ptr
        lda     $84
        clc
        adc     #$20
        sta     VIC_SPR5_X
        bcc     b6DD6
        lda     VIC_SPR_HI_X
        ora     #$20
        sta     VIC_SPR_HI_X
b6DD6:  inc     $84
        lda     $84
        cmp     #$48
        bcc     b6DE4
        lda     $85
        bpl     b6DE4
        dec     $84
b6DE4:  lda     $85
        bpl     b6E0F
        lda     $84
        cmp     #$10
        bcc     b6E0F
        cmp     #$1A
        bcc     b6E03
        cmp     #$30
        bcc     b6E0F
        cmp     #$3A
        bcs     b6E0F
        
        jsr     get_bitmap_value
        ora     #$40
        sta     (temp_ptr),y
        bne     b6E0F
b6E03:  lda     #$19
        sec
        sbc     $84
        jsr     get_bitmap_value
        and     #$BF
        sta     (temp_ptr),y
b6E0F:  rts




;-----------------------------------------------------------
;                      get_bitmap_value
;
; Gets the value stored in bitmap memory for one of 10
; possible addresses. The memory address will contain the
; pixel located a (56, 122 + (A & 0x0f)) where A is the
; value in the accumulator when the method is called. The
; value of that location in bitmap memory will be in the
; accumulator when the method returns.
;-----------------------------------------------------------

get_bitmap_value:
        and     #$0F
        asl     a
        tax
        lda     @addresses,x
        sta     temp_ptr
        lda     @addresses + 1,x
        sta     temp_ptr + 1
        ldy     #$00
        lda     (temp_ptr),y
        rts

@addresses:
        .addr   $52FA           ; (56,122)
        .addr   $52FB           ; (56,123)
        .addr   $52FC           ; (56,124)
        .addr   $52FD           ; (56,125)
        .addr   $52FE           ; (56,126)
        .addr   $52FF           ; (56,127)
        .addr   $5438           ; (56,128)
        .addr   $5439           ; (56,129)
        .addr   $543A           ; (56,130)
        .addr   $543B           ; (56,131)





