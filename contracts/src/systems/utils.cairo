use dojo::event::EventStorage;
use dojo::model::{ModelStorage, ModelValueStorage};
use dojo::world::storage::WorldStorage;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

use p_war::models::{
    game::{Game, Status}, board::{Board, GameId, Position}, player::{Player},
    proposal::{PixelRecoveryRate}, allowed_color::AllowedColor, allowed_app::AllowedApp,
    guilds::{Guild}
};
use starknet::{
    ContractAddress, get_block_timestamp, get_caller_address, get_contract_address, get_tx_info
};

pub fn check_game_status(status: Status) -> bool {
    status == Status::Pending || status == Status::Ongoing
}
