;-------------------------------------------------------------------------------
;
; The load address for most files is always set to $2000, but is ignored. The
; actual location where this code should be loaded into memory is stored in a
; lookup table in HELLO.
;
;-------------------------------------------------------------------------------

.segment "LOADADDR"

    .addr   $2000