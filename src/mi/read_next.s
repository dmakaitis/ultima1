;-------------------------------------------------------------------------------
;
; read_next.s
;
; Routines for reading a byte and advancing the pointer to the next byte.
;
;-------------------------------------------------------------------------------

.include "c64.inc"

.export inc_then_read_ptr
.export read_then_inc_ptr

.export rts_ptr
.export read_ptr

        .setcpu "6502"

.segment "CODE_READ_NEXT"

;-----------------------------------------------------------
;                     inc_then_read_ptr
;
; Increments the rts pointer, then reads the byte located
; at the resulting address.
;-----------------------------------------------------------

inc_then_read_ptr:
        inc     rts_ptr
        bne     @read_byte
        inc     rts_ptr + 1
@read_byte:
rts_ptr         := * + 1
        lda     BASIC_BUF
        rts



;-----------------------------------------------------------
;                     read_then_inc_ptr
;
; Reads the byte located at the address pointed to by the
; read pointer, then increments the read pointer.
;-----------------------------------------------------------

read_then_inc_ptr:
read_ptr        := * + 1
        lda     BASIC_BUF
        inc     read_ptr
        bne     @done
        inc     read_ptr + 1
@done:  rts



