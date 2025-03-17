use starknet::ContractAddress;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct GamePayments {
    #[key]
    game_id: u32,
    participation_fee: u256,
    prize_pool: u256,
    treasury_balance: u256
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct PlayerPayment {
    #[key]
    game_id: u32,
    #[key]
    player: ContractAddress,
    amount_paid: u256
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct TreasuryInfo {
    #[key]
    dummy_key: u32,
    treasury_address: ContractAddress
}
