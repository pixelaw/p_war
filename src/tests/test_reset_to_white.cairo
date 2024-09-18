use starknet::{
    class_hash::Felt252TryIntoClassHash, ContractAddress, testing::{set_block_timestamp, set_account_contract_address},
    get_block_timestamp,contract_address_const
};

use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

use dojo::utils::test::{spawn_test_world, deploy_contract};

use p_war::{
    models::{
        player::{player}, game::{Game, game}, board::{Board, GameId, board, game_id, p_war_pixel},
        proposal::{Proposal, pixel_recovery_rate, proposal, player_vote},
        allowed_app::{AllowedApp, allowed_app},
        allowed_color::{AllowedColor, allowed_color, palette_colors, in_palette, game_palette},
    },
    systems::{
        actions::{p_war_actions, IActionsDispatcher, IActionsDispatcherTrait},
        propose::{propose, IProposeDispatcher, IProposeDispatcherTrait},
        voting::{voting, IVotingDispatcher, IVotingDispatcherTrait}
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
    utils::{DefaultParameters, Position, is_pixel_color}
};


const WHITE_COLOR: u32 = 0xFFFFFFFF;
const RED_COLOR: u32 = 0xFF0000FF;

const GAME_ORIGIN_POSITION: Position = Position { x: 0, y: 0 };
const GAME_PAINT_POSITION: Position = Position { x: 1, y: 1 };


// Proposal type 2
const PROPOSAL_TYPE_RESET_TO_WHITE_BY_COLOR: u8 = 2;

const VOTE_PIXEL_COUNT: u32 = 3;

#[test]
#[available_gas(999_999_999)]
fn test_reset_to_white() {
    let ZERO_ADDRESS: ContractAddress = contract_address_const::<0>();

    // Initialize the world and the actions
    let (world, _, p_war_actions, propose, voting,) = p_war::tests::utils::setup();


    // Setup players
    let PLAYER_1 = contract_address_const::<0x1337>();
    let PLAYER_2 = contract_address_const::<0x42>();

    // Impersonate player1
    set_account_contract_address(PLAYER_1);



    // Create a game.
    // This creates a 10x10 grid to the bottom-right of the start_position
    p_war_actions
        .interact(
            DefaultParameters {
                for_player: ZERO_ADDRESS, // Leave this 0 if not processing the Queue
                for_system: ZERO_ADDRESS, // Leave this 0 if not processing the Queue
                position: GAME_ORIGIN_POSITION,
                color: WHITE_COLOR
            }
        );

    // paint a color inside of the grid
    p_war_actions
        .interact(
            DefaultParameters {
                for_player: ZERO_ADDRESS, // Leave this 0 if not processing the Queue
                for_system: ZERO_ADDRESS, // Leave this 0 if not processing the Queue
                position: GAME_PAINT_POSITION,
                color: RED_COLOR
            }
        );

    let game_id = p_war_actions.get_game_id(GAME_ORIGIN_POSITION);

    print!("game_id = {}", game_id);

    let proposal_id = propose
        .create_proposal(
            game_id,
            proposal_type: PROPOSAL_TYPE_RESET_TO_WHITE_BY_COLOR,
            target_args_1: RED_COLOR,
            target_args_2: 0
        );

    // let index = propose_system.toggle_allowed_color(id, NEW_COLOR);

    voting.vote(game_id, proposal_id, VOTE_PIXEL_COUNT, true);

    let proposal = get!(world, (game_id, proposal_id), (Proposal));

    print!("proposal.end: {}\n", proposal.end);

    // Fast-forward blocktime by 60 seconds
    set_block_timestamp(get_block_timestamp() + 60);

    // Activate the proposal
    propose.activate_proposal(game_id, proposal_id, array![GAME_PAINT_POSITION].into());

    // Retrieve the pixel that was reset
    assert(is_pixel_color(world, GAME_PAINT_POSITION, WHITE_COLOR), 'Pixel should be entirely white');

    // Now try to paint on it again
    p_war_actions
        .interact(
            DefaultParameters {
                for_player: ZERO_ADDRESS, // Leave this 0 if not processing the Queue
                for_system: ZERO_ADDRESS, // Leave this 0 if not processing the Queue
                position: GAME_PAINT_POSITION,
                color: RED_COLOR
            }
        );

    assert(is_pixel_color(world, GAME_PAINT_POSITION, RED_COLOR), 'Pixel should be entirely red');

    // Impersonate player2
    set_account_contract_address(PLAYER_2);

    // Now try to paint on it again
    p_war_actions
        .interact(
            DefaultParameters {
                for_player: ZERO_ADDRESS, // Leave this 0 if not processing the Queue
                for_system: ZERO_ADDRESS, // Leave this 0 if not processing the Queue
                position: GAME_PAINT_POSITION,
                color: WHITE_COLOR
            }
        );

    assert(is_pixel_color(world, GAME_PAINT_POSITION, WHITE_COLOR), 'Pixel should be entirely white');

}
