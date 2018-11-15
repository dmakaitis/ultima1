; ---------------------------------------------------------------------------
; MI library routines

mi_main                                 := $7400

mi_race_name_table                      := $7763;
mi_weapon_table                         := $777C;
mi_weapon_abbr_table                    := $77EC;
mi_attribute_table                      := $7842;
mi_class_name_table                     := $7911;
mi_transport_table                      := $7930;
mi_command_table                        := $797F;
mi_r7A51                                := $7A51;
mi_r7A57                                := $7A57;
mi_world_monster_table                  := $7A7F;
mi_land_name_table                      := $7BDA;
mi_world_feature_continent_y_coords     := $7C18;
mi_world_feature_x_coords               := $7C6C;
mi_world_feature_table                  := $7CC0;

mi_check_drive_status                   := $8175;
mi_w81C1                                := $81C1;
mi_current_attribute                    := $81C4;
mi_command_table_override               := $81C7;
mi_command_table_override_hi            := $81C8;
mi_command_decode_table                 := $81C9;

mi_player_save_data                     := $81E2;

mi_player_continent                     := $81E4;
mi_player_continent_mask                := $81E5;
mi_player_sound_flag                    := $81E7;
mi_player_position_x                    := $81E8;
mi_player_position_y                    := $81E9;
mi_player_gems                          := $81EA;
mi_player_gems_1                        := $81EB;
mi_player_gems_2                        := $81EC;
mi_player_gems_3                        := $81ED;
mi_player_equipped_spell                := $81EE;
mi_player_equipped_weapon               := $81EF;
mi_player_equipped_armor                := $81F0;
mi_player_current_vehicle               := $81F1;
mi_player_inventory_armor               := $81F2;
mi_player_inventory_weapons             := $81F8;
mi_player_inventory_spells              := $8208;
mi_player_inventory_vehicles_m8         := $820B;
mi_player_inventory_vehicles            := $8213;
mi_player_821D                          := $821D;
mi_player_821E                          := $821E;
mi_player_new_vehicle_north             := $8226;
mi_player_new_vehicle_west              := $8227;
mi_player_new_vehicle_east              := $8228;
mi_player_new_vehicle_south             := $8229;
mi_player_new_time_machine              := $822A;
mi_player_sex                           := $822C;
mi_player_name                          := $822D;
mi_player_hits                          := $823B;
mi_player_hits_hi                       := $823C;
mi_player_strength                      := $823D;
mi_player_agility                       := $823F;
mi_player_stamina                       := $8241;
mi_player_charisma                      := $8243;
mi_player_wisdom                        := $8245;
mi_player_intelligence                  := $8247;
mi_player_money                         := $8249;
mi_player_money_hi                      := $824A;
mi_player_race                          := $824B;
mi_player_class                         := $824D;
mi_player_food                          := $825A;
mi_player_food_hi                       := $825B;
mi_player_experience                    := $825C;
mi_player_experience_hi                 := $825D;
mi_player_world_feature                 := $8262;
mi_player_8263                          := $8263;
mi_player_random_seed                   := $8264;
mi_player_8267                          := $8267;
mi_player_8268                          := $8268;
mi_player_vehicle_count                 := $826B;
mi_player_vehicle_x_coords              := $826C;
mi_player_vehicle_x_coords_p1           := $826D;
mi_player_vehicle_continent_y_coords_m1 := $82BB;
mi_player_vehicle_continent_y_coords    := $82BC;
mi_player_vehicle_continent_y_coords_p1 := $82BD;
mi_player_vehicle_types                 := $830C;
mi_player_vehicle_types_p1              := $830D;
mi_player_vehicle_tiles_m1              := $835B;
mi_player_vehicle_tiles                 := $835C;
mi_player_vehicle_tiles_p1              := $835D;

mi_print_digit                          := $83CD;
mi_print_char                           := $83D7;
mi_print_tab                            := $83ED;
mi_print_crlf_col_1                     := $83F3;
mi_cursor_to_col_1                      := $83F6;

mi_cursor_to_col_0                      := $8411;
mi_reduce_text_window_size              := $8416;
mi_print_string_entry_x                 := $8426;
mi_print_first_string_entry             := $842B;
mi_print_string_entry_x2                := $842D;
mi_print_text_at_x_y                    := $848A;
mi_print_text                           := $848E;
mi_print_x_chars                        := $84B9;
mi_clear_screen_and_draw_border         := $84C0;

mi_to_decimal_a_x                       := $8522;
mi_print_short_int                      := $8582;
mi_number_padding                       := $85BE;
mi_div_a_by_10                          := $85BF;
mi_get_random_number_a                  := $85C9;
mi_reset_buffers_and_wait_for_input     := $85E1;
mi_wait_for_input                       := $85E4;
mi_decode_and_print_command_a           := $85FD;

mi_j863A                                := $863A;
mi_s863C                                := $863C;
mi_increase_high_bytes                  := $8678;
mi_display_stats                        := $8689;
mi_update_stats                         := $86C6;

mi_restore_text_area                    := $8701;
mi_store_text_area                      := $870C;
mi_print_equipped_spell                 := $8717;
mi_no_effect                            := $874E;
mi_spell_failed                         := $8766;
mi_cmd_invalid                          := $876A;
mi_play_error_sound_and_reset_buffers   := $8772;
mi_play_sound_and_reset_buffers_a       := $8774;
mi_reset_buffers                        := $8777;
mi_do_nothing                           := $8787;
mi_s8788                                := $8788;
mi_s879F                                := $879F;
mi_s87A1                                := $87A1;
mi_get_item_to_ready                    := $87D0;

mi_cmd_ztats                            := $890C;

mi_print_player_name                    := $8BA1;
mi_cmd_noise                            := $8BB9;
mi_player_died                          := $8BCE;

mi_load_ou_module                       := $8C5E;
mi_load_module_a                        := $8C60;
