;-------------------------------------------------------------------------------
;
; load_file.s
;
; Prints the border around the main menu screen.
;
;-------------------------------------------------------------------------------

.include "kernel.inc"

.export load_file_a
.export load_file_cached_a
.export check_drive_status

.export filename
.export file_start_address
.export file_end_address

.export write_filenames
.export write_start_addresses
.export write_end_addresses

PROCESSOR_PORT          := $01

        .setcpu "6502"

.segment "CODE_LOAD_FILE"

;-----------------------------------------------------------
;                     load_file_cached
; 
; Functions identically to load_file below, except if the
; index of the file to read is $05 ("OU"), then the file
; will be loaded from RAM instead of from disk.
;
; This is probably to allow the 'OU' file to be cached under
; KERNEL ROM to allow it to be reloaded quickly on demand.
;-----------------------------------------------------------

load_file_cached_a:
        cpx     #$05
        bne     load_file_a

        lda     PROCESSOR_PORT                          ; Disable KERNEL ROM
        and     #$FD
        sta     PROCESSOR_PORT

        lda     #$00                                    ; Copy 30 * 256 bytes from $E000-F7FF to $8C9E-$A49D
        tay
        sta     $60
        lda     #$E0
        sta     $61
        lda     #$9E
        sta     $62
        lda     #$8C
        sta     $63
        ldx     #$18
@loop:  lda     ($60),y
        sta     ($62),y
        iny
        bne     @loop
        inc     $61
        inc     $63
        dex
        bne     @loop

        lda     PROCESSOR_PORT                          ; Enable KERNEL ROM
        ora     #$02
        sta     PROCESSOR_PORT

        clc
        rts



;-----------------------------------------------------------
;                       load_file_a
;
; Loads one of the game files. The file to load is selected
; by the value in the x register, which may be one of the
; following:
;
;   00 : TC @ $4000 - ???
;   01 : MA @ $C700 - ???
;   02 : PL @ $6400 - ???
;   03 : FI @ $6420 - ???
;   04 : GE @ $8C9E - ???
;   05 : OU @ $E000 - ???
;   06 : DN @ $8C9E - ???
;   07 : TW @ $8C9E - ???
;   08 : CA @ $8C9E - ???
;   09 : SP @ $8C9E - ???
;   0a : TM @ $8C9E - ???
;   0b : ST @ $0C00 - Screen and Text routines
;   0c : IN @ $6800 - Displays Ultima I intro animation
;   0d : MI @ $7400 - ???
;   0e : LO @ $0800 - Display studio logo
;   0f : PR @ $12C0 - copy protection test file
;   10 : DD @ $B000 - disk driver selection
;   11 : RO @ $B000 - Character roster
;   12 : P0 @ $81E2 - Player save slot 1
;   13 : P1 @ $81E2 - Player save slot 2
;   14 : P2 @ $81E2 - Player save slot 3
;   15 : P3 @ $81E2 - Player save slot 4
;
; The file will be loaded into the memory location listed
; for the file above.
;
; The processor carry flag will be set if the status after
; reading the file is not $30, which indicates the read
; was successful.
;-----------------------------------------------------------

load_file_a:
        txa                                             ; x = x * 2
        asl     a
        tax

        lda     read_filenames,x                        ; Get the filename and start address
        sta     filename
        lda     read_filenames + 1,x
        sta     filename + 1
        lda     read_start_addresses,x
        sta     file_start_address
        lda     read_start_addresses + 1,x
        sta     file_start_address + 1

        lda     #$02                                    ; open the file and load it
        ldx     #$08
        ldy     #$00
        jsr     KERNEL_SETLFS
        lda     #$02
        ldx     #$95
        ldy     #$C5
        jsr     KERNEL_SETNAM
        lda     #$00
        ldx     file_start_address
        ldy     file_start_address + 1
        jsr     KERNEL_LOAD

check_drive_status:
        lda     #$00                                    ; Clear out file name
        jsr     KERNEL_SETNAM
        lda     #$0F                                    ; open 15,8,15
        tay
        ldx     #$08
        jsr     KERNEL_SETLFS
        jsr     KERNEL_OPEN
        ldx     #$0F                                    ; Read status from channel 15
        jsr     KERNEL_CHKIN
        jsr     KERNEL_CHRIN
        pha

        lda     #$0F                                    ; Close the channel and restore default I/O channels
        jsr     KERNEL_CLOSE
        jsr     KERNEL_CLRCHN

        pla
        cmp     #$30
        beq     LC58C
        sec
        rts




LC58C:  clc
        rts
        rts





.segment "DATA_FILE_METADATA"

file_start_address:
        .addr   $0000
file_end_address:
        .addr   $0000

        .byte   "S:"
filename:  
        .byte   "GM"




read_filenames:  
        .byte   "TC"
        .byte   "MA"
        .byte   "PL"
        .byte   "FI"

        .byte   "GE"
        .byte   "OU"
        .byte   "DN"
        .byte   "TW"

        .byte   "CA"
        .byte   "SP"
        .byte   "TM"
        .byte   "ST"                                    ; Screen and Text routines

        .byte   "IN"                                    ; Displays Ultima I intro animation
        .byte   "MI"
        .byte   "LO"                                    ; Displays Origin logo and loads intro
        .byte   "PR"                                    ; PR is for copy protection - reading this file should fail




write_filenames:
        .byte   "DD"
        .byte   "RO"
        .byte   "P0"
        .byte   "P1"
        .byte   "P2"
        .byte   "P3"




read_start_addresses:
        .addr   $4000
        .addr   $C700
        .addr   $6400
        .addr   $6420

        .addr   $8C9E
        .addr   $E000
        .addr   $8C9E
        .addr   $8C9E

        .addr   $8C9E
        .addr   $8C9E
        .addr   $8C9E
        .addr   $0C00

        .addr   $6800
        .addr   $7400
        .addr   $0800
        .addr   $12C0




write_start_addresses:
        .addr   $B000
        .addr   $B000
        .addr   $81E2
        .addr   $81E2
        .addr   $81E2
        .addr   $81E2
write_end_addresses:
        .addr   $B001
        .addr   $B040
        .addr   $83AC
        .addr   $83AC
        .addr   $83AC
        .addr   $83AC




        .byte   $00
