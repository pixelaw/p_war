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
//     game_id: u32,
//     #[key]
//     index: u32,
//     author: ContractAddress,
//     proposal_type: ProposalType,
//     args: Args,
//     start: u64,
//     end: u64,
//     yes_px: u32,
//     no_px: u32
// }

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Proposal {
    #[key]
    pub game_id: u32,
    #[key]
    pub index: u32,
    pub author: ContractAddress,
    pub proposal_type: u8, // change it from ProposalType is not working...
    pub target_args_1: u32,
    pub target_args_2: u32,
    pub start: u64,
    pub end: u64,
    pub yes_voting_power: u32,
    pub no_voting_power: u32,
    pub is_activated: bool, // added: check if the proposal is activated
}


#[derive(Serde, Copy, Drop, PartialEq)]
#[dojo::model]
pub struct PlayerVote {
    #[key]
    pub player: ContractAddress,
    #[key]
    pub game_id: u32,
    #[key]
    pub index: u32,
    pub is_in_favor: bool,
    pub voting_power: u32
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct PixelRecoveryRate {
    #[key]
    pub game_id: u32,
    pub rate: u64
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


