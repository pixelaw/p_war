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
    mod test_setup;
    mod test_games;
    mod test_guilds;
    mod test_proposals;
    mod utils;
}
