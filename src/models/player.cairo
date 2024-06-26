use starknet::{get_block_timestamp, ContractAddress};

#[derive(Model, Copy, Drop, Serde)]
struct Player {
    #[key]
    address: ContractAddress,
    // name: felt252,
    max_px: u32,
    num_owns: u32,
    num_commit: u32,
    current_px: u32,
    last_date: u64,
    is_banned: bool,
}
