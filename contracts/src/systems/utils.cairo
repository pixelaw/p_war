use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

use p_war::constants::DEFAULT_PX;
use p_war::models::{
    game::{Game, Status}, board::{Board, GameId, Position}, player::{Player},
    proposal::{PixelRecoveryRate}, allowed_color::AllowedColor, allowed_app::AllowedApp,
    guilds::{Guild}
};
use starknet::{
    ContractAddress, get_block_timestamp, get_caller_address, get_contract_address, get_tx_info
};

fn update_max_px(world: IWorldDispatcher, game_id: usize, player_address: ContractAddress) {
    let mut player = get!(world, (player_address), (Player));

    let game = get!(world, (game_id), (Game));

    let mut max_px = game.const_val
        + game.coeff_own_pixels * player.num_owns
        + game.coeff_commits * player.num_commit;

    if max_px < 1 {
        max_px = 1;
    };

    // if the player is new one:
    if player.max_px == 0 {
        player.current_px = max_px;
        player.last_date = get_block_timestamp();
        player.num_owns = 0;
        player.num_commit = 0;
        player.is_banned = false;
    };

    player.max_px = max_px;

    set!(world, (player));
}

fn recover_px(world: IWorldDispatcher, game_id: usize, player_address: ContractAddress) {
    update_max_px(world, game_id, player_address);

    let mut player = get!(world, (player_address), (Player));

    println!("create_game 3");
    let recovery_rate = get!(world, (game_id), (PixelRecoveryRate));

    println!("create_game 4");
    let current_time = get_block_timestamp();
    let time_diff = current_time - player.last_date;

    if recovery_rate.rate == 0 {
        return;
    }

    let recover_pxs: u32 = ((time_diff) / recovery_rate.rate).try_into().unwrap();

    if player.max_px >= (player.current_px + recover_pxs) {
        player.current_px = player.current_px + recover_pxs;
    } else {
        player.current_px = player.max_px;
    }

    print!("\n## RECOVERY_RATE: {} ##\n", recovery_rate.rate);
    print!("## RECOVER_PXS: {} ##\n", recover_pxs);
    print!("## CURRENT PX: {} ##\n", player.current_px);

    set!(world, (player));
}

fn check_game_status(status: Status) -> bool {
    status == Status::Pending || status == Status::Ongoing
}

fn is_member(world: IWorldDispatcher, game_id: usize, guild_id: usize, member: ContractAddress) -> bool {
    let guild = get!(world, (game_id, guild_id), (Guild));
    let mut is_member = false;
    let mut i = 0;
    loop {
        if i == guild.members.len() {
            break;
        }
        if guild.members.at(i) == @member {
            is_member = true;
            break;
        }
        i += 1;
    };
    is_member
}