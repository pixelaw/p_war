mod constants;
mod systems {
    mod actions;
    mod apps;
    mod propose;
    mod utils;
    mod voting;
    mod guilds;
}

mod models {
    mod allowed_app;
    mod allowed_color;
    mod board;
    mod game;
    mod player;
    mod proposal;
    mod guilds;
}

#[cfg(test)]
mod tests {
    mod test_add_color;
    mod test_create_world;
    mod test_extend_game_end;
    mod test_reset_to_white;
    mod test_guild;
    mod utils;
}
