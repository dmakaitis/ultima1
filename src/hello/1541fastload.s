;-----------------------------------------------------------
; 1541fastload.s
;
; The following section will be copied out to the 1541
; drive, and contains the fastload code that will be
; executed on the 1541.
;-----------------------------------------------------------

        .setcpu "6502"


read_256_bytes:= $0146 + $000C
read_target_vector:= $0146 + $000C + $002E

BUFFER0_COMMAND:= $00

BUFFER0_TRACK:= $06
BUFFER0_SECTOR:= $07
EXPECTED_HEADER_ID:= $12
LAST_HEADER_ID:= $16
LAST_TRACK  := $18
LAST_SECTOR := $19
LAST_HEADER_CHECKSUM:= $1A
BUFFER_ADDR := $30
BUFFER_TRACK_SECTOR_ADDR:= $32
DATA_BLK_SIG:= $38
COMPUTED_CHECKSUM:= $3A
TEMP_REG    := $44
EXPECTED_DATA_BLK_SIG:= $47

BUFFER0     := $0300

VIA1_PORTB  := $1800
VIA1_TIMER  := $1804

VIA2_PORTB  := $1C00
VIA2_PORTA  := $1C01
VIA2_TIMER_LATCH:= $1C06
VIA2_AUX    := $1C0C

DOS_TURN_ON_LED:= $C118
DOS_GIVE_ERROR := $C1C8
DOS_READ_BAM := $D042
DOS_FILE_NOT_FOUND:= $D945
DOS_CALC_DATA_PARITY:= $F5E9

LF8E0           := $F8E0
DOS_ENCODE_BLOCK_HEADER:= $F934



__start_1541_fastload_code:

.segment "FASTLOAD_1541"
.org    $0500

        inc     read_target_vector + 1  ; Load the next 256 bytes of code from the C64
        jsr     read_256_bytes

        cli                             ; Enable interrupts

        jsr     DOS_TURN_ON_LED
        jsr     DOS_READ_BAM

        sei                             ; Disable interrupts

        lda     #$15                    ; Set timer latch?
        sta     VIA2_TIMER_LATCH + 1

        lda     #$03
        sta     $3C

        lda     #$12                    ; Load first sector of disk directory
        ldx     #$01

@load_directory_sector:
        jsr     read_sector

        ldx     #$07                    ; Start with the first directory entry in sector just read

@check_directory_entry:
        lda     directory_entry_offsets,x
        sta     $3B                     ; Word at $3B now holds the address in memory of the directory entry

        ldy     #$00                    ; Is the entry a properly closed PRG file?
        lda     ($3B),y
        cmp     #$82
        bne     @advance_to_next_entry

        ldy     #$03
@check_filename_char:
        lda     filename,y

        cmp     #$2A                    ; Are we trying to load the file '*'?
        beq     load_file               ; If so, accept the first file we find...

        cmp     #$3F                    ; Is the current character in the filename a '?'?
        beq     @matched_filename_char  ; If so, treat this as a match against the current character in directory entry
        cmp     ($3B),y                 ; Compare the current character with the directory entry
        bne     @advance_to_next_entry  ; If they do not match, go to the next entry

@matched_filename_char:
        iny
        cpy     #$12
        bne     @check_filename_char    ; Have we compared all 16 characters (18 - 2)?
        beq     load_file               ; If so, then this is the file we want

@advance_to_next_entry:
        dex
        bpl     @check_directory_entry
        ldx     BUFFER0 + 1             ; Get next sector
        lda     BUFFER0                 ; Get next track
        bne     @load_directory_sector

        lda     #$FF
        sta     $0300
        jsr     send_256_bytes
        lda     #$3A
        sta     VIA2_TIMER_LATCH + 1
        cli
        jmp     DOS_FILE_NOT_FOUND

directory_entry_offsets:  .byte   $E2,$C2,$A2,$82,$62,$42,$22,$02

load_file:
        ldy     #$02                    ; Get the first sector
        lda     ($3B),y
        tax
        dey                             ; Get the first track
        lda     ($3B),y

@load_file_sector:
        jsr     read_sector
        jsr     send_256_bytes
        ldx     BUFFER0 + 1             ; Get next sector
        lda     BUFFER0                 ; Get next track
        bne     @load_file_sector       ; If next track is not 0, then read next sector of file

        lda     #$F7
        and     VIA2_PORTB
        sta     VIA2_PORTB

        lda     #$3A
        sta     VIA2_TIMER_LATCH + 1

        rts




;-----------------------------------------------------------
;                       send_256_bytes
;
; Sends 256 bytes of data starting at $0300 over the serial
; line using the fast load protocol.
;-----------------------------------------------------------

send_256_bytes:
        ldy     #$00

@loop:  lda     BUFFER0,y               ; Load the upper four bits to write
        lsr
        lsr
        lsr
        lsr

        tax                             ; Lookup the encoding for the bits
        lda     serial_encoding_table,x
        tax

        lda     #$01                    ; Wait for the serial lines to be available
@wait_for_data_in_low:
        bit     VIA1_PORTB
        beq     @wait_for_data_in_low

        lda     #$08                    ; Signal that we're ready to send data
        sta     VIA1_PORTB

        lda     #$01                    ; Wait for C64 to signal it's ready to receive
@wait_for_data_in_high:
        bit     VIA1_PORTB
        bne     @wait_for_data_in_high

        stx     VIA1_PORTB              ; Send encoded bits
        txa
        asl     a
        and     #$0F
        sta     VIA1_PORTB

        lda     BUFFER0,y               ; Load the lower four bits to write
        and     #$0F

        tax                             ; Lookup the encoding for the bits
        lda     serial_encoding_table,x

        sta     VIA1_PORTB              ; Send encoded bits
        asl
        and     #$0F
        nop
        sta     VIA1_PORTB
        nop
        nop
        nop

        lda     #$00                    ; signal byte is complete
        sta     VIA1_PORTB

        iny
        bne     @loop
        rts

;-----------------------------------------------------------
; The following is a lookup table on how to encode four bits
; of data over the serial output lines. Each entry contains
; the two subsequent values that should be sent over each
; of the lines:
;
;   bit 0: second DATA OUT value
;   bit 1: first DATA OUT value
;   bit 2: second CLOCK OUT value
;   bit 3: first CLOCK OUT value
;-----------------------------------------------------------

serial_encoding_table:
        .byte   $00,$04,$01,$05,$08,$0C,$09,$0D
        .byte   $02,$06,$03,$07,$0A,$0E,$0B,$0F




;-----------------------------------------------------------
;                      read_sector
;
; Reads a sector of data from the disk. The accumulator
; should hold the track to read, and the x register should
; hold the sector. The read sector will be stored in
; buffer 0 located at $0300.
;-----------------------------------------------------------

read_sector:
        stx     BUFFER0_SECTOR          ; Store track/sector in buffer 0 track/status register
        sta     BUFFER0
        cmp     BUFFER0_TRACK
        php
        sta     BUFFER0_TRACK
        plp
        beq     @skip_read_sector_header    ; Branch if the track has not changed since last time

        lda     #$B0                    ; Set buffer 0 command/status to read in sector header
        sta     BUFFER0_COMMAND

        cli                             ; Enable interrupts to allow command to execute

@loop_wait_read_sector_header:
        bit     BUFFER0_COMMAND
        bmi     @loop_wait_read_sector_header

        sei                             ; Disable interrupts

        lda     BUFFER0_COMMAND         ; Make sure we read the data okay
        cmp     #$01
        bne     @handle_error

@skip_read_sector_header:
        lda     #$EE                    ; Attach byte ready line to CPU overflow flag
        sta     VIA2_AUX

        lda     #<BUFFER0_TRACK         ; Point buffer track/sector register to buffer 0
        sta     BUFFER_TRACK_SECTOR_ADDR
        lda     #>BUFFER0_TRACK
        sta     BUFFER_TRACK_SECTOR_ADDR + 1

                                        ; the high byte of BUFFER_TRACK_SECTOR_ADDR is the
                                        ; same as the low byte of BUFFER_ADDR, so we can 
                                        ; skip the extra LDA...

        sta     BUFFER_ADDR             ; Set read buffer to buffer 0 ($0300)
        lda     #>BUFFER0
        sta     BUFFER_ADDR + 1

        jsr     read_block_header

@loop_read_bytes:
        bvc     @loop_read_bytes        ; Wait for overflow flag to indicate data is ready
        clv

        lda     VIA2_PORTA              ; Read byte into buffer
        sta     BUFFER0,y
        iny
        bne     @loop_read_bytes

        ldy     #$BA                    ; Read bytes into GCR-decoding buffer at $01BA-$01FF
@loop_read_bytes2:
        bvc     @loop_read_bytes2
        clv

        lda     VIA2_PORTA
        sta     $0100,y
        iny
        bne     @loop_read_bytes2

        jsr     LF8E0                   ; Probably calculates the block signature for validation...
        lda     DATA_BLK_SIG
        cmp     EXPECTED_DATA_BLK_SIG
        beq     @data_block_signature_ok

        lda     #$22                    ; Send an error response
        bne     give_error

@data_block_signature_ok:
        jsr     DOS_CALC_DATA_PARITY
        cmp     COMPUTED_CHECKSUM
        beq     @checksum_ok

        lda     #$23                    ; Send an error response
        bne     give_error

@checksum_ok:
        lda     #$EC                    ; Detach byte ready line from overflow processor flag
        sta     VIA2_AUX
        rts

@handle_error:
        clc
        adc     #$18
give_error:
        sta     TEMP_REG
        lda     #$FF
        sta     BUFFER0
        jsr     send_256_bytes
        lda     #$3A
        sta     VIA2_TIMER_LATCH + 1
        lda     TEMP_REG
        jmp     DOS_GIVE_ERROR




;-----------------------------------------------------------
;                   read_block_header
;
; Reads a block header from the disk. This is a slightly
; modified version of the code in the 1541 ROM located at
; $F510.
;-----------------------------------------------------------

read_block_header:
        lda     EXPECTED_HEADER_ID      ; Read ID 1
        sta     LAST_HEADER_ID
        lda     EXPECTED_HEADER_ID + 1  ; Read ID 2
        sta     LAST_HEADER_ID + 1
        lda     BUFFER0_TRACK           ; Get track
        sta     LAST_TRACK
        lda     BUFFER0_SECTOR          ; Get sector
        sta     LAST_SECTOR
        lda     #$00                    ; Calculate parity for block header
        eor     LAST_HEADER_ID
        eor     LAST_HEADER_ID + 1
        eor     LAST_TRACK
        eor     LAST_SECTOR
        sta     LAST_HEADER_CHECKSUM
        jsr     DOS_ENCODE_BLOCK_HEADER ; and save

        ldx     #$5A                    ; 90 attempts
@read_header_byte:
        jsr     wait_for_sync

@wait_for_byte_ready:
        bvc     @wait_for_byte_ready
        clv
        lda     VIA2_PORTA              ; Read data from block header
        cmp     $24,y                   ; Compare with saved data
        beq     @header_byte_read_ok
        dex
        bne     @read_header_byte       ; Try again if we have attempts left over
        lda     #$20                    ; Send read error
        bne     give_error

@header_byte_read_ok:
        iny
        cpy     #$08                    ; Have we read 8 bytes yet?
        bne     @wait_for_byte_ready

wait_for_sync:
        lda     #$D0                    ; Start timer
        sta     VIA1_TIMER + 1
        lda     #$21
@loop:  bit     VIA1_TIMER + 1
        bpl     give_error              ; if timer run down, then error

        bit     VIA2_PORTB              ; SYNC signal
        bmi     @loop                   ; sync signal not found yet?

        lda     VIA2_PORTA              ; Read byte
        clv
filename:                               ; The filename data is really three bytes later (see note below)
        ldy     #$00
        rts

; The memory area immediately after this point will be used to hold the file name
; It will be referenced by using lda (filename),y, with y starting at the value 3
; which will result in the first byte after the RTS above.