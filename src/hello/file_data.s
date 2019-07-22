;-------------------------------------------------------------------------------
;
; file_data.s
;
; File metadata and file related variable storage.
;
;-------------------------------------------------------------------------------

.export filename
.export file_start_address
.export file_end_address

.export read_filenames
.export read_start_addresses

.export write_filenames
.export write_start_addresses
.export write_end_addresses

        .setcpu "6502"

.segment "DATA_FILE_DATA"

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

        .byte   "GE"                                    ; Character generator code
        .byte   "OU"                                    ; Outdoor module
        .byte   "DN"                                    ; Dungeon module
        .byte   "TW"                                    ; Town module

        .byte   "CA"                                    ; Castle module
        .byte   "SP"                                    ; Space module
        .byte   "TM"                                    ; Time machine module
        .byte   "ST"                                    ; Screen and Text routines

        .byte   "IN"                                    ; Displays Ultima I intro animation
        .byte   "MI"                                    ; Common code library
        .byte   "LO"                                    ; Displays Origin logo and loads intro
        .byte   "PR"                                    ; PR is for copy protection - reading this file should fail




write_filenames:
        .byte   "DD"                                    ; Disk driver selection
        .byte   "RO"                                    ; Character roster
        .byte   "P0"                                    ; Player save slot 1
        .byte   "P1"                                    ; Player save slot 2
        .byte   "P2"                                    ; Player save slot 3
        .byte   "P3"                                    ; Player save slot 4




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
