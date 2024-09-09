use starknet::ContractAddress;

#[derive(Copy, Drop, Serde)]
#[dojo::model(namespace: "pixelaw", nomapping: true)]
struct Guild {
    #[key]
    game_id: usize,
    #[key]
    guild_id: usize,
    guild_name: felt252,
    creator: ContractAddress,
    members: Vec<ContractAddress>,
    member_count: usize
}
