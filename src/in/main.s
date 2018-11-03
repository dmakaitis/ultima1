;-------------------------------------------------------------------------------
;
; main.s
;
; Main entry point of IN. Passes control to the intro initialization routine.
;
;-------------------------------------------------------------------------------

.include "c64.inc"
.include "kernel.inc"
.include "in.inc"

.export in_main

.import run_intro

        .setcpu "6502"

;-------------------------------------------------------------------------------
;
; The load address for this file is always set to $2000, but is ignored. The
; actual location where this code should be loaded into memory is $6800.
;
;-------------------------------------------------------------------------------

.segment    "LOADADDR"

        .addr   $2000




.code

in_main:
        jmp     run_intro
