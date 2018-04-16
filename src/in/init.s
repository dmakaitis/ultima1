;-------------------------------------------------------------------------------
;
; init_intro.s
;
; Initializes the intro animation routines that display the intro page until
; the user presses a key to continue.
;-------------------------------------------------------------------------------

.include "c64.inc"
.include "kernel.inc"
.include "global.inc"
.include "in.inc"

.import intro_backdrop

.export decompress_backdrop

        .setcpu "6502"

.segment "CODE_INIT"

decompress_backdrop:
        lda     #<bitmap_memory         ; Write to bitmap memory at $4000
        sta     store_vector
        lda     #>bitmap_memory
        sta     store_vector + 1
        lda     #<intro_backdrop        ; Read from compressed image data
        sta     load_vector
        lda     #>intro_backdrop
        sta     load_vector + 1

@decompress_loop:
        jsr     lda_and_advance
        cmp     #$DA
        beq     build_bitmap_row_addr_table
        cmp     #$00                    ; If the next byte is $00, $10, $FF, $E6, $16, or
        beq     @store_run              ; $50, then it is a run and the following byte contains
        cmp     #$10                    ; the number of times the value should be repeated
        beq     @store_run
        cmp     #$FF
        beq     @store_run
        cmp     #$E6
        beq     @store_run
        cmp     #$16
        beq     @store_run
        cmp     #$50
        beq     @store_run

        jsr     sta_and_advance
        jmp     @decompress_loop

@store_run:
        pha
        jsr     lda_and_advance
        tax
        pla
@loop:  jsr     sta_and_advance
        dex
        bne     @loop
        jmp     @decompress_loop




;-----------------------------------------------------------
;                       lda_and_advance
;
; Loads the value stored at the memory location pointed to 
; by 'load_vector' into the accumulator, then advances
; 'load_vector' by one.
;-----------------------------------------------------------

lda_and_advance:
load_vector     := * + 1
        lda     intro_backdrop
        inc     load_vector
        bne     @exit
        inc     load_vector + 1
@exit:  rts




;-----------------------------------------------------------
;                       sta_and_advance
;
; Stores the value in the accumulator into the memory
; location pointed to by 'store_vector', then advances
; 'store_vector' by one.
;-----------------------------------------------------------

sta_and_advance:
store_vector    := * + 1
        sta     bitmap_memory
        inc     store_vector
        bne     @exit
        inc     store_vector + 1
@exit:  rts




        ; Initialize data in $1200-$12BF, and $12C0-$137F to become a lookup table to
        ; find the address in memory where each row of pixels starts in the bitmap display.
        ;
        ; The bytes starting at $1200 contain the least significant byte of the address
        ; for each of 192 rows of pixels, starting with the top row.
        ;
        ; The bytes starting at $12C0 contain the most significant byte of the address
        ; for each row of pixels.
        ;
        ; The addresses are stored assuming the bitmap is located at $2000 in memory, so
        ; a constant would need to be added if the bitmap is located elsewhere (for
        ; example, add $2000 if the bitmap is located at $4000, as it is in the intro).

build_bitmap_row_addr_table:
        lda     #$00
        sta     bitmap_row_addr_table_low
        lda     #$20
        sta     bitmap_row_addr_table_high
        ldx     #$00
@loop:  lda     bitmap_row_addr_table_low,x
        clc
        adc     #$01
        inx
        sta     bitmap_row_addr_table_low,x                 
        and     #$07
        bne     @copy_next_high_byte

        dex
        lda     bitmap_row_addr_table_high,x
        clc
        adc     #$01
        inx
        sta     bitmap_row_addr_table_high,x
        lda     bitmap_row_addr_table_low,x
        and     #$F0
        clc
        adc     #$40
        sta     bitmap_row_addr_table_low,x
        bcc     @check_if_done
        inc     bitmap_row_addr_table_high,x
        jmp     @check_if_done

@copy_next_high_byte:
        dex
        lda     bitmap_row_addr_table_high,x
        inx
        sta     bitmap_row_addr_table_high,x

@check_if_done:
        cpx     #$BF
        bne     @loop




        ; Initializes data in $15B0-$15D7 and $15D8-$15FF to become a lookup table
        ; to find the offset in memory from the start of a row of pixels to a particular
        ; column in that row. The first entry in each table is used to find the left-
        ; most column, and the last entry to find the right-most column. Each table
        ; contains 40 entries, since each byte in memory contains 8 pixels (8 * 40 = 320).
        ;
        ; The table starting at $15B0 contains the least significant byte, and the
        ; the table starting at $15D8 contains the most significant byte.

build_bitmap_col_offset_table:
        lda     #$38                    ; The last entry in the table is $0138
        sta     temp_value
        lda     #$01
        sta     temp_value + 1

        ldx     #$27                    ; We will load 40 entries

@loop:  lda     temp_value              ; Load the table backwards, each value is $0008 lower than the following
        sta     bitmap_col_offset_table_low,x
        sec
        sbc     #$08
        sta     temp_value
        lda     temp_value + 1
        sta     bitmap_col_offset_table_high,x
        sbc     #$00
        sta     temp_value + 1
        dex
        bpl     @loop
