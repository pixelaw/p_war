mod systems {
    mod actions;
    mod propose;
    mod voting;
    mod apps;
    mod utils;
}

mod models {
    mod allowed_app;
    mod allowed_color;
    mod board;
    mod game;
    mod proposal;
    mod player;
}

mod tests {
    mod test_create_world;
    mod test_add_color;
    mod test_change_game_duration;
    mod test_change_pixel_recovery;
    mod test_expand_area;
    mod test_ban_player;
    mod test_change_max_px;
    mod test_change_winner_config;
    mod test_change_base_cost;
    mod test_make_a_disaster;
}
