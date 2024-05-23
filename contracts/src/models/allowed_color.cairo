#[derive(Model, Copy, Drop, Serde)]
struct AllowedColor {
    #[key]
    game_id: usize,
    #[key]
    color: u32,
    is_allowed: bool
}