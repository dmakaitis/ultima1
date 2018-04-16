;-------------------------------------------------------------------------------
;
; wait.s
;
; Code that handles waiting for a key press and making sure animations are 
; updated.
;
;-------------------------------------------------------------------------------

.include "c64.inc"
.include "kernel.inc"
.include "global.inc"
.include "in.inc"

.import exit_intro

.import update_horse_animation
.import animate_knight

.export wait_6_seconds
.export wait_frames
.export wait_for_key_press

.export wait_frames_counter

        .setcpu "6502"

.segment "CODE_WAIT"

;-----------------------------------------------------------
;                       wait_6_seconds
;
; Pauses for 6 seconds (240 frames), while updating
; animations, then checks to see if the user is pressing a
; key to exit the intro page.
;
; This is a convenience method for putting $F0 into
; 'wait_frames_counter', then calling 'wait_frames'.
;-----------------------------------------------------------

wait_6_seconds:
        lda     #240                    ; Set number of frames to pause for keypress to 240
        sta     wait_frames_counter




;-----------------------------------------------------------
;                       wait_frames
;
; Pauses for the number of frames stored in
; 'wait_frames_counter', while updating animations, then
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
        jsr     animate_stars
        jsr     update_horse_animation
        jsr     set_6444
        jsr     animate_knight
        dec     wait_frames_counter
        bne     wait_frames
        beq     check_for_key_press




;-----------------------------------------------------------
;                   wait_for_key_press
;
; Waits for a short period, then checks to see if the user
; is pressing a key. If they are, exit the intro.
;
; The amount of delay before checking for a key press is
; set by placing a value in 'wait_frames_counter'.
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
        dec     wait_frames_counter
        bne     wait_for_key_press

check_for_key_press:
        jsr     KERNEL_SCNKEY           ; Is the user pressing a key?
        jsr     KERNEL_GETIN
        cmp     #$00
        beq     @wait_for_user          ; If not, keep waiting
        jmp     exit_intro

@wait_for_user:
        rts

wait_frames_counter:
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




