use crate::models::game::Status;

pub fn check_game_status(status: Status) -> bool {
    status == Status::Pending || status == Status::Ongoing
}
