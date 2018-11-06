;-------------------------------------------------------------------------------
;
; load_module.s
;
; Load a swappable module into memory and begins execution of the module.
;
;-------------------------------------------------------------------------------

.include "hello.inc"

.export mi_load_ou_module

.export load_module_a

.import mi_display_stats
.import mi_reset_buffers
.import mi_restore_text_area

.import check_drive_status
.import draw_border
.import reset_screen_swapping

swap_main       := $8C9E

        .setcpu "6502"

.segment "CODE_MODULE"

;-----------------------------------------------------------
;                     mi_load_ou_module
;
; Loads and begins execution of the OU module.
;-----------------------------------------------------------

mi_load_ou_module:
        lda     #$01                                    ; a := 1



;-----------------------------------------------------------
;                      load_module_a
;
; Loads and begins execution of the module specified in the
; accumulator. Valid modules are:
;
; 1 - OU
; 2 - DN
; 3 - TW
; 4 - CA
; 5 - SP
; 6 - TM
;
; Any other value in the accumulator will result in the GE
; module being loaded to allow the player to choose or
; create a new character.
;-----------------------------------------------------------

load_module_a:
        ldx     #$FF                                    ; Reset the stack
        txs

        cmp     #$07                                    ; if a == 0 or a >= 7 then b8C6a
        bcs     @load_ge
        tax
        bne     @load_module

@load_ge:
        ldx     #$04                                    ; Load module GE at $8C9E (do_mi_main)
        jsr     load_file
        bcs     @load_ge

        jmp     swap_main                               ; Now run the GE module

@load_module:
        clc                                             ; active_swap_module = module to load (OU, DN, TW, CA, SP, or TM)
        adc     #$04
        sta     active_swap_module

@load_loop:
        jsr     mi_reset_buffers                        ; Load the requested module
        ldx     active_swap_module
        jsr     load_file        
        jsr     check_drive_status
        bcs     @load_loop

        jsr     reset_screen_swapping
        jsr     mi_display_stats
        jsr     draw_border
        jsr     mi_restore_text_area

        jmp     swap_main



active_swap_module:
        .byte   $04

        .byte   $20,$3D,$16,$4C,$9B,$8C

