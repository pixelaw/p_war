use pixelaw::core::utils::Position;
use starknet::{ContractAddress};

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Board {
    #[key]
    pub id: u32,
    pub origin: Position,
    pub width: u32,
    pub height: u32,
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct PWarPixel {
    #[key]
    pub position: Position,
    pub owner: ContractAddress,
}


#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct GameId {
    #[key]
    pub x: u32,
    #[key]
    pub y: u32,
    pub value: u32,
}
