use starknet::ContractAddress;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct Guild {
    #[key]
    game_id: u32,
    #[key]
    guild_id: u32,
    guild_name: felt252,
    creator: ContractAddress,
    members: Span<ContractAddress>,
    member_count: u32
}
