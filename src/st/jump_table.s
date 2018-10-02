;-------------------------------------------------------------------------------
;
; jump_tables.s
;
; Jump tables to provide entry points into ST library routines.
;
;-------------------------------------------------------------------------------

.include "c64.inc"
.include "kernel.inc"
.include "global.inc"

.import do_nothing4
.import clear_main_viewport

init_snd_gfx                := $178F
do_nothing                  := $0
do_nothing2                 := $0
do_nothing3                 := $0
copy_screen_2_to_1          := $0
scroll_text_area_up         := $0
do_s164C                    := $0
fill_text_row               := $0
do_s1652                    := $0
set_text_window_full        := $0
set_text_window_stats       := $0
set_text_window_command     := $1A0D
do_s165E                    := $0
swap_bitmaps                := $0
print_char                  := $0
do_s166A                    := $0
wait_for_input              := $0
get_random_number           := $0
scan_and_buffer_input       := $0
read_input_from_buffer      := $0
read_from_buffer            := $0
do_s167C                    := $0
update_cursor               := $0
do_s1682                    := $0
do_s1685                    := $0
do_s1688                    := $0
do_s168B                    := $0
do_s168E                    := $0
do_s1691                    := $0
do_s1694                    := $0
wait_for_raster             := $0

        .setcpu "6502"

.segment "CODE_JUMP"

;-----------------------------------------------------------
;
;-----------------------------------------------------------

st_init_snd_gfx:
        jmp     init_snd_gfx

st_do_nothing:
        jmp     do_nothing

st_do_nothing2:
        jmp     do_nothing2

st_do_nothing3:
        jmp     do_nothing3

st_copy_screen_2_to_1:
        jmp     copy_screen_2_to_1

st_scroll_text_area_up:
        jmp     scroll_text_area_up

st_s164C:
        jmp     do_s164C

st_fill_text_row:
        jmp     fill_text_row

st_s1652:
        jmp     do_s1652

st_set_text_window_full:
        jmp     set_text_window_full

st_set_text_window_stats:
        jmp     set_text_window_stats

st_set_text_window_command:
        jmp     set_text_window_command

st_s165E:
        jmp     do_s165E

st_clear_main_viewport:
        jmp     clear_main_viewport

st_swap_bitmaps:
        jmp     swap_bitmaps

st_print_char:
        jmp     print_char

st_s166A:
        jmp     do_s166A

st_wait_for_input:
        jmp     wait_for_input

st_get_random_number_:
        jmp     get_random_number

st_scan_and_buffer_input:
        jmp     scan_and_buffer_input

st_read_input_from_buffer:
        jmp     read_input_from_buffer

st_read_from_buffer:
        jmp     read_from_buffer

st_s167C:
        jmp     do_s167C

st_update_cursor:
        jmp     update_cursor

st_s1682:
        jmp     do_s1682

st_s1685:
        jmp     do_s1685

st_s1688:
        jmp     do_s1688

st_s168B:
        jmp     do_s168B

st_s168E:
        jmp     do_s168E

st_s1691:
        jmp     do_s1691

st_s1694:
        jmp     do_s1694

st_do_nothing4:
        jmp     do_nothing4

st_do_nothing5:
        jmp     do_nothing4

st_wait_for_raster:
        jmp     wait_for_raster
