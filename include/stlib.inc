; ---------------------------------------------------------------------------
; ST library routines

CUR_X_OFF                   := $2E;
CUR_X_MAX                   := $2F;

CUR_Y_MIN                   := $30;
CUR_Y_MAX                   := $31;
CUR_X                       := $32;
CUR_Y                       := $33;

BM_ADDR_MASK                := $5C;
BM2_ADDR_MASK               := $5D;

w1638                       := $1638;

st_init_snd_gfx             := $163A
st_copy_screen_2_to_1       := $1646;
st_scroll_text_area_up      := $1649;
st_fill_text_row            := $164F;
st_set_text_window_full     := $1655;
st_set_text_window_stats    := $1658;
st_set_text_window_command  := $165B;
st_clear_main_viewport      := $1661;
st_swap_bitmaps             := $1664;
st_draw_char                := $1667;
st_s1670                    := $1670;
st_buffer_input             := $1673;
st_read_input_from_buffer   := $1676;
