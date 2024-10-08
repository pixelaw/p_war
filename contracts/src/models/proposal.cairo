use starknet::ContractAddress;

// #[derive(Copy, Drop, Serde, Introspect, PartialEq, Print)]
// struct Args {
//     address: ContractAddress,
//     arg1: u64,
//     arg2: u64,
// }

// #[derive(PartialEq, Copy, Introspect, Drop, Serde, Print)]
// enum ProposalType {
//     Unknown,
//     ToggleAllowedApp,
//     AddNewColor,
//     ExtendGameEndTime,
//     ChangePixelRecovery,
//     ExpandArea,
//     BanPlayerAddress,
//     ChangeMaxPXConfig,
//     ChangeWinnerConfig,
//     ChangePaintCost,
//     ResetToWhiteByCoordinates,
//     ResetToWhiteByColor,
// }

// #[derive(Model, Copy, Drop, Serde, Print)]
// struct Proposal {
//     #[key]
//     game_id: usize,
//     #[key]
//     index: usize,
//     author: ContractAddress,
//     proposal_type: ProposalType,
//     args: Args,
//     start: u64,
//     end: u64,
//     yes_px: u32,
//     no_px: u32
// }

#[derive(Copy, Drop, Serde)]
#[dojo::model(namespace: "pixelaw", nomapping: true)]
struct Proposal {
    #[key]
    game_id: usize,
    #[key]
    index: usize,
    author: ContractAddress,
    proposal_type: u8, // change it from ProposalType is not working...
    target_args_1: u32,
    target_args_2: u32,
    start: u64,
    end: u64,
    yes_voting_power: u32,
    no_voting_power: u32,
    is_activated: bool, // added: check if the proposal is activated
}


#[derive(Serde, Copy, Drop, PartialEq)]
#[dojo::model(namespace: "pixelaw", nomapping: true)]
struct PlayerVote {
    #[key]
    player: ContractAddress,
    #[key]
    game_id: usize,
    #[key]
    index: usize,
    is_in_favor: bool,
    voting_power: u32
}

#[derive(Copy, Drop, Serde)]
#[dojo::model(namespace: "pixelaw", nomapping: true)]
struct PixelRecoveryRate {
    #[key]
    game_id: usize,
    rate: u64
}
// impl ProposalTypeFelt252 of Into<ProposalType, felt252> {
//     fn into(self: ProposalType) -> felt252 {
//         match self {
//             ProposalType::Unknown => 0,
//             ProposalType::ToggleAllowedApp => 1,
//             ProposalType::AddNewColor => 2,
//             ProposalType::ExtendGameEndTime => 3,
//             ProposalType::ChangePixelRecovery => 4,
//             ProposalType::ExpandArea => 5,
//             ProposalType::BanPlayerAddress => 6,
//             ProposalType::ChangeMaxPXConfig => 7,
//             ProposalType::ChangeWinnerConfig => 8,
//             ProposalType::ChangePaintCost => 9,
//             ProposalType::ResetToWhiteByCoordinates => 10,
//             ProposalType::ResetToWhiteByColor => 11,
//         }
//     }
// }


