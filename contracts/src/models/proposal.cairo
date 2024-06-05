use starknet::ContractAddress;

#[derive(Copy, Drop, Serde, Introspect, PartialEq, Print)]
struct Args {
    toggle_allowed_app: ContractAddress,
    arg1: u64,
    arg2: u64,
}

#[derive(PartialEq, Copy, Introspect, Drop, Serde, Print)]
enum ProposalType {
    Unknown,
    ToggleAllowedApp,
    ToggleAllowedColor,
    ChangeGameDuration,
    ChangePixelRecovery,
    ExpandArea,
}


#[derive(Model, Copy, Drop, Serde, Print)]
struct Proposal {
    #[key]
    game_id: usize,
    #[key]
    index: usize,
    author: ContractAddress,
    proposal_type: ProposalType,
    args: Args,
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
    rate: u64
}

impl ProposalTypeFelt252 of Into<ProposalType, felt252> {
    fn into(self: ProposalType) -> felt252 {
        match self {
            ProposalType::Unknown => 0,
            ProposalType::ToggleAllowedApp => 1,
            ProposalType::ToggleAllowedColor => 2,
            ProposalType::ChangeGameDuration => 3,
            ProposalType::ChangePixelRecovery => 4,            
            ProposalType::ExpandArea => 5,       
        }
    }
}