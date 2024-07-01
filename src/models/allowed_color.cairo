// if the color is allowed
#[derive(Model, Copy, Drop, Serde)]
struct AllowedColor {
    #[key]
    game_id: usize,
    #[key]
    color: u32,
    is_allowed: bool
}

// the color found in what index
#[derive(Model, Copy, Drop, Serde)]
struct PaletteColors {
    #[key]
    game_id: usize,
    #[key]
    idx: u32,
    color: u32
}

// if the color is already in the palette
#[derive(Model, Copy, Drop, Serde)]
struct InPalette {
    #[key]
    game_id: usize,
    #[key]
    color: u32,
    value: bool
}

// number of colors in the game's palette
#[derive(Model, Copy, Drop, Serde)]
struct GamePalette {
    #[key]
    game_id: usize,
    length: usize
}