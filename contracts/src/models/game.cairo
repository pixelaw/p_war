use starknet::get_block_timestamp;

#[derive(Model, Copy, Drop, Serde)]
struct Game {
    #[key]
    id: usize,
    start: u64,
    end: u64,
    proposal_idx: usize
}

#[derive(PartialEq, Copy, Drop, Serde)]
enum Status {
    Unknown,
    Pending,
    Ongoing,
    Completed
}

trait GameTrait {
    fn status(self: Game) -> Status;
}

impl GameImpl of GameTrait {
    fn status(self: Game) -> Status {

        if self.start == 0 && self.end == 0 {
            return Status::Unknown;
        }

        let time_stamp = get_block_timestamp();
        if time_stamp < self.start {
            Status::Pending
        } else if time_stamp >= self.end {
            Status::Completed
        } else {
            Status::Ongoing
        }
    }
}
