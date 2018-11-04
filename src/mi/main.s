;-------------------------------------------------------------------------------
;
; main.s
;
; Entry point for the MI module.
;
;-------------------------------------------------------------------------------

.include "c64.inc"
.include "st.inc"
.include "hello.inc"

.import load_module_a

.import reset_screen_swapping

        .setcpu "6502"

.segment        "CODE_MAIN"

;-----------------------------------------------------------
;                          mi_main
;
; Entry point for the MI module. Passes control to
; do_mi_main.
;-----------------------------------------------------------

mi_main:
        jmp     do_mi_main



.segment        "CODE_DO_MAIN"

;-----------------------------------------------------------
;                       do_mi_main
;
; Entry point for the MI module.
;-----------------------------------------------------------

do_mi_main:
        sei

        ldx     #$FF                                    ; Reset the stack
        txs

        ldx     #$0B                                    ; Load the ST module at $0C00
        jsr     load_file

        ldx     #$0F                                    ; Load the PR module at $12C0
        jsr     load_file                               ; (this should fail on a legitimate copy)

        jsr     st_set_text_window_full
        jsr     st_init_snd_gfx

        lda     #$60                                    ; Initialize bitmap swapping
        sta     BM_ADDR_MASK
        sta     BM2_ADDR_MASK
        jsr     st_swap_bitmaps
        jsr     reset_screen_swapping

        lda     #$96                                    ; Set bitmap memory to $4000 and
        sta     CIA2_PRA                                ; screen memory to $6000
        lda     #$80
        sta     VIC_VIDEO_ADR

        lda     #$00
        jmp     load_module_a



        .byte   $C8
