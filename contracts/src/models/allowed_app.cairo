use starknet::ContractAddress;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct AllowedApp {
    #[key]
    game_id: u32,
    #[key]
    contract: ContractAddress,
    is_allowed: bool
}
