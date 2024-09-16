use starknet::ContractAddress;
use dojo::world::IWorldDispatcher;

#[derive(Copy, Drop, Serde)]
#[dojo::model(namespace: "pixelaw", nomapping: true)]
struct Guild {
    #[key]
    game_id: usize,
    #[key]
    guild_id: usize,
    guild_name: felt252,
    creator: ContractAddress,
    members: Span<ContractAddress>,
    member_count: usize
}
