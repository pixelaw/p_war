use starknet::ContractAddress;

#[derive(Copy, Drop, Serde, Introspect, PartialEq, Print)]
struct Terms {
    toggle_allowed_app: ContractAddress,
    toggle_allowed_color: u32,
    change_game_duration: u64,
    change_pixel_recovery: u32,
    expand_area: u32
}


#[derive(Model, Copy, Drop, Serde, Print)]
struct Proposal {
    #[key]
    game_id: usize,
    #[key]
    index: usize,
    author: ContractAddress,
    terms: Terms,
    start: u64,
    end: u64,
    yes_px: u32,
    no_px: u32
}

#[derive(Model, Serde, Copy, Drop, PartialEq, Print)]
struct PlayerVote {
    #[key]
    player: ContractAddress,
    #[key]
    game_id: usize,
    #[key]
    index: usize,

    is_in_favor: bool,
    px: u32
}

#[derive(Model, Copy, Drop, Serde, Print)]
struct PixelRecoveryRate {
    #[key]
    id: usize,
    rate: u32
}