;-----------------------------------------------------------
;                _1541_fastload_bootstrap
;
; The following section will be copied out to the 1541 drive
; to bootstrap the fastload code. It contains enough code to
; handle receiving and decoding a 256 byte block of data
; over the CLOCK and DATA lines of the serial port, then 
; pass control to the received block.
;-----------------------------------------------------------

        .setcpu "6502"

read_buffer:= $103

code_target:=  $0500

VIA1_PORTB:= $1800

.segment "BOOTSTRAP_1541"
.org    $0146

        ldx     #$00                    ; Delay to allow C64 code to get ready to write
@loop_delay:
        dex
        bne     @loop_delay

        sei                             ; Disable interrupts to ensure exact timing

        jsr     read_256_bytes
        jmp     code_target             ; Jump to code that was just received




;-----------------------------------------------------------
;                       read_256_bytes
;
; Reads 256 bytes of data over the serial CLOCK and DATA
; lines. Instead of reading the data normally, four samples
; of both lines will be taken for each byte of data. Each
; sample will read the following bits of data:
;
;     SAMPLE  CLOCK    DATA
;       1       7       5
;       2       6       4
;       3       3       1
;       4       2       0
;
; Note this is different than how the C64 receives data as
; the data is encoded on each end in a manner that can be
; decoded on the other end the fastest based on available
; hardware.
;
; To ensure proper timing, interupts must be disabled prior
; to calling this routine. 
;-----------------------------------------------------------

read_256_bytes:
        ldy     #$00

        lda     #$08                    ; set clock out to signal the C64 that we are ready to receive
        sta     VIA1_PORTB

@loop_read_bytes:
        ldx     #$00                    ; wait for DATA IN to indicate the C64 is ready to send a byte
        lda     #$01
@loop_wait_for_c64:
        bit     VIA1_PORTB
        beq     @loop_wait_for_c64

        stx     VIA1_PORTB              ; initialize the serial port

        lda     VIA1_PORTB              ; read the first four bits and store in buffer
        asl
        nop
        eor     VIA1_PORTB
        asl
        asl
        asl
        asl
        sta     read_buffer

        lda     VIA1_PORTB              ; read the second four bits and combine with buffer
        asl
        nop
        eor     VIA1_PORTB
        eor     read_buffer

@read_target_vector:= * + 1

        sta     code_target,y           ; Store the byte into the target memory.
        iny
        bne     @loop_read_bytes
        rts



