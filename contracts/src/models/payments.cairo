use starknet::ContractAddress;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct GamePayments {
    #[key]
    pub game_id: u32,
    pub participation_fee: u256,
    pub prize_pool: u256,
    pub treasury_balance: u256,
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct PlayerPayment {
    #[key]
    pub game_id: u32,
    #[key]
    pub player: ContractAddress,
    pub amount_paid: u256,
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct TreasuryInfo {
    #[key]
    pub dummy_key: u32,
    pub treasury_address: ContractAddress,
}
