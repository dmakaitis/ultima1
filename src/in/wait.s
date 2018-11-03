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
.include "in.inc"

.import exit_intro

.import animate_horse
.import animate_knight
.import animate_bird_eye
.import animate_stars

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
        jsr     animate_horse
        jsr     animate_bird_eye
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








