use pixelaw::core::utils::Position;
use starknet::{ContractAddress};

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct Board {
    #[key]
    id: u32,
    origin: Position,
    width: u32,
    height: u32,
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct PWarPixel {
    #[key]
    position: Position,
    owner: ContractAddress
}


#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct GameId {
    #[key]
    x: u32,
    #[key]
    y: u32,
    value: u32
}
