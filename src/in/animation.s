;-------------------------------------------------------------------------------
;
; animation.s
;
; Animation code for the knight (or car), horse, stars and bird.
;
;-------------------------------------------------------------------------------

.include "c64.inc"
.include "kernel.inc"
.include "macros.inc"
.include "in.inc"

.import intro_loop_counter
.import horse_frame_ptrs
.import horse_anim_frames

.export animate_horse
.export animate_knight
.export animate_bird_eye
.export animate_stars

        .setcpu "6502"

.segment "CODE_ANIMATION"

;-----------------------------------------------------------
;                     animate_bird_eye
;
; Sets the byte at $6444 to either a $07 or $06, depending
; on the value stored in the 'frame_ctr' ($79).
;-----------------------------------------------------------

animate_bird_eye:
        lda     bird_done_flag          ; Only animate the eye if the bird has landed already
        beq     @exit

        ldx     #$07

        lda     frame_ctr               ; Determine the value to write to the sprite image
        lsr
        lsr
        cmp     #$08
        bcc     @update_image
        ldx     #$06

@update_image:
        stx     sprite_1_image + 4

@exit:  rts




;-----------------------------------------------------------
;                       animate_stars
;
; Updates star colors to make them twinkle.
;-----------------------------------------------------------

animate_stars:
        lda     frame_ctr               ; Update once every 4 frames
        and     #$03
        beq     @update_counter
        rts

@update_counter:
        inc     star_ctr2               ; Cycle from 0 to 8, then repeat
        lda     star_ctr2
        cmp     #$09
        bcc     @update_stars

        lda     #$00                    ; Reset counter
        sta     star_ctr2

@update_stars:
        tax
        inc     star_ctr                ; Cycle from 0 to 7, then repeat
        lda     star_ctr
        and     #$07
        sta     star_ctr

        tay
        lda     @star_offsets,y
        tay
        lda     @star_colors,x
        sta     screen_memory,y

        lda     frame_ctr               ; Every 32 frames, make the castle flag wave by swapping
        and     #$1F                    ; the two bytes that comprise the flag in bitmap memory
        bne     @done                   ; (vertically swap pixels 72-49 on rows 117 and 118)

        lda     bitmap_memory + BITMAP_OFFSET 72, 117
        pha
        lda     bitmap_memory + BITMAP_OFFSET 72, 118
        sta     bitmap_memory + BITMAP_OFFSET 72, 117
        pla
        sta     bitmap_memory + BITMAP_OFFSET 72, 118

@done:  rts

@star_offsets:
        .byte   $04,$0C,$20,$31,$48,$64,$68,$7E

@star_colors:
        .byte   $10,$30,$10,$60,$30,$70,$00,$A0
        .byte   $10,$30,$00,$60,$30,$70,$10,$A0




;-----------------------------------------------------------
;                      animate_horse
;
; Selects the next frame of the horse animation to load into
; sprite 0. 
;-----------------------------------------------------------

animate_horse:
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

        ldy     #$29                    ; Copy the sprite image
@loop:  lda     (temp_ptr),y
        sta     sprite_0_image,y
        dey
        bpl     @loop

return_from_routine:
        rts




;-----------------------------------------------------------
;                       animate_knight
;
; Animates the knight (or car) that rides across the
; background, also updating the side door of the castle if 
; necessary.
;-----------------------------------------------------------

animate_knight:
        lda     knight_flag             ; Are we ready to animate the knight?
        beq     return_from_routine

        lda     intro_loop_counter      ; Only update every 4th time through the intro loop
        and     #$03
        bne     return_from_routine

        lda     frame_ctr               ; Only update every 8th frame
        and     #$07
        bne     return_from_routine

        lda     knight_ctr              ; Set sprite 5 pointer to either $93 or $94 to
        and     #$01                    ; animate the knight
        clc
        adc     #$93
        sta     sprite_5_ptr

        lda     knight_ctr              ; Update X coordinate of sprite 5 to 32 + counter
        clc
        adc     #32
        sta     VIC_SPR5_X
        bcc     @sprite_position_set

        lda     VIC_SPR_HI_X            ; Advance high bit of X coordinate for sprite 5
        ora     #$20
        sta     VIC_SPR_HI_X

@sprite_position_set:
        inc     knight_ctr              ; Update the knight counter
        lda     knight_ctr

        cmp     #72
        bcc     @update_door
        lda     car_flag
        bpl     @update_door
        dec     knight_ctr

@update_door:
        lda     car_flag                ; If we are animating the knight, then we are done at this point
        bpl     @done

        lda     knight_ctr

        cmp     #16                     ; Open door on frames 16-25
        bcc     @done
        cmp     #26
        bcc     @open_door

        cmp     #48                     ; Close door on frames 48-57
        bcc     @done
        cmp     #58
        bcs     @done
        
        jsr     get_bitmap_value        ; Animate the castle side door closing
        ora     #$40
        sta     (temp_ptr),y
        bne     @done

@open_door:
        lda     #$19                    ; Animate the castle side door opening
        sec
        sbc     knight_ctr
        jsr     get_bitmap_value
        and     #$BF
        sta     (temp_ptr),y

@done:  rts




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
