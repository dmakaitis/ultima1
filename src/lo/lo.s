;-------------------------------------------------------------------------------
;
; lo.s
;
; Loads the game font, then displays the large studio logo.
;
;-------------------------------------------------------------------------------


.include "c64.inc"
.include "kernel.inc"

.import origin_logo

.export lo_main

        .setcpu "6502"
        
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




.code

;-----------------------------------------------------------
;                        display_logo
;
; Called by hello.prg after the system has been initialized.
;-----------------------------------------------------------

lo_main:
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
