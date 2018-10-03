;-------------------------------------------------------------------------------
;
; init.s
;
; Initializes the VIC and SID chips and sets location of bitmap and screen 
; memory.
;
;-------------------------------------------------------------------------------

.include "c64.inc"

.export init_snd_gfx
.export do_nothing

CHAR_REV                := $1F
zp5B                    := $5B
INPUT_BUFFER_SIZE       := $56

SCRN_MEM                := $0400
SCRN_MEM2               := $6000

w1C7E                   := $ffff
w1C80                   := $ffff

        .setcpu "6502"

.segment "CODE_INIT"

;-----------------------------------------------------------
;                       init_snd_gfx
;
; Initializes the VIC and SID chips and sets location of
; bitmap and screen memory.
;-----------------------------------------------------------

init_snd_gfx:
        lda     #$01
        sta     SID_S3Lo
        lda     #$0F
        sta     SID_AD3
        lda     #$41
        sta     SID_Ctl3
        lda     #$8F
        sta     w1C80
        sta     w1C7E
        lda     #$FF
        sta     SID_SUR3
        lda     #$00
        sta     INPUT_BUFFER_SIZE
        sta     zp5B
        sta     CHAR_REV
        sta     CIA1_TOD10
        lda     #$18
        sta     VIC_VIDEO_ADR
        lda     #$08
        sta     VIC_CTRL2
        lda     #$37
        sta     VIC_CTRL1
        lda     #$00
        sta     VIC_BORDERCOLOR

        tax
        lda     #$10
@loop:  sta     SCRN_MEM,x
        sta     SCRN_MEM + $0100,x
        sta     SCRN_MEM + $0200,x
        sta     SCRN_MEM + $0300,x
        sta     SCRN_MEM2,x
        sta     SCRN_MEM2 + $0100,x
        sta     SCRN_MEM2 + $0200,x
        sta     SCRN_MEM2 + $0300,x
        inx
        bne     @loop
        cli
        rts

        

        .byte   $18,$60

do_nothing:
        rts
