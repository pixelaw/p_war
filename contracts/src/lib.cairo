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
}
