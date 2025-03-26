use starknet::{ContractAddress};

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Player {
    #[key]
    pub address: ContractAddress,
    // #[key] // the game_id as a key for the player should be added as players could be playing
    // different games at once game_id: u32,
    // name: felt252,
    pub num_owns: u32,
    pub num_commit: u32,
    pub last_date: u64,
    pub is_banned: bool,
}
