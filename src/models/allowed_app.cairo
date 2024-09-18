use starknet::ContractAddress;

#[derive(Copy, Drop, Serde)]
#[dojo::model(namespace: "pixelaw", nomapping: true)]
struct AllowedApp {
    #[key]
    game_id: usize,
    #[key]
    contract: ContractAddress,
    is_allowed: bool
}
