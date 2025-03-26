use starknet::ContractAddress;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct AllowedApp {
    #[key]
    pub game_id: u32,
    #[key]
    pub contract: ContractAddress,
    pub is_allowed: bool
}
