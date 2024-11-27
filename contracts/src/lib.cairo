mod constants;
mod systems {
    mod actions;
    mod app;
    mod guilds;
    mod propose;
    mod utils;
    mod voting;
}

mod models {
    mod allowed_app;
    mod allowed_color;
    mod board;
    mod game;
    mod guilds;
    mod player;
    mod proposal;
}

#[cfg(test)]
mod tests {
    // mod test_add_color;
    // // mod test_create_world;
    // mod test_extend_game_end;
    mod test_guild;
    // mod test_reset_to_white;
    mod utils;
}
