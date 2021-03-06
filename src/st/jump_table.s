;-------------------------------------------------------------------------------
;
; jump_tables.s
;
; Jump tables to provide entry points into ST library routines.
;
;-------------------------------------------------------------------------------

.include "c64.inc"
.include "kernel.inc"

.export st_init_snd_gfx
.export st_do_nothing
.export st_do_nothing2
.export st_do_nothing3
.export st_copy_screen_2_to_1
.export st_scroll_text_area_up
.export st_clear_current_text_row
.export st_clear_to_end_of_text_row_a
.export st_clear_text_window
.export st_set_text_window_full
.export st_set_text_window_stats
.export st_set_text_window_command
.export st_set_text_window_main
.export st_clear_main_viewport
.export st_swap_bitmaps
.export st_print_char
.export st_draw_world
.export st_wait_for_input
.export st_get_random_number
.export st_scan_and_buffer_input
.export st_read_input
.export st_get_input
.export st_draw_world_and_get_input
.export st_update_cursor
.export st_play_sound_a
.export st_queue_sound
.export st_play_next_sound
.export st_set_draw_color
.export st_draw_pixel
.export st_draw_line_x_y
.export st_draw_line
.export st_do_nothing4
.export st_do_nothing5
.export st_wait_for_raster

.import clear_current_text_row
.import clear_main_viewport
.import clear_text_window
.import clear_to_end_of_text_row_a
.import copy_screen_2_to_1
.import draw_world
.import draw_world_and_get_input
.import get_input
.import get_random_number
.import init_snd_gfx
.import play_next_sound
.import play_sound_a
.import print_char
.import queue_sound
.import read_input
.import scan_and_buffer_input
.import scroll_text_area_up
.import set_text_window_command
.import set_text_window_full
.import set_text_window_main
.import set_text_window_stats
.import swap_bitmaps
.import update_cursor
.import wait_for_input
.import wait_for_raster

.import do_set_draw_color
.import do_draw_pixel
.import do_draw_line_x_y
.import do_draw_line

.import do_nothing
.import do_nothing2
.import do_nothing3
.import do_nothing4

; Reminders to update these files when addresses are ready:
;
; scan_and_buffer_input - scroll_text

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

st_clear_current_text_row:
        jmp     clear_current_text_row

st_clear_to_end_of_text_row_a:
        jmp     clear_to_end_of_text_row_a

st_clear_text_window:
        jmp     clear_text_window

st_set_text_window_full:
        jmp     set_text_window_full

st_set_text_window_stats:
        jmp     set_text_window_stats

st_set_text_window_command:
        jmp     set_text_window_command

st_set_text_window_main:
        jmp     set_text_window_main

st_clear_main_viewport:
        jmp     clear_main_viewport

st_swap_bitmaps:
        jmp     swap_bitmaps

st_print_char:
        jmp     print_char

st_draw_world:
        jmp     draw_world

st_wait_for_input:
        jmp     wait_for_input

st_get_random_number:
        jmp     get_random_number

st_scan_and_buffer_input:
        jmp     scan_and_buffer_input

st_read_input:
        jmp     read_input

st_get_input:
        jmp     get_input

st_draw_world_and_get_input:
        jmp     draw_world_and_get_input

st_update_cursor:
        jmp     update_cursor

st_play_sound_a:
        jmp     play_sound_a

st_queue_sound:
        jmp     queue_sound

st_play_next_sound:
        jmp     play_next_sound

st_set_draw_color:
        jmp     do_set_draw_color

st_draw_pixel:
        jmp     do_draw_pixel

st_draw_line_x_y:
        jmp     do_draw_line_x_y

st_draw_line:
        jmp     do_draw_line

st_do_nothing4:
        jmp     do_nothing4

st_do_nothing5:
        jmp     do_nothing4

st_wait_for_raster:
        jmp     wait_for_raster
