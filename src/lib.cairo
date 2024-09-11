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

#[cfg(test)]
mod tests {
    mod utils;
    mod test_create_world;
    mod test_add_color;
    mod test_reset_to_white;
    mod test_extend_game_end;
}

mod constants;
