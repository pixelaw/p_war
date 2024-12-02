use p_war::tests::utils::{deploy_p_war, print_all_colors};
use dojo::model::{ModelStorage, ModelValueStorage};
use dojo::world::{WorldStorage, WorldStorageTrait};
use dojo::event::EventStorage;
use pixelaw_test_helpers::{setup_core_initialized};
use starknet::{class_hash::Felt252TryIntoClassHash, ContractAddress, testing::{set_block_timestamp}, get_block_timestamp};
use p_war::{
    models::{
        game::{Game}, board::{Board, GameId, Position}, proposal::{Proposal},
        allowed_app::AllowedApp, allowed_color::{AllowedColor, PaletteColors},
    },
    systems::{
        actions::{p_war_actions, IActionsDispatcher, IActionsDispatcherTrait},
        propose::{propose_actions, IProposeDispatcher, IProposeDispatcherTrait},
        voting::{voting_actions, IVotingDispatcher, IVotingDispatcherTrait}
    },
    constants::{GAME_DURATION, PROPOSAL_DURATION}
};
use pixelaw::core::{
    models::{
        pixel::{Pixel, PixelUpdate},
    },
    actions::{
        actions as core_actions, IActionsDispatcher as ICoreActionsDispatcher,
        IActionsDispatcherTrait as ICoreActionsDispatcherTrait
    },
    utils::{DefaultParameters, Position as PixelawPosition, is_pixel_color}
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
    let (mut world, _core_actions, _player_1, _player_2) = setup_core_initialized();
    let (_world, p_war_actions, propose_action, voting_action, _guild, _allowed_app) = deploy_p_war(ref world);

    // Create a game.
    // This creates a 10x10 grid to the bottom-right of the start_position
    p_war_actions
        .interact(
            DefaultParameters {
                player_override: Option::None,
                system_override: Option::None,
                area_hint: Option::None,
                position: GAME_ORIGIN_POSITION,
                color: WHITE_COLOR
            }
        );

    // paint a color inside of the grid
    p_war_actions
        .interact(
            DefaultParameters {
                player_override: Option::None, // Leave this 0 if not processing the Queue
                system_override: Option::None, // Leave this 0 if not processing the Queue
                area_hint: Option::None,
                position: GAME_PAINT_POSITION,
                color: RED_COLOR
            }
        );

    let game_id = p_war_actions.get_game_id(GAME_ORIGIN_POSITION);

    print!("game_id = {}", game_id);

    let proposal_id = propose_action
        .create_proposal(
            game_id,
            proposal_type: PROPOSAL_TYPE_RESET_TO_WHITE_BY_COLOR,
            target_args_1: RED_COLOR,
            target_args_2: 0
        );

    // let index = propose_system.toggle_allowed_color(id, NEW_COLOR);

    voting_action.vote(game_id, proposal_id, VOTE_PIXEL_COUNT, true);

    let proposal: Proposal = world.read_model((game_id, proposal_id));

    print!("proposal.end: {}\n", proposal.end);

    // Fast-forward blocktime by 60 seconds
    set_block_timestamp(get_block_timestamp() + PROPOSAL_DURATION);

    // Activate the proposal
    propose_action.activate_proposal(game_id, proposal_id, array![GAME_PAINT_POSITION].into());

    // Retrieve the pixel that was reset
    assert(
        is_pixel_color(ref world, GAME_PAINT_POSITION, WHITE_COLOR), 'Pixel should be entirely white'
    );

    // Now try to paint on it again
    p_war_actions
        .interact(
            DefaultParameters {
                player_override: Option::None, // Leave this 0 if not processing the Queue
                system_override: Option::None, // Leave this 0 if not processing the Queue
                area_hint: Option::None,
                position: GAME_PAINT_POSITION,
                color: RED_COLOR
            }
        );

    assert(is_pixel_color(ref world, GAME_PAINT_POSITION, RED_COLOR), 'Pixel should be entirely red');

    // Now try to paint on it again
    p_war_actions
        .interact(
            DefaultParameters {
                player_override: Option::None, // Leave this 0 if not processing the Queue
                system_override: Option::None, // Leave this 0 if not processing the Queue
                area_hint: Option::None,
                position: GAME_PAINT_POSITION,
                color: WHITE_COLOR
            }
        );

    assert(
        is_pixel_color(ref world, GAME_PAINT_POSITION, WHITE_COLOR), 'Pixel should be entirely white'
    );
}
