;-------------------------------------------------------------------------------
;
; water.s
;
; Animates the water tile by rotating all the pixels one row down.
;
;-------------------------------------------------------------------------------

.import tile_images

.export animate_water

water_tile      := tile_images
water_q2        := water_tile + 8
water_q3        := water_tile + 16

        .setcpu "6502"

.segment "CODE_S168B"

;-----------------------------------------------------------
;                      animate_water
;
; Animates the water tile by rotating all the pixels one row
; down.
;-----------------------------------------------------------

animate_water:
        jsr     swap_water_q2_q3                        ; Reorganize the water tile to make it easier to scroll vertically

        ldx     #$0F                                    ; Do the scrolling
        jsr     scroll_water_down
        ldx     #$1F
        jsr     scroll_water_down

        ; continued below                               ; Restore the water tile to its normal layout




;-----------------------------------------------------------
;                      swap_water_q2_q3
;
; Swaps the upper right quarter of the water tile with the
; lower left. This happens twice when animating the water.
; The first time reorganizes the tile so each of two pairs
; of bytes in the water contains 16 vertical 8 pixel rows.
; The second time restores the tile to its normal format
; (8 8-pixel rows, followed by the 8 8-pixel rows to the
; right).
;-----------------------------------------------------------

swap_water_q2_q3:
        ldx     #$07                                    ; Swap eight pairs of bytes

@loop:  lda     water_q2,x                              ; Swap the two bytes
        ldy     water_q3,x
        sta     water_q3,x
        tya
        sta     water_q2,x
        dex                                             ; Loop through all eight pairs
        bpl     @loop

        rts



;-----------------------------------------------------------
;                     scroll_water_down
;
; Rotates a number of consecutive bytes so that the new
; value for each byte is equal to what the previous byte
; was, and the value of the first byte is equal to what the
; value of the last byte was in the previous frame.
;
; The x register should contain the index of the last byte
; to rotate, and must equal either 0x0f or 0x1f for the
; function to work properly.
;-----------------------------------------------------------

scroll_water_down:
        lda     water_tile,x                            ; Cache the value of the last byte
        pha

@loop:  dex                                             ; Get the previous byte...
        lda     water_tile,x
        inx                                             ; ...and copy it to the current location
        sta     water_tile,x
        dex

        bmi     @done                                   ; Loop until our counter is equal to either 0xff or 0x0f
        cpx     #$0F                                    ; (this could probably be optimized to do one less copy since
        bne     @loop                                   ; the final time copy the loop will get replaced by the code below)

@done:  inx                                             ; Update our counter to point back at the first location
        
        pla                                             ; Retrieve our cached last byte and place it into the first location
        sta     water_tile,x
        rts
