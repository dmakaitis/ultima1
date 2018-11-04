;-------------------------------------------------------------------------------
;
; loadaddr.s
;
; Simply contains the two byte "load address" for the module. For most modules
; this is set to $2000, but is ignored by the file loading code.
;
;-------------------------------------------------------------------------------


        .setcpu "6502"

.segment "LOADADDR"

    .addr   $2000



