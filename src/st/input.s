;-------------------------------------------------------------------------------
;
; input.s
;
; Routines for reading input from the player.
;
;-------------------------------------------------------------------------------

.export buffer_input
.export draw_world_and_read_from_buffer
.export get_random_number
.export read_from_buffer
.export read_input_from_buffer
.export scan_and_buffer_input
.export update_cursor
.export wait_for_input

.export bitmap_cia_config
.export bitmap_vic_config

.import delay_a_squared
.import do_nothing4
.import draw_world
.import print_char
.import scan_input

        .setcpu "6502"

INPUT_BUFFER            := $4E
INPUT_BUFFER_SIZE       := $56

.segment "CODE_INPUT"

;-----------------------------------------------------------
;                   scan_and_buffer_input
;
; 
;-----------------------------------------------------------

scan_and_buffer_input:
        jsr     scan_input
        bpl     b1E27

        ; continued below



;-----------------------------------------------------------
;                       buffer_input
;
; 
;-----------------------------------------------------------

buffer_input:
        cmp     #$90
        beq     b1E27
        cmp     #$93
        beq     b1E27
        cmp     #$A0
        bne     b1E1D
        ldx     #$00
        stx     INPUT_BUFFER_SIZE
b1E1D:  ldx     INPUT_BUFFER_SIZE
        cpx     #$08
        bcs     b1E27
        sta     INPUT_BUFFER,x
        inc     INPUT_BUFFER_SIZE
b1E27:  rts



bitmap_cia_config:
        .byte   $97,$96
bitmap_vic_config:
        .byte   $18,$80



;-----------------------------------------------------------
;                     wait_for_input
;
; 
;-----------------------------------------------------------

wait_for_input:
        ldy     #$07
b1E2E:  jsr     scan_and_buffer_input
        lda     INPUT_BUFFER_SIZE
        bne     b1E27
        lda     #$4F
        jsr     delay_a_squared
        dey
        bne     b1E2E
        rts



;-----------------------------------------------------------
;                  read_input_from_buffer
;
; 
;-----------------------------------------------------------

read_input_from_buffer:
        jsr     read_from_buffer
        beq     read_input_from_buffer
        rts



;-----------------------------------------------------------
;                    read_from_buffer
;
; 
;-----------------------------------------------------------

read_from_buffer:
        jsr     cache_x_y_and_update_cursor
        jsr     wait_for_input
        lda     INPUT_BUFFER_SIZE
        bne     b1E5A
        beq     b1E7A



;-----------------------------------------------------------
;              draw_world_and_read_from_buffer
;
; 
;-----------------------------------------------------------

draw_world_and_read_from_buffer:
        jsr     cache_x_y_and_update_cursor
        jsr     draw_world
        lda     INPUT_BUFFER_SIZE
        beq     b1E7A
b1E5A:  lda     #$20
        jsr     print_char
        lda     INPUT_BUFFER
        dec     INPUT_BUFFER_SIZE
        ldx     #$01
        cmp     #$FF
        bne     b1E6B
        lda     #$88
b1E6B:  cmp     #$E0
        bcc     b1E71
        eor     #$20
b1E71:  ldy     INPUT_BUFFER,x
        sty     INPUT_BUFFER - 1,x
        inx
        cpx     #$08
        bcc     b1E71
b1E7A:  ldx     x_cache
        ldy     y_cache
        and     #$7F
        rts



;-----------------------------------------------------------
;                cache_x_y_and_update_cursor
;
; 
;-----------------------------------------------------------

cache_x_y_and_update_cursor:
        stx     x_cache
        sty     y_cache
        jsr     do_nothing4

        ; continued below



;-----------------------------------------------------------
;                     update_cursor
;
; 
;-----------------------------------------------------------

update_cursor:
        ldx     cursor_char
        dex
        cpx     #$7C
        bcs     b1E96
        ldx     #$7F
b1E96:  stx     cursor_char
cursor_char     := * + 1
        lda     #$7C
        jsr     print_char

        ; continued below



;-----------------------------------------------------------
;                    get_random_number
;
; 
;-----------------------------------------------------------

get_random_number:
        clc
        lda     w1ED4
        ldx     #$0E
b1EA4:  adc     w1EC5,x
        sta     w1EC5,x
        dex
        bpl     b1EA4
        lda     w1ED4
        clc
        adc     w1EC5
        sta     w1EC5
        ldx     #$0F
b1EB9:  inc     w1EC5,x
        bne     b1EC1
        dex
        bpl     b1EB9
b1EC1:  lda     w1EC5
        rts



w1EC5:  .byte   $64,$76,$85,$54,$F6,$5C,$76,$1F
        .byte   $E7,$12,$A7,$6B,$93,$C4,$6E
w1ED4:  .byte   $1B



.segment "DATA_1789"

x_cache:
        .byte   $00
y_cache:
        .byte   $00
