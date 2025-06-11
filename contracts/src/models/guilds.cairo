use starknet::ContractAddress;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Guild {
    #[key]
    pub game_id: u32,
    #[key]
    pub guild_id: u32,
    pub guild_name: felt252,
    pub creator: ContractAddress,
    pub members: Span<ContractAddress>,
    pub member_count: u32,
}
