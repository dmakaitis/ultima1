;-------------------------------------------------------------------------------
;
; lo.s
;
;-------------------------------------------------------------------------------


.include "c64.inc"
.include "kernel.inc"

        .setcpu "6502"

        .export display_logo
        
;-------------------------------------------------------------------------------
;
; The load address for this file is always set to $2000, but is ignored. The
; actual location where this code should be loaded into memory is $8000.
;
;-------------------------------------------------------------------------------

screen_memory   := $0400

bitmap_memory   := $2000

L6800           := $6800

load_file_cached:= $C480
load_file       := $C486




.segment    "LOADADDR"

        .addr   $2000

.code

        .incbin "lo/font.bin"




;-----------------------------------------------------------
;                        display_logo
;
; Called by hello.prg after the system has been initialized.
;-----------------------------------------------------------

display_logo:
        lda     #$00                    ; Disable screen
        sta     VIC_CTRL1

        ldx     #$20                    ; Fill memory $2000-$5FFF with $40
        stx     $FD
        lda     #$00
        tay
        sta     $FC
        ldx     #$40
@loop:  sta     ($FC),y
        iny
        bne     @loop
        inc     $FD
        dex
        bne     @loop

        lda     #$08                    ; $FE hold the number of blocks we need to copy
        sta     $FE

        lda     #$60                    ; Copy Origin logo to temporary buffer at $4000 (specifically $4660)
        sta     @store + 1                      
        lda     #$46                    ;     then $0C9E-$0EB5, then $0EB6-$10CD
        sta     @store + 2              ;     then $10CE-$12E5, then $12E6-$14FD
        lda     #<origin_logo           ;     then $14FE-$1715, then $1716-$192D
        sta     @load + 1               ;     then $192E-$1B45, then $1B46-$1D5D
        lda     #>origin_logo
        sta     @load + 2
@copy_block:
        ldx     #$02                    ; Copy $0118 bytes
        ldy     #$18
@load:  lda     $0C9E
@store: sta     $2500
        inc     @load + 1               ; Increment the source address by 1
        bne     @increment_store
        inc     @load + 2
@increment_store:
        inc     @store + 1              ; Increment the target address by 1
        bne     @advance
        inc     @store + 2
@advance:
        dey
        bne     @load
        dex
        bne     @load

        lda     @store + 1              ; Advance storage target by $28 bytes to $48A0
        clc
        adc     #$28
        sta     @store + 1
        lda     @store + 2
        adc     #$00
        sta     @store + 2

        dec     $FE
        bne     @copy_block             ; Copy 7 more times, each time advancing target start by $0240 bytes...

        ldx     #$00                    ; Initialize screen memory so the logo will be rendered in blue
        lda     #$60
@loop_color:
        sta     screen_memory,x
        sta     screen_memory + $0100,x
        sta     screen_memory + $0200,x
        sta     screen_memory + $02F0,x
        inx
        bne     @loop_color

        lda     #$00
        sta     VIC_BORDERCOLOR
        lda     #$37                    ; Enable bitmap mode
        sta     VIC_CTRL1
        lda     #$08                    ; Enable multicolor mode
        sta     VIC_CTRL2
        lda     #$18                    ; Select screen memory at $0400, bitmap at $2000
        sta     VIC_VIDEO_ADR

        jsr     disolve_logo

        ldx     #$05                    ; Cache the 'OU' file under KERNEL ROM
        jsr     load_file

        ldx     #$0C                    ; Load the 'IN' file
        jsr     load_file_cached

        jmp     L6800




.data

origin_logo:
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $03,$03,$06,$06,$0C,$0C,$18,$18
        .byte   $FF,$00,$00,$00,$00,$00,$01,$01
        .byte   $FF,$20,$60,$60,$C0,$C0,$80,$80
        .byte   $FF,$02,$06,$06,$0C,$0C,$18,$18
        .byte   $FF,$00,$00,$01,$03,$07,$0F,$1F
        .byte   $FF,$78,$F8,$F8,$F8,$F8,$F8,$F8
        .byte   $FF,$02,$06,$06,$0C,$0C,$18,$18
        .byte   $FF,$00,$00,$00,$00,$00,$01,$01
        .byte   $FF,$20,$60,$60,$C0,$C0,$80,$80
        .byte   $FF,$02,$06,$06,$0C,$0C,$18,$18
        .byte   $FF,$00,$00,$00,$00,$03,$0F,$1F
        .byte   $FF,$00,$00,$00,$FF,$FF,$FF,$00
        .byte   $FF,$00,$00,$00,$FF,$FF,$FF,$00
        .byte   $FF,$00,$00,$00,$C0,$E0,$F0,$78
        .byte   $FF,$00,$00,$00,$00,$00,$03,$07
        .byte   $FF,$00,$00,$00,$3F,$FF,$FF,$80
        .byte   $FF,$00,$00,$00,$FF,$FF,$FF,$00
        .byte   $FF,$00,$00,$00,$F0,$F8,$FE,$0E
        .byte   $FF,$00,$00,$00,$00,$00,$00,$00
        .byte   $FF,$00,$00,$00,$78,$78,$F0,$F0
        .byte   $FF,$00,$00,$00,$00,$01,$03,$07
        .byte   $FF,$00,$00,$00,$FF,$FF,$FF,$C0
        .byte   $FF,$00,$00,$00,$FF,$FF,$FF,$00
        .byte   $FF,$00,$00,$00,$E0,$F8,$FE,$1E
        .byte   $FF,$00,$00,$00,$00,$00,$00,$00
        .byte   $FF,$00,$00,$00,$78,$78,$F0,$F0
        .byte   $FF,$00,$00,$00,$00,$03,$03,$07
        .byte   $FF,$00,$00,$00,$00,$80,$80,$C0
        .byte   $FF,$00,$00,$00,$00,$00,$00,$00
        .byte   $FF,$00,$00,$00,$00,$3C,$3C,$78
        .byte   $FF,$00,$01,$01,$03,$03,$06,$06
        .byte   $C0,$C0,$80,$80,$00,$00,$00,$00
origin_logo2:
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$01,$01
        .byte   $30,$30,$7F,$60,$C0,$C0,$80,$80
        .byte   $03,$03,$FF,$06,$0C,$0C,$18,$18
        .byte   $00,$00,$FF,$00,$00,$00,$01,$01
        .byte   $30,$30,$FF,$60,$C0,$C0,$80,$80
        .byte   $3F,$7F,$FF,$0F,$0F,$1E,$1E,$3C
        .byte   $F8,$F8,$FF,$00,$00,$00,$01,$01
        .byte   $30,$30,$FF,$60,$C0,$C0,$80,$80
        .byte   $03,$03,$FF,$06,$0C,$0C,$18,$18
        .byte   $00,$00,$FF,$00,$00,$00,$01,$01
        .byte   $30,$30,$E0,$60,$C0,$C0,$80,$81
        .byte   $1E,$3C,$3C,$78,$78,$F0,$F0,$E0
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$01,$01,$03,$03,$07
        .byte   $78,$F0,$F0,$E0,$E0,$C0,$C0,$80
        .byte   $07,$0F,$0F,$1E,$1E,$3C,$3C,$78
        .byte   $80,$00,$00,$00,$00,$00,$00,$03
        .byte   $00,$00,$00,$00,$00,$00,$0F,$FF
        .byte   $1E,$1E,$3C,$3C,$38,$F8,$E0,$80
        .byte   $01,$01,$03,$03,$07,$07,$0F,$0F
        .byte   $E0,$E0,$C0,$C0,$80,$80,$00,$00
        .byte   $07,$0F,$0F,$1E,$1E,$3C,$3C,$78
        .byte   $C0,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $1E,$3C,$3C,$78,$78,$00,$00,$00
        .byte   $01,$01,$03,$03,$07,$07,$0F,$0F
        .byte   $E0,$E0,$C0,$C0,$80,$80,$00,$00
        .byte   $07,$0F,$0F,$1F,$1F,$3C,$3C,$78
        .byte   $C0,$E0,$E0,$F0,$F0,$78,$78,$3C
        .byte   $00,$00,$00,$01,$01,$03,$03,$07
        .byte   $78,$F0,$F0,$E0,$E0,$C0,$C0,$80
        .byte   $0C,$0C,$18,$18,$30,$30,$60,$60
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
origin_logo3:
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $03,$03,$06,$06,$0F,$0C,$18,$18
        .byte   $00,$00,$00,$00,$FF,$00,$01,$03
        .byte   $30,$30,$60,$60,$FF,$C0,$80,$80
        .byte   $03,$03,$06,$06,$FF,$0C,$18,$18
        .byte   $00,$00,$00,$00,$FF,$01,$01,$03
        .byte   $3C,$78,$78,$F0,$FF,$E0,$E0,$C0
        .byte   $03,$03,$06,$06,$FF,$0C,$18,$18
        .byte   $00,$00,$00,$00,$FF,$00,$01,$01
        .byte   $30,$30,$60,$60,$FF,$C0,$C0,$C0
        .byte   $03,$03,$06,$06,$FC,$0C,$18,$18
        .byte   $01,$03,$03,$07,$07,$0F,$0F,$1E
        .byte   $E0,$C0,$C0,$80,$80,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $07,$0F,$0F,$1E,$1E,$3C,$3C,$78
        .byte   $80,$00,$00,$01,$01,$03,$03,$07
        .byte   $78,$F0,$E0,$E0,$E0,$C0,$C0,$80
        .byte   $0F,$1F,$1E,$0E,$0F,$07,$03,$01
        .byte   $F8,$80,$00,$00,$80,$80,$E0,$F0
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $1E,$1E,$3C,$3C,$78,$78,$F0,$F0
        .byte   $00,$00,$00,$01,$01,$03,$03,$07
        .byte   $78,$F0,$F0,$E0,$E0,$C0,$C0,$80
        .byte   $00,$03,$03,$03,$00,$00,$00,$00
        .byte   $00,$FF,$FF,$FF,$0F,$0F,$0F,$0F
        .byte   $00,$C0,$C0,$C0,$80,$80,$00,$00
        .byte   $1E,$1E,$3C,$3C,$78,$78,$F0,$F0
        .byte   $00,$00,$00,$01,$01,$03,$03,$07
        .byte   $78,$F0,$F0,$E0,$E0,$C0,$C0,$80
        .byte   $3C,$1E,$1E,$0F,$0F,$07,$07,$03
        .byte   $07,$0F,$0F,$1E,$1E,$BC,$BC,$F8
        .byte   $80,$00,$01,$01,$03,$03,$06,$06
        .byte   $C0,$C0,$80,$80,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
origin_logo4:
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$01
        .byte   $30,$30,$60,$63,$8F,$3F,$FF,$FF
        .byte   $0F,$3F,$FE,$FE,$FC,$FF,$FF,$FF
        .byte   $00,$00,$00,$00,$00,$FF,$FF,$FF
        .byte   $30,$30,$60,$60,$C0,$FF,$FF,$FF
        .byte   $03,$07,$07,$0F,$0F,$FF,$FF,$FF
        .byte   $C0,$80,$80,$00,$00,$FF,$FF,$FF
        .byte   $30,$30,$60,$60,$C0,$FF,$FF,$FF
        .byte   $03,$03,$07,$07,$0F,$FF,$FF,$FF
        .byte   $E0,$F0,$F8,$FC,$FE,$FF,$FF,$FF
        .byte   $30,$30,$60,$60,$40,$00,$80,$00
        .byte   $1E,$3C,$3C,$1F,$0F,$07,$00,$00
        .byte   $00,$00,$00,$FF,$FF,$FF,$00,$00
        .byte   $00,$00,$01,$FF,$FF,$FE,$00,$00
        .byte   $78,$F0,$F0,$E0,$80,$00,$00,$00
        .byte   $07,$0F,$0F,$1E,$1E,$1E,$00,$00
        .byte   $80,$00,$00,$00,$00,$00,$00,$00
        .byte   $01,$00,$00,$00,$00,$00,$00,$00
        .byte   $F0,$F8,$78,$78,$38,$38,$00,$00
        .byte   $01,$01,$03,$03,$07,$07,$00,$00
        .byte   $E0,$E0,$C0,$C0,$80,$80,$00,$00
        .byte   $07,$0F,$0F,$0F,$03,$00,$00,$00
        .byte   $80,$00,$00,$FF,$FF,$FF,$00,$00
        .byte   $00,$00,$00,$FF,$FF,$FF,$00,$00
        .byte   $0E,$3C,$78,$F0,$E0,$C0,$00,$00
        .byte   $01,$01,$03,$03,$07,$07,$00,$00
        .byte   $E0,$E0,$C0,$C0,$80,$80,$00,$00
        .byte   $07,$0F,$0F,$1E,$1E,$1E,$00,$00
        .byte   $80,$00,$00,$00,$00,$00,$00,$00
        .byte   $03,$01,$01,$00,$00,$00,$00,$00
        .byte   $F8,$F0,$F0,$E0,$E0,$E0,$00,$00
        .byte   $0C,$0C,$18,$18,$30,$30,$60,$60
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
origin_logo5:
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $02,$02,$06,$06,$0C,$0C,$18,$18
        .byte   $FF,$3F,$0F,$03,$00,$00,$01,$01
        .byte   $F0,$F0,$E0,$E0,$C0,$C0,$80,$80
        .byte   $03,$03,$06,$06,$0C,$0C,$18,$18
        .byte   $00,$00,$00,$00,$00,$01,$01,$03
        .byte   $3C,$78,$78,$F0,$F0,$E0,$E0,$C0
        .byte   $03,$03,$06,$06,$0C,$0C,$18,$18
        .byte   $00,$00,$00,$00,$00,$00,$01,$01
        .byte   $7F,$7F,$7F,$7E,$F8,$E0,$C0,$80
        .byte   $F8,$E2,$86,$06,$0C,$0C,$18,$18
        .byte   $00,$00,$00,$00,$00,$00,$03,$0F
        .byte   $00,$00,$00,$00,$00,$00,$F8,$F8
        .byte   $00,$00,$00,$00,$00,$00,$38,$38
        .byte   $00,$00,$00,$00,$00,$00,$38,$38
        .byte   $00,$00,$00,$00,$00,$00,$0F,$3F
        .byte   $00,$00,$00,$00,$00,$00,$E0,$E0
        .byte   $00,$00,$00,$00,$00,$00,$FF,$FF
        .byte   $00,$00,$00,$00,$00,$00,$F0,$F0
        .byte   $00,$00,$00,$00,$00,$00,$FF,$FF
        .byte   $00,$00,$00,$00,$00,$00,$C3,$C3
        .byte   $00,$00,$00,$00,$00,$00,$80,$80
        .byte   $00,$00,$00,$00,$00,$00,$3C,$7C
        .byte   $00,$00,$00,$00,$00,$00,$0F,$3F
        .byte   $00,$00,$00,$00,$00,$00,$E0,$E0
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$F0,$F0
        .byte   $00,$00,$00,$00,$00,$00,$E3,$E3
        .byte   $00,$00,$00,$00,$00,$00,$80,$83
        .byte   $00,$00,$00,$00,$00,$00,$F8,$F8
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$01,$01,$03,$03,$06,$06
        .byte   $C0,$C0,$80,$80,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
origin_logo6:
        .byte   $00,$00,$00,$00,$00,$00,$01,$01
        .byte   $3F,$30,$60,$60,$C0,$C0,$80,$80
        .byte   $FF,$03,$06,$06,$0C,$0C,$18,$18
        .byte   $FF,$00,$00,$00,$00,$00,$01,$01
        .byte   $FF,$30,$60,$60,$C0,$C0,$80,$80
        .byte   $FF,$07,$07,$0F,$0F,$1E,$1E,$3C
        .byte   $FF,$80,$80,$00,$00,$00,$01,$01
        .byte   $FF,$30,$60,$60,$C0,$C0,$80,$80
        .byte   $FF,$03,$06,$06,$0C,$0C,$18,$18
        .byte   $FF,$00,$00,$00,$00,$00,$01,$01
        .byte   $F0,$30,$60,$60,$C0,$C0,$80,$80
        .byte   $1E,$38,$38,$3E,$0F,$07,$03,$00
        .byte   $00,$00,$00,$00,$80,$C0,$E0,$E0
        .byte   $70,$70,$E0,$E0,$FF,$FF,$1E,$1E
        .byte   $70,$70,$E0,$E0,$C0,$C0,$00,$00
        .byte   $78,$F0,$E0,$F8,$3E,$1F,$0F,$07
        .byte   $00,$00,$00,$00,$00,$00,$80,$80
        .byte   $0F,$0F,$1E,$1E,$3C,$3C,$78,$78
        .byte   $01,$01,$03,$03,$07,$07,$0F,$0F
        .byte   $E0,$E0,$C0,$C0,$FE,$FE,$00,$00
        .byte   $03,$07,$07,$0F,$0F,$1E,$1E,$3C
        .byte   $E0,$E3,$FF,$7E,$78,$01,$01,$03
        .byte   $FC,$F8,$F8,$F0,$F0,$E0,$E0,$C0
        .byte   $38,$F0,$E0,$F8,$3E,$0F,$0F,$07
        .byte   $00,$00,$00,$00,$00,$00,$80,$80
        .byte   $01,$01,$03,$03,$07,$07,$0F,$0F
        .byte   $E1,$E1,$C3,$C3,$83,$87,$07,$0F
        .byte   $F3,$F3,$FB,$FB,$FF,$BE,$BE,$3C
        .byte   $83,$87,$07,$0E,$0E,$1C,$1C,$38
        .byte   $80,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $0C,$0C,$18,$18,$30,$30,$60,$60
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
origin_logo7:
        .byte   $03,$03,$07,$06,$0C,$0C,$18,$18
        .byte   $00,$00,$FF,$00,$00,$00,$01,$01
        .byte   $30,$30,$FF,$60,$C0,$C0,$80,$80
        .byte   $03,$03,$FF,$06,$0C,$0C,$18,$18
        .byte   $00,$00,$FF,$1F,$1F,$1F,$1F,$1F
        .byte   $3C,$78,$FF,$FE,$FC,$F8,$F0,$E0
        .byte   $03,$03,$FF,$06,$0C,$0C,$18,$18
        .byte   $00,$00,$FF,$00,$00,$00,$01,$01
        .byte   $30,$30,$FF,$60,$C0,$C0,$80,$80
        .byte   $03,$03,$FE,$06,$0C,$0C,$18,$18
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$03,$FF,$FE,$00,$00,$00,$00
        .byte   $E0,$C0,$80,$00,$00,$00,$00,$00
        .byte   $3C,$3C,$78,$78,$00,$00,$00,$00
        .byte   $00,$00,$03,$03,$00,$00,$00,$00
        .byte   $03,$0F,$FE,$F8,$00,$00,$00,$00
        .byte   $80,$00,$01,$01,$00,$00,$00,$00
        .byte   $F0,$F0,$E0,$E0,$00,$00,$00,$00
        .byte   $1E,$1E,$3F,$3F,$00,$00,$00,$00
        .byte   $00,$00,$F8,$F8,$00,$00,$00,$00
        .byte   $3C,$78,$78,$78,$00,$00,$00,$00
        .byte   $03,$07,$07,$07,$00,$00,$00,$00
        .byte   $C0,$80,$83,$83,$00,$00,$00,$00
        .byte   $03,$0F,$FE,$F8,$00,$00,$00,$00
        .byte   $80,$00,$00,$00,$00,$00,$00,$00
        .byte   $1E,$1E,$3C,$3C,$00,$00,$00,$00
        .byte   $0F,$0E,$0E,$0E,$00,$00,$00,$00
        .byte   $3C,$38,$38,$38,$00,$00,$00,$00
        .byte   $38,$38,$3F,$0F,$00,$00,$00,$00
        .byte   $00,$00,$83,$83,$00,$00,$00,$00
        .byte   $00,$00,$01,$01,$03,$03,$06,$06
        .byte   $C0,$C0,$80,$80,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
origin_logo8:
        .byte   $30,$30,$60,$60,$FF,$00,$00,$00
        .byte   $03,$03,$06,$06,$FF,$00,$00,$00
        .byte   $00,$00,$00,$00,$FF,$00,$00,$00
        .byte   $30,$30,$60,$60,$FF,$00,$00,$00
        .byte   $1F,$1F,$1F,$1E,$FF,$00,$00,$00
        .byte   $C0,$80,$00,$00,$FF,$00,$00,$00
        .byte   $30,$30,$60,$60,$FF,$00,$00,$00
        .byte   $03,$03,$06,$06,$FF,$00,$00,$00
        .byte   $00,$00,$00,$00,$FF,$00,$00,$00
        .byte   $30,$30,$60,$60,$FF,$00,$00,$00
        .byte   $00,$00,$00,$00,$FF,$00,$00,$00
        .byte   $00,$00,$00,$00,$FF,$00,$00,$00
        .byte   $00,$00,$00,$00,$FF,$00,$00,$00
        .byte   $00,$00,$00,$00,$FF,$00,$00,$00
        .byte   $00,$00,$00,$00,$FF,$00,$00,$00
        .byte   $00,$00,$00,$00,$FF,$00,$00,$00
        .byte   $00,$00,$00,$00,$FF,$00,$00,$00
        .byte   $00,$00,$00,$00,$FF,$00,$00,$00
        .byte   $00,$00,$00,$00,$FF,$00,$00,$00
        .byte   $00,$00,$00,$00,$FF,$00,$00,$00
        .byte   $00,$00,$00,$00,$FF,$00,$00,$00
        .byte   $00,$00,$00,$00,$FF,$00,$00,$00
        .byte   $00,$00,$00,$00,$FF,$00,$00,$00
        .byte   $00,$00,$00,$00,$FF,$00,$00,$00
        .byte   $00,$00,$00,$00,$FF,$00,$00,$00
        .byte   $00,$00,$00,$00,$FF,$00,$00,$00
        .byte   $00,$00,$00,$00,$FF,$00,$00,$00
        .byte   $00,$00,$00,$00,$FF,$00,$00,$00
        .byte   $00,$00,$00,$00,$FF,$00,$00,$00
        .byte   $00,$00,$00,$00,$FF,$00,$00,$00
        .byte   $0C,$0C,$18,$18,$F0,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00




        .byte   $A9,$20,$AA,$85,$E3,$A9,$00,$A8
        .byte   $85,$E2,$91,$E2,$C8,$D0,$FB,$E6
        .byte   $E3,$CA,$D0,$F6,$20,$78,$15,$4C
        .byte   $75,$15




;-----------------------------------------------------------
;                       disolve_logo
;
; Disolves the Origin logo, located at $4667 in memory, onto
; the bitmap display located at $2000 in memory. The upper
; left corner of the logo will be displayed at $2667.
;-----------------------------------------------------------

.segment "CODE2"

disolve_logo:
        ldx     #$FF                    ; $E0 = $FFFF, $E7 = $0000
        stx     $E0
        stx     $E1
        inx
        stx     $E7                         
        stx     $E8

@loop:  lsr     $E1
        ror     $E0
        bcc     @update_low_byte

        lda     $E1                     ; Keep high byte of address in range
        eor     #$B4
        sta     $E1

@update_low_byte:
        lda     $E0                     ; Update low byte of address
        sta     $E2
        sta     $E5
        lda     $E1
        and     #$1F

        cmp     #$06                    ; Make sure we've selected an address within our logo range
        bcc     @next
        cmp     #$11
        bcs     @next

        clc                             ; Store high bit of addresses
        adc     #$20
        sta     $E3                     ; $E2 points to random location between $2600 and $31FF (bitmap memory)
        adc     #$20
        sta     $E6                     ; $E5 points to location exactly $2000 bytes above $E2

        lda     $E1                     ; Use bits 4-6 in $E1 to pick a number from 0-7 and put in Y
        and     #$E0
        rol
        rol
        rol
        rol
        tay

        sec                             ; Place bit in bit 7 - Y
        lda     #$00
@loop_ror:
        ror
        dey
        bpl     @loop_ror

        iny                             ; Y = 0

        tax
        and     ($E5),y                 ; If the value has not change, skip to the next iteration
        beq     @next
        sta     $E9
        txa

        eor     #$FF                    ; Turn on the selected bit in the output
        and     ($E2),y
        ora     $E9
        sta     ($E2),y

@next:  inc     $E7                     ; loop 65536 times
        bne     @loop
        inc     $E8
        bne     @loop

        lda     $4000
        sta     bitmap_memory
        rts




        .byte   $CE
