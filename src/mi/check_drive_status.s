;-------------------------------------------------------------------------------
;
; check_drive_status.s
;
; Check the drive status after loading or saving a file.
;
;-------------------------------------------------------------------------------

.include "st.inc"

.export check_drive_status

.import mi_print_text

.import press_space_to_continue

        .setcpu "6502"

.segment "CODE_STATUS"

;-----------------------------------------------------------
;                    check_drive_status
;
; Check the drive status after loading or saving a file. If
; the carry flag is clear, then the disk operation was
; successful. Otherwise, an error will be displayed to the
; user.
;-----------------------------------------------------------

check_drive_status:
        bcc     @no_error

        jsr     mi_print_text							; Display error message to the user

        .byte   "}Disk error ",$00

        jsr     press_space_to_continue
        jsr     st_clear_to_end_of_text_row_a
        
        sec
@no_error:
        rts
