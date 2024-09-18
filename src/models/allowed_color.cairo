// if the color is allowed
#[derive(Copy, Drop, Serde)]
#[dojo::model(namespace: "pixelaw", nomapping: true)]
struct AllowedColor {
    #[key]
    game_id: usize,
    #[key]
    color: u32,
    is_allowed: bool
}

// the color found in what index
#[derive(Copy, Drop, Serde)]
#[dojo::model(namespace: "pixelaw", nomapping: true)]
struct PaletteColors {
    #[key]
    game_id: usize,
    #[key]
    idx: u32,
    color: u32
}

// if the color is already in the palette
#[derive(Copy, Drop, Serde)]
#[dojo::model(namespace: "pixelaw", nomapping: true)]
struct InPalette {
    #[key]
    game_id: usize,
    #[key]
    color: u32,
    value: bool
}

// number of colors in the game's palette
#[derive(Copy, Drop, Serde)]
#[dojo::model(namespace: "pixelaw", nomapping: true)]
struct GamePalette {
    #[key]
    game_id: usize,
    length: usize
}
