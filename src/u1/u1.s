;-------------------------------------------------------------------------------
;
; u1.s
;
; This program simply blanks the screen, then loads the "hello" file into memory
; at $8000 and passes it control.
;
; This program is positioned so that when it is loaded into memory at $02d7,
; the BASIC idle loop vector is overwritten with the value $02d7. The result is
; that the program will immediately execute when loaded by typing:
;
;     LOAD "u1",8,1
;
; (or LOAD "*",8,1, assuming it is the first file on disk)
;-------------------------------------------------------------------------------

.include "c64.inc"
.include "kernel.inc"

.import main

        .setcpu "6502"

target          :=  $8000

; Ensure the first two bytes of the file are $02d7 so the c64 will read this
; into the correct location. For this to work, the linker will need to be
; configured so that the starting address is $02d7 (see u1.cfg).

.segment    "LOADADDR"

        .addr   $02D7

.segment "U1_CODE"

autoload:
        lda    #$00
        sta    VIC_CTRL1            ; disable screen
        sta    VIC_BORDERCOLOR      ; set border color to black

        lda    #$02                 ; logical number
        ldx    #$08                 ; device number
        ldy    #$00                 ; secondary address
        jsr    KERNEL_SETLFS

        lda    #$05                 ; filename length
        ldx    #<filename
        ldy    #>filename
        jsr    KERNEL_SETNAM

        lda    #$00                 ; load
        ldx    #<target         
        ldy    #>target
        jsr    KERNEL_LOAD

        jmp    target

.segment "U1_DATA"

filename:
       .byte   "HELLO"

basic_idle_loop_vector:
       .addr   autoload

basic_line_tokenizer_vector:
       .byte   $f1                  ; Not sure what this is for, if anything...