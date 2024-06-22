#[derive(Model, Copy, Drop, Serde)]
struct AllowedColor {
    #[key]
    game_id: usize,
    #[key]
    color: u32,
    is_allowed: bool
}

#[derive(Model, Copy, Drop, Serde)]
struct PaletteColors {
    #[key]
    game_id: usize,
    #[key]
    idx: u32,
    color: u32
}