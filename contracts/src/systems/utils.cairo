use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

use p_war::models::{
    game::{Game, Status}, board::{Board, GameId, Position}, player::{Player},
    proposal::{PixelRecoveryRate}, allowed_color::AllowedColor, allowed_app::AllowedApp
};
use starknet::{
    ContractAddress, get_block_timestamp, get_caller_address, get_contract_address, get_tx_info
};

fn check_game_status(status: Status) -> bool {
    status == Status::Pending || status == Status::Ongoing
}
