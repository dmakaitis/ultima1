;-------------------------------------------------------------------------------
;
; bitmap.s
;
; Code for drawing, animating and erasing bitmap images.
;
;-------------------------------------------------------------------------------

.include "c64.inc"
.include "kernel.inc"
.include "global.inc"
.include "in.inc"

.import wait_frames

.import wait_frames_counter

.import studio_logo
.import title_logo

.import sword
.import sword_mask
.import sword_hand
.import hand

.export animate_sword
.export backup_bitmap_memory
.export draw_studio_logo
.export draw_title_logo
.export erase_sword_area

        .setcpu "6502"

.segment "CODE_BITMAP"

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

        ldx     #56                     ; Copy onto rows 56 through 77

@next_x:ldy     #(152 / 8)              ; Get address for pixel (152,56)
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
        adc     #8
        tay
        cpy     #104
        bcc     @next_y

        inx                             ; Advance to next row
        cpx     #77
        bcc     @next_x
        rts




;-----------------------------------------------------------
;                       draw_title_logo
;
; Draws the title logo at (88, 48). The logo is 184 pixels
; wide and 48 pixels high.
;-----------------------------------------------------------

draw_title_logo:
        ldx     #48                     ; Calculate address of (88, 48) and put in temp_ptr2
        ldy     #(88 / 8)
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
        ldy     #0                      ; Copy a 184x8 pixel block
@next_y:
        lda     (temp_ptr),y
        sta     (temp_ptr2),y
        iny
        cpy     #184
        bcc     @next_y

        lda     temp_ptr                ; Advance source pointer by 184 bytes
        clc
        adc     #184
        sta     temp_ptr
        lda     temp_ptr + 1
        adc     #0
        sta     temp_ptr + 1

        lda     temp_ptr2               ; Advance target pointer by 320 bytes
        clc
        adc     #<320
        sta     temp_ptr2
        lda     temp_ptr2 + 1
        adc     #>320
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
        ldy     #30                     ; Calculate address for (240, X) in both bitmap and bitmap backup
        lda     bitmap_row_addr_table_low + 20,x
        clc
        adc     bitmap_col_offset_table_low,y
        sta     temp_ptr
        sta     temp_ptr2
        lda     bitmap_row_addr_table_high + 20,x
        adc     bitmap_col_offset_table_high,y
        adc     #$20
        sta     temp_ptr + 1            ; temp_ptr has address in bitmap memory
        adc     #$40
        sta     temp_ptr2 + 1           ; temp_ptr2 has address in bitmap backup memory

        ldy     #0

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
        adc     #8
        tay
        cpy     #24
        bcc     @next_y

        inx                             ; Keep drawing until we have passed line 112
        cpx     #113
        bcc     @next_x

        lda     #8                      ; Wait for 8 frames
        sta     wait_frames_counter
        jsr     wait_frames

        inc     sword_ctr               ; Update sword counter
        lda     sword_ctr
        cmp     #112
        bcs     sword_done
        jmp     animate_sword




sword_done:
        ldx     #84                     ; X = row 84 in bitmap (starting at row 84 + 20 = 104)

        lda     #<sword_hand
        sta     @image_ptr
        lda     #>sword_hand
        sta     @image_ptr + 1

@next_x:
        ldy     #(240 / 8)              ; Calculate address for (240, X) in bitmap backup
        lda     bitmap_row_addr_table_low + 20,x
        clc
        adc     bitmap_col_offset_table_low,y
        sta     temp_ptr2
        lda     bitmap_row_addr_table_high + 20,x
        adc     bitmap_col_offset_table_high,y
        adc     #$60
        sta     temp_ptr2 + 1

        ldy     #0

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
        adc     #8
        tay
        cpy     #24
        bcc     @next_y

        inx                             ; Advance to next row until row 95
        cpx     #95
        bcc     @next_x

        lda     #$FF                    ; Signal the knight that it can now proceed
        sta     knight_flag




remove_hand:
        lda     #<hand                  ; Animate the hand going back into the lake
        sta     @image_ptr
        lda     #>hand
        sta     @image_ptr + 1

        ldx     hand_ctr                ; Start at pixel (240, 104 + hand_ctr)

@next_x:
        ldy     #(240 / 8)
        lda     bitmap_row_addr_table_low + 104,x
        clc
        adc     bitmap_col_offset_table_low,y
        sta     temp_ptr
        sta     temp_ptr2
        lda     bitmap_row_addr_table_high + 104,x
        adc     bitmap_col_offset_table_high,y
        adc     #$20
        sta     temp_ptr + 1            ; temp_ptr points to pixel in bitmap memory
        adc     #$40
        sta     temp_ptr2 + 1           ; temp_ptr points to same pixel in bitmap backup

        ldy     #0
@next_y:
        lda     (temp_ptr2),y           ; Load pixels from backup
@image_ptr      := * + 1
        ora     hand                    ; Add in the hand
        sta     (temp_ptr),y            ; Store it in bitmap memory

        inc     @image_ptr              ; Advance the image pointer
        bne     @advance_column
        inc     @image_ptr + 1

@advance_column:
        tya                             ; Advance to next 8 pixels in row
        clc
        adc     #8
        tay
        cpy     #24                     ; Copy 24 pixels total
        bcc     @next_y

        inx                             ; Advance to next row
        cpx     #29                     ; Draw 29 - hand_ctr rows
        bcc     @next_x

        lda     #16                     ; Wait for 16 frames
        sta     wait_frames_counter
        jsr     wait_frames

        inc     hand_ctr                ; Update the hand counter, and repeat until it is gone
        lda     hand_ctr
        cmp     #29
        bcc     remove_hand

        rts




;-----------------------------------------------------------
;                       erase_sword_area
;
; Erases (sets to zero) the bitmap from (240,20) to
; (263,116).
;-----------------------------------------------------------

erase_sword_area:
        ldx     #96

@calculate_next_address:
        ldy     #(240 / 8)              ; Calculate address of (240, x)
        lda     bitmap_row_addr_table_low + 20,x
        clc
        adc     bitmap_col_offset_table_low,y
        sta     temp_ptr
        lda     bitmap_row_addr_table_high + 20,x
        adc     bitmap_col_offset_table_high,y
        adc     #$20
        sta     temp_ptr + 1

        ldy     #0
@loop:  lda     #0                      ; Erase an 24x8 block
        sta     (temp_ptr),y
        tya
        clc
        adc     #8
        tay
        cpy     #24
        bne     @loop

        dex
        bpl     @calculate_next_address
        rts
