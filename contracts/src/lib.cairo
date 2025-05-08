mod constants;
pub mod systems {
    pub mod actions;
    pub mod guilds;
    pub mod propose;
    pub mod utils;
    pub mod voting;
}

pub mod models {
    pub mod allowed_app;
    pub mod allowed_color;
    pub mod board;
    pub mod game;
    pub mod guilds;
    pub mod player;
    pub mod proposal;
}

#[cfg(test)]
pub mod tests {
    // mod test_games;
    // mod test_guilds;
    // mod test_proposals;
    pub mod test_setup;
    pub mod utils;
}
