temp_value                      := $5E
temp_ptr                        := $60
temp_ptr2                       := $62

frame_ctr                       := $79
horse_anim_index                := $7A
star_ctr                        := $7B
sword_ctr                       := $7C
star_ctr2                       := $7D
hand_ctr                        := $7E
bird_x                          := $7F
bird_y                          := $80
bird_frame                      := $81
bird_done_flag                  := $82
knight_flag                     := $83
knight_ctr                      := $84
car_flag                        := $85
pause_ctr                       := $86

bitmap_row_addr_table_low       := $1200
bitmap_row_addr_table_high      := $12C0

bitmap_col_offset_table_low     := $15B0
bitmap_col_offset_table_high    := $15D8

bitmap_memory                   := $4000
screen_memory                   := $6000

sprite_0_ptr                    := screen_memory + $03F8
sprite_1_ptr                    := screen_memory + $03F9
sprite_2_ptr                    := screen_memory + $03FA
sprite_3_ptr                    := screen_memory + $03FB
sprite_4_ptr                    := screen_memory + $03FC
sprite_5_ptr                    := screen_memory + $03FD
sprite_6_ptr                    := screen_memory + $03FE
sprite_7_ptr                    := screen_memory + $03FF

sprite_0_image                  := bitmap_memory + $40 * $90    ; $6400
sprite_1_image                  := bitmap_memory + $40 * $91    ; $6440
sprite_2_image                  := bitmap_memory + $40 * $92    ; $6480
sprite_3_image                  := bitmap_memory + $40 * $95    ; $6540
sprite_4_image                  := bitmap_memory + $40 * $96    ; $6580
sprite_5_image                  := bitmap_memory + $40 * $93    ; $64C0
sprite_5b_image                 := bitmap_memory + $40 * $94    ; $6500
sprite_6_image                  := bitmap_memory + $40 * $97    ; $65C0
sprite_7_image                  := bitmap_memory + $40 * $97    ; $65C0

bitmap_backup                   := $8000