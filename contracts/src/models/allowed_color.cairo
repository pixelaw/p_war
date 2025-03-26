// if the color is allowed
#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct AllowedColor {
    #[key]
    pub game_id: u32,
    #[key]
    pub color: u32,
    pub is_allowed: bool
}

// the color found in what index
#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct PaletteColors {
    #[key]
    pub game_id: u32,
    #[key]
    pub idx: u32,
    pub color: u32
}

// if the color is already in the palette
#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct InPalette {
    #[key]
    pub game_id: u32,
    #[key]
    pub color: u32,
    pub value: bool
}

// number of colors in the game's palette
#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct GamePalette {
    #[key]
    pub game_id: u32,
    pub length: u32
}
