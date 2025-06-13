use starknet::ContractAddress;
use starknet::get_block_timestamp;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Game {
    #[key]
    pub id: u32,
    pub start: u64,
    pub end: u64,
    pub proposal_idx: u32,
    pub coeff_own_pixels: u32,
    pub coeff_commits: u32,
    pub winner_config: u32, // optimally, set by contract address.
    pub winner: ContractAddress,
    pub guild_ids: Span<u32>, //list of guild IDs inside the game pub struct
    pub guild_count: u32,
}

#[derive(PartialEq, Copy, Drop, Serde)]
pub enum Status {
    Unknown,
    Pending,
    Ongoing,
    Completed,
}

pub trait GameTrait {
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
