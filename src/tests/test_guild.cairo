use starknet::{
    class_hash::Felt252TryIntoClassHash, ContractAddress, testing::{set_block_timestamp, set_account_contract_address, set_contract_address},
    get_block_timestamp, contract_address_const
};

use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

use dojo::utils::test::{spawn_test_world, deploy_contract};

use p_war::{
    models::{
        player::{Player, player}, game::{Game, game}, board::{Board, GameId, board, game_id, p_war_pixel},
        proposal::{Proposal, pixel_recovery_rate, proposal, player_vote},
        allowed_app::{AllowedApp, allowed_app},
        allowed_color::{AllowedColor, allowed_color, palette_colors, in_palette, game_palette},
        guilds::{Guild, guild},
    },
    systems::{
        actions::{p_war_actions, IActionsDispatcher, IActionsDispatcherTrait},
        propose::{propose, IProposeDispatcher, IProposeDispatcherTrait},
        voting::{voting, IVotingDispatcher, IVotingDispatcherTrait},
        guilds::{guild_actions, IGuild, IGuildDispatcher, IGuildDispatcherTrait},
    },
    tests::utils as test_utils
};

use pixelaw::core::{
    models::{
        permissions::{permissions}, pixel::{pixel, Pixel, PixelUpdate}, queue::queue_item,
        registry::{app, app_user, app_name, core_actions_address, instruction}
    },
    actions::{
        actions as core_actions, IActionsDispatcher as ICoreActionsDispatcher,
        IActionsDispatcherTrait as ICoreActionsDispatcherTrait
    },
    utils::{DefaultParameters, Position}
};

const WHITE_COLOR: u32 = 0xFFFFFFFF;
const GAME_ORIGIN_POSITION: Position = Position { x: 0, y: 0 };
const GAME_PAINT_POSITION: Position = Position { x: 1, y: 1 };

#[test]
#[available_gas(999_999_999)]
fn test_guild_operations() {

    println!("start test");

    let ZERO_ADDRESS: ContractAddress = contract_address_const::<0>();

    // Initialize the world and the actions
    let (world, _core_actions, p_war_actions, _propose, _voting, guild_actions) = p_war::tests::utils::setup();

    println!("setup");

    // Setup players
    let PLAYER_1 = contract_address_const::<0x1337>();
    let PLAYER_2 = contract_address_const::<0x42>();
    // let PLAYER_3 = contract_address_const::<0x43>();

    println!("setup players");

    // Impersonate player1
    set_account_contract_address(PLAYER_1);

    println!("impersonate player1");

    // Create a game
    p_war_actions
    .interact(
        DefaultParameters {
            for_player: ZERO_ADDRESS,
            for_system: ZERO_ADDRESS,
            position: GAME_ORIGIN_POSITION,
            color: WHITE_COLOR
        }
    );

    let game_id = p_war_actions.get_game_id(GAME_ORIGIN_POSITION);
    println!("game created: game_id = {}", game_id);

    //was not able to import set_call from core::helpers
    set_account_contract_address(PLAYER_1);
    set_contract_address(PLAYER_1);
    let guild_id = guild_actions.create_guild(game_id, 'Test Guild');
    println!("guild created: guild_id = {}", guild_id);
    
    // Check if the guild was created
    let guild = get!(world, (game_id, guild_id), (Guild));
    assert(guild.guild_name == 'Test Guild', 'Guild name mismatch');
    assert(guild.creator == PLAYER_1, 'Guild creator mismatch');
    assert(guild.member_count == 1, 'create, should be 1');

    println!("check guild passed");

    // Add a member
    set_account_contract_address(PLAYER_1);
    set_contract_address(PLAYER_1);
    guild_actions.add_member(game_id, guild_id, PLAYER_2);
    
    // Check if the member was added
    let updated_guild = get!(world, (game_id, guild_id), (Guild));
    assert(updated_guild.member_count == 2, 'Member count should be 2');

    // Remove a member
    guild_actions.remove_member(game_id, guild_id, PLAYER_2);
    
    // Check if the member was removed
    let final_guild = get!(world, (game_id, guild_id), (Guild));
    assert(final_guild.member_count == 1, 'remove, should be 1');

    println!("guild operations passed");

    // Test guild points
    // paint a color inside of the grid
    // set_account_contract_address(PLAYER_1);
    // set_contract_address(PLAYER_1);
    // p_war_actions
    //     .interact(
    //         DefaultParameters {
    //             for_player: ZERO_ADDRESS, // Leave this 0 if not processing the Queue
    //             for_system: ZERO_ADDRESS, // Leave this 0 if not processing the Queue
    //             position: GAME_PAINT_POSITION,
    //             color: WHITE_COLOR
    //         }
    //     );
    // let action_game_id = p_war_actions.get_game_id(GAME_ORIGIN_POSITION);
    // assert(action_game_id == game_id, 'game id mismatch');
    // let guild_points = guild_actions.get_guild_points(game_id, guild_id);
    // println!("test: guild_points: {}", guild_points);
    // assert(guild_points == 1, 'Guild points mismatch');
}