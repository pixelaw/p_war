use starknet::{ContractAddress};

#[derive(Copy, Drop, Serde, Introspect)]
struct Position {
    x: u32,
    y: u32
}

#[derive(Model, Copy, Drop, Serde)]
struct Board {
    #[key]
    id: usize,
    origin: Position,
    width: u32,
    height: u32,
}

#[derive(Model, Copy, Drop, Serde)]
struct PWarPixel {
    #[key]
    position: Position,
    owner: ContractAddress
}


#[derive(Model, Copy, Drop, Serde)]
struct GameId {
    #[key]
    x: u32,
    #[key]
    y: u32,
    value: usize
}

trait BoardTrait {
    fn is_in_board(self: Board, position: Position) -> bool;
}

impl BoardImpl of BoardTrait {
    fn is_in_board(self: Board, position: Position) -> bool {
        position.x >= self.origin.x &&
            position.x <= self.origin.x + self.width &&
            position.y >= self.origin.y &&
            position.y <= self.origin.y + self.height
    }
}