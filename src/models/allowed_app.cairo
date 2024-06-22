use starknet::ContractAddress;

#[derive(Model, Copy, Drop, Serde)]
struct AllowedApp {
    #[key]
    game_id: usize,
    #[key]
    contract: ContractAddress,
    is_allowed: bool
}