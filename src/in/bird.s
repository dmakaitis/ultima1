;-------------------------------------------------------------------------------
;
; bird.s
;
; Code for animating the bird.
;
;-------------------------------------------------------------------------------

.include "c64.inc"
.include "kernel.inc"
.include "global.inc"
.include "in.inc"

.import wait_frames

.import wait_frames_counter

.import bird_body
.import bird_body_final
.import bird_head
.import bird_head_final

.export animate_bird

        .setcpu "6502"

.segment "CODE_BIRD"

;-----------------------------------------------------------
;                       animate_bird
;
; Animates the bird flying across the background under the
; title.
;-----------------------------------------------------------

animate_bird:
        lda     #254                    ; Set initial bird position
        sta     bird_x

        lda     #124
        sta     bird_y

        lda     #$00                    ; Reset bird animation to the first frame
        sta     bird_frame

        lda     #$1E                    ; Set sprites 0, 5, 6, and 7 to draw in front of bitmap
        sta     VIC_SPR_BG_PRIO

@loop:  lda     #10                     ; Wait for 10 frames
        sta     wait_frames_counter
        jsr     wait_frames

        ldx     bird_frame              ; Update bird frame (0 through 2, then repeats)
        inx
        cpx     #$03
        bcc     @save_bird_frame
        ldx     #$00
@save_bird_frame:
        stx     bird_frame

        lda     bird_frame_offsets,x
        tax

        ldy     #$2F                    ; Copy one of the three bird animation frames
@update_sprite_loop:
        lda     bird_head,x             ; Two sprites are combined so we can have a two color "sprite"
        sta     sprite_1_image,y
        lda     bird_body,x
        sta     sprite_2_image,y
        dex
        dey
        bpl     @update_sprite_loop

        lda     bird_y                  ; Set sprite Y positions
        sta     VIC_SPR1_Y
        sta     VIC_SPR2_Y

        lda     bird_x                  ; Set the bird head sprite position
        clc
        adc     #64                     ; Offset by 64 pixels
        sta     VIC_SPR1_X

        lda     VIC_SPR_HI_X            ; Set or clear the hi X position bit for the bird head sprite
        and     #$FD
        bcc     @set_hi_x_bit_1
        ora     #$02
@set_hi_x_bit_1:
        sta     VIC_SPR_HI_X

        lda     bird_x                  ; Set the bird body sprite position
        clc
        adc     #68                     ; Offset by 68 pixels
        sta     VIC_SPR2_X

        lda     VIC_SPR_HI_X            ; Set or clear the hi X position bit for the bird body sprite
        and     #$FB
        bcc     @set_hi_x_bit_2
        ora     #$04
@set_hi_x_bit_2:
        sta     VIC_SPR_HI_X

        lda     bird_frame              ; Every time we are on bird frame 0, adjust the Y position
        bne     @update_bird_priority
        dec     bird_y                  ; If X is greater than 68, then the bird should be flying up
        lda     bird_x
        cmp     #$48
        bcs     @update_bird_priority

        inc     bird_y                  ; After X passes 68, the bird should fly back down
        inc     bird_y

@update_bird_priority:
        lda     bird_x                  ; If X equals 16, make bird sprites appear in front of bitmap
        cmp     #$10
        bne     @update_bird_x

        lda     #$18                    ; Set sprites 0, 1, 2, 5, 6, and 7 to draw in front of bitmap
        sta     VIC_SPR_BG_PRIO

@update_bird_x:
        dec     bird_x                  ; Decrement X by two, and loop until it reaches zero.
        dec     bird_x
        bne     @loop

        ldx     #$2F                    ; Update the bird sprites to their final images
@update_sprite_end_loop:
        lda     bird_head_final,x
        sta     sprite_1_image,x
        lda     bird_body_final,x
        sta     sprite_2_image,x
        dex
        bpl     @update_sprite_end_loop

        lda     #64                     ; Set bird sprite end positions
        sta     VIC_SPR2_X
        lda     #71
        sta     VIC_SPR1_X
        lda     #110
        sta     VIC_SPR1_Y
        sta     VIC_SPR2_Y
        lda     #$FF
        sta     bird_done_flag
        rts
        rts

bird_frame_offsets:
        .byte   $2F,$5F,$8F
