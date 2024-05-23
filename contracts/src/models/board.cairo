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
    length: u32,
    width: u32
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
            position.x <= self.origin.x + self.length &&
            position.y >= self.origin.y &&
            position.y <= self.origin.y + self.width
    }
}