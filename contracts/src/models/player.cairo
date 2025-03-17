use starknet::{get_block_timestamp, ContractAddress};

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct Player {
    #[key]
    address: ContractAddress,
    // #[key] // the game_id as a key for the player should be added as players could be playing
    // different games at once game_id: u32,
    // name: felt252,
    num_owns: u32,
    num_commit: u32,
    last_date: u64,
    is_banned: bool,
}
