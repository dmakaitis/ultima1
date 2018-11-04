;-------------------------------------------------------------------------------
;
; exit.s
;
; Exit the intro page and passes control to the main menu.
;
;-------------------------------------------------------------------------------

.include "c64.inc"
.include "kernel.inc"
.include "hello.inc"
.include "in.inc"

.import disable_sprites

.export exit_intro

mi_main         := $7400

        .setcpu "6502"

.segment "CODE_EXIT"

exit_intro:
        jsr     disable_sprites

        lda     #>bitmap_memory         ; Fill memory $4000 to $63FF with zeros
        sta     temp_ptr + 1            ; (erase intro graphics)
        lda     #<bitmap_memory
        sta     temp_ptr
        tay
        ldx     #$24
@loop:  sta     (temp_ptr),y
        iny
        bne     @loop
        inc     temp_ptr + 1
        dex
        bne     @loop

        ldx     #$0D                    ; Load MI at $7400
        jsr     load_file
        jmp     mi_main                 ; Execute MI
