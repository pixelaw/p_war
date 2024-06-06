use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use starknet::{ContractAddress, get_block_timestamp, get_caller_address, get_contract_address, get_tx_info};
use p_war::models::{
    game::{Game, Status},
    board::{Board, GameId, Position},
    player::{Player},
    proposal::{PixelRecoveryRate},
    allowed_color::AllowedColor,
    allowed_app::AllowedApp
};

const DEFAULT_PX: u32 = 10;

fn recover_px(world: IWorldDispatcher, game_id: usize) {
    let player_address = get_tx_info().unbox().account_contract_address;
    let mut player = get!(
        world,
        (player_address),
        (Player)
    );

    // if this is first time for the caller, let's set initial px.
    if player.max_px == 0 {
        player.max_px = DEFAULT_PX;
        player.current_px = DEFAULT_PX;
        player.last_date = get_block_timestamp();
        player.is_banned = false;
    } else {
        let recovery_rate = get!(
            world,
            (game_id),
            (PixelRecoveryRate)
        );

        let current_time = get_block_timestamp();
        let time_diff = current_time - player.last_date;

        print!("\n ## RECOVERY_RATE: {} ##\n", recovery_rate.rate);

        let recover_pxs: u32 = ((time_diff) / recovery_rate.rate).try_into().unwrap();

        if player.max_px >= (player.current_px + recover_pxs) {
            player.current_px = player.current_px + recover_pxs;
        } else {
            player.current_px = player.max_px;
        }
    }

    print!("\n ### CURRENT PX: {} ###\n", player.current_px);

    set!(
        world,
        (player)
    );
}