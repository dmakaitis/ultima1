;-------------------------------------------------------------------------------
;
; intro.s
;
; Main loop for the intro page.
;
;-------------------------------------------------------------------------------

.include "c64.inc"
.include "kernel.inc"
.include "global.inc"
.include "in.inc"

.import exit_intro
.import draw_text
.import erase_text_area
.import enable_sprites
.import disable_sprites
.import setup_sprites
.import animate_knight
.import update_horse_animation

.import intro_loop_counter

.import studio_logo
.import title_logo

.import sword
.import sword_mask
.import sword_hand

.import d7B3B
.import d7B6B
.import d7A0B
.import d7AA3
.import d7835

        .setcpu "6502"

.segment "CODE_INTRO"

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
        jsr     backup_bitmap_memory
        jsr     wait_6_seconds
        jsr     animate_sword

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




infinite_loop:
        jmp     infinite_loop           ; Does not look like this ever gets called (hopefully)




















.segment "CODE_INTRO2"

;-----------------------------------------------------------
;                    backup_bitmap_memory
;
; Copies bitmap memory to $8000.
;-----------------------------------------------------------

backup_bitmap_memory:
        lda     #<bitmap_memory         ; Set temp_ptr to $4000, and temp_ptr2 to $8000
        sta     temp_ptr
        sta     temp_ptr2
        tay
        lda     #>bitmap_memory
        sta     temp_ptr + 1
        lda     #>bitmap_backup
        sta     temp_ptr2 + 1

        ldx     #$20                    ; Copy $2000 bytes from temp_ptr to temp_ptr2
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

@next_x:
        ldy     #$00                    ; Copy a 184x8 pixel block
@next_y:
        lda     (temp_ptr),y
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
        bne     @next_x
        rts




;-----------------------------------------------------------
;                       animate_sword
;
; Animates the sword rising out of the lake to form part of
; the Ultima I logo.
;-----------------------------------------------------------

animate_sword:
        lda     #112                    ; X = 112 - value stored in the sword counter
        sec                             ; (probably top position of where to draw sword)
        sbc     sword_ctr
        tax

        lda     #<sword                 ; Setup pointers to data
        sta     @image_ptr
        lda     #>sword
        sta     @image_ptr + 1

        lda     #<sword_mask
        sta     @mask_ptr
        lda     #>sword_mask
        sta     @mask_ptr + 1

@next_x:
        ldy     #$1E                    ; Calculate address for (240, X) in both bitmap and bitmap backup
        lda     bitmap_row_addr_table_low + $14,x
        clc
        adc     bitmap_col_offset_table_low,y
        sta     temp_ptr
        sta     temp_ptr2
        lda     bitmap_row_addr_table_high + $14,x
        adc     bitmap_col_offset_table_high,y
        adc     #$20
        sta     temp_ptr + 1            ; temp_ptr has address in bitmap memory
        adc     #$40
        sta     temp_ptr2 + 1           ; temp_ptr2 has address in bitmap backup memory

        ldy     #$00

@next_y:
        lda     (temp_ptr2),y           ; Read pixels from backup memory,
@mask_ptr       := * + 1
        and     sword_mask              ; clear an area to draw the sword
@image_ptr      := * + 1
        ora     sword                   ; draw sword image
        sta     (temp_ptr),y

        inc     @image_ptr              ; Advance image pointer
        bne     @image_ptr_updated
        inc     @image_ptr + 1

@image_ptr_updated:
        inc     @mask_ptr               ; Advance mask pointer
        bne     @mask_ptr_updated
        inc     @mask_ptr + 1

@mask_ptr_updated:
        tya                             ; Advance right 8 pixels
        clc
        adc     #$08
        tay
        cpy     #$18
        bcc     @next_y

        inx                             ; Keep drawing until we have passed line 112
        cpx     #$71
        bcc     @next_x

        lda     #$08                    ; Wait for 8 frames
        sta     wait_frames_ctr
        jsr     wait_frames

        inc     sword_ctr               ; Update sword counter
        lda     sword_ctr
        cmp     #$70
        bcs     sword_done
        jmp     animate_sword




sword_done:
        ldx     #84                     ; X = row 84 in bitmap

        lda     #<sword_hand
        sta     @image_ptr
        lda     #>sword_hand
        sta     @image_ptr + 1

@next_x:
        ldy     #$1E                    ; Calculate address for (240, X) in bitmap backup
        lda     bitmap_row_addr_table_low + $14,x
        clc
        adc     bitmap_col_offset_table_low,y
        sta     temp_ptr2
        lda     bitmap_row_addr_table_high + $14,x
        adc     bitmap_col_offset_table_high,y
        adc     #$60
        sta     temp_ptr2 + 1

        ldy     #$00

@next_y:
        lda     (temp_ptr2),y           ; Write the sword hand into the bitmap backup
@image_ptr      := * + 1
        ora     sword_hand
        sta     (temp_ptr2),y

        inc     @image_ptr              ; Advance the image pointer
        bne     @image_ptr_updated
        inc     @image_ptr + 1

@image_ptr_updated:
        tya                             ; Advance right 8 pixels, for a total of 24 pixels copied
        clc
        adc     #$08
        tay
        cpy     #$18
        bcc     @next_y

        inx                             ; Advance to next row until row 95
        cpx     #95
        bcc     @next_x

        lda     #$FF
        sta     knight_flag
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
        jsr     animate_knight
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
; on the value stored in the 'frame_ctr' ($79). (part of 
; sprite 1 image?)
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




