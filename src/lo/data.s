;-------------------------------------------------------------------------------
;
; data.s
;
;-------------------------------------------------------------------------------


.include "c64.inc"
.include "kernel.inc"

.export lo_font

.export origin_logo

        .setcpu "6502"

;-------------------------------------------------------------------------------
;
; The load address for this file is always set to $2000, but is ignored. The
; actual location where this code should be loaded into memory is $8000.
;
;-------------------------------------------------------------------------------

.segment "LOADADDR"

        .addr   $2000




.segment "FONT"

lo_font:
        .incbin "font.bin"




.data

origin_logo:
        .incbin "osibig.bin"




        .byte   $A9,$20,$AA,$85,$E3,$A9,$00,$A8
        .byte   $85,$E2,$91,$E2,$C8,$D0,$FB,$E6
        .byte   $E3,$CA,$D0,$F6,$20,$78,$15,$4C
        .byte   $75,$15
