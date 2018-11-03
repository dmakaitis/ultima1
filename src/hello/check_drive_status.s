;-------------------------------------------------------------------------------
;
; check_drive_status.s
;
; Checks the error status of the floppy drive and sets the carry flag if the 
; status is okay, or clears the carry flag if the drive is in an error status.
;
;-------------------------------------------------------------------------------

.include "kernel.inc"

.export check_drive_status

        .setcpu "6502"

.segment "CODE_DRIVE_STATUS"

;-----------------------------------------------------------
;                     check_drive_status
; 
; Checks the error status of the floppy drive and sets the
; carry flag if the status is okay, or clears the carry
; flag if the drive is in an error status.
;-----------------------------------------------------------

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

        pla                                             ; Check the drive status and set the carry flag appropriately
        cmp     #$30
        beq     @file_read_unsuccessful
        sec
        rts




@file_read_unsuccessful:
        clc
        rts
        rts
