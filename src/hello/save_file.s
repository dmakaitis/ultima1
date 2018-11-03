;-------------------------------------------------------------------------------
;
; save_file.s
;
; Saves one of the game files.
;
;-------------------------------------------------------------------------------

.include "kernel.inc"

.export save_file_a

.export selected_character

.import check_drive_status

.import filename
.import file_start_address
.import file_end_address

.import write_filenames
.import write_start_addresses
.import write_end_addresses

        .setcpu "6502"

.segment "CODE_SAVE_FILE"

        ; The code below looks like it would never get executed, but if it did, it would probably save file "P0"...
;-----------------------------------------------------------
;                   save_selected_character
;
; Saves the character data for the currently selected
; character slot.
;-----------------------------------------------------------

save_selected_character:

        ldx     selected_character                      ; x := selected_character + 2
        inx
        inx

        ; continued in save_file



;-----------------------------------------------------------
;                         save_file
;
; Saves one of the game files. The file to save is selected
; by the value in the x register, which may be one of the
; following:
;
;   0 : DD @ $B000-$B001 - Disk driver selection
;   1 : RO @ $B000-$B040 - Character roster
;   2 : P0 @ $81E2-$83AC - Player save slot 1
;   3 : P1 @ $81E2-$83AC - Player save slot 2
;   4 : P2 @ $81E2-$83AC - Player save slot 3
;   5 : P3 @ $81E2-$83AC - Player save slot 4
;
; The memory range saved for each file is listed above.
;-----------------------------------------------------------

save_file_a:
        txa                                             ; x = x * 2
        asl
        tax

        lda     write_filenames,x                       ; Load the two character filename into memory at $C595
        sta     filename                                ; $C593 already holds the characters 'S:', so the result
        lda     write_filenames + 1,x                   ; will be a DOS command to delete the file at $C593
        sta     filename + 1

        lda     write_start_addresses,x                 ; Get start address of data to save
        sta     file_start_address
        lda     write_start_addresses + 1,x
        sta     file_start_address + 1

        lda     write_end_addresses,x                   ; Get end address of data to save (+1)
        sta     file_end_address
        lda     write_end_addresses + 1,x
        sta     file_end_address + 1

        ;-----------------------------------------------------------
        ; Delete the requested file
        ;-----------------------------------------------------------

        lda     #$04                                    ; Set filename to four characters at $C593
        ldx     #$93
        ldy     #$C5
        jsr     KERNEL_SETNAM

        lda     #$0F                                    ; open 15,8,5,"S:xx"
        tay
        ldx     #$08
        jsr     KERNEL_SETLFS
        jsr     KERNEL_OPEN
        lda     #$0F
        jsr     KERNEL_CLOSE

        ;-----------------------------------------------------------
        ; Save the requested file
        ;-----------------------------------------------------------

        lda     #$02                                    ; Save file
        ldx     #$08
        ldy     #$FF
        jsr     KERNEL_SETLFS
        lda     #$02
        ldx     #$95
        ldy     #$C5
        jsr     KERNEL_SETNAM
        lda     file_start_address
        sta     $60
        lda     file_start_address + 1
        sta     $61
        lda     #$60
        ldx     file_end_address
        ldy     file_end_address + 1
        jsr     KERNEL_SAVE
        jmp     check_drive_status



selected_character:
        .byte   $00
