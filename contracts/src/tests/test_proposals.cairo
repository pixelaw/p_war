use dojo::event::EventStorage;
use dojo::model::{ModelStorage, ModelValueStorage};
use dojo::world::{WorldStorage, WorldStorageTrait};
use p_war::tests::utils::{deploy_p_war};
use p_war::{
    models::{
        game::{Game}, board::{Board, GameId, Position}, proposal::{Proposal}, player::{Player},
        allowed_app::AllowedApp, allowed_color::{AllowedColor, PaletteColors},
    },
    systems::{
        actions::{p_war_actions, IActionsDispatcher, IActionsDispatcherTrait},
        propose::{propose_actions, IProposeDispatcher, IProposeDispatcherTrait},
        voting::{voting_actions, IVotingDispatcher, IVotingDispatcherTrait}
    },
    constants::{DEFAULT_AREA, PROPOSAL_DURATION, GAME_DURATION}
};
use pixelaw::core::{
    models::{pixel::{Pixel, PixelUpdate},},
    actions::{
        actions as core_actions, IActionsDispatcher as ICoreActionsDispatcher,
        IActionsDispatcherTrait as ICoreActionsDispatcherTrait
    },
    utils::{DefaultParameters, Position as PixelawPosition, is_pixel_color}
};
use pixelaw_test_helpers::{setup_core_initialized};
use starknet::{
    class_hash::Felt252TryIntoClassHash, ContractAddress, testing::{set_block_timestamp},
    get_tx_info, get_block_timestamp
};

const WHITE_COLOR: u32 = 0xFFFFFFFF;
const NEW_COLOR: u32 = 0xAABBCCFF;
const RED_COLOR: u32 = 0xFF0000FF;

const GAME_ORIGIN_POSITION: Position = Position { x: 0, y: 0 };
const GAME_PAINT_POSITION: Position = Position { x: 1, y: 1 };

// Proposal type 2
const PROPOSAL_TYPE_RESET_TO_WHITE_BY_COLOR: u8 = 2;
const VOTE_PIXEL_COUNT: u32 = 3;

#[test]
#[available_gas(999_999_999)]
fn test_add_color() {
    let (mut world, _core_actions, _player_1, _player_2) = setup_core_initialized();
    let (_world, p_war_actions, propose_action, voting_action, _guild, _allowed_app) = deploy_p_war(
        ref world
    );

    let default_params = DefaultParameters {
        player_override: Option::None,
        system_override: Option::None,
        area_hint: Option::None,
        position: GAME_ORIGIN_POSITION,
        color: WHITE_COLOR
    };

    // create a game
    p_war_actions.interact(default_params);

    let id = p_war_actions
        .get_game_id(Position { x: default_params.position.x, y: default_params.position.y });
    println!("id = {}", id);

    let index = propose_action
        .create_proposal(
            game_id: id, proposal_type: 1, target_args_1: NEW_COLOR, target_args_2: 0,
        );

    let oldest_color_pallette: PaletteColors = world.read_model((id, 0));

    let vote_px = 3;
    voting_action.vote(id, index, vote_px, true);

    let proposal: Proposal = world.read_model((id, index));

    println!("\n## PROPOSAL INFO ##");
    println!("Proposal end: {}", proposal.end);

    // should add cheat code to spend time
    set_block_timestamp(
        proposal.end + PROPOSAL_DURATION
    ); // NOTE: we need to set block timestamp forcely
    propose_action.activate_proposal(id, index, array![default_params.position].into());

    // call place_pixel
    let new_params = DefaultParameters {
        player_override: Option::None,
        system_override: Option::None,
        area_hint: Option::None,
        position: GAME_PAINT_POSITION,
        color: NEW_COLOR
    };

    p_war_actions.interact(new_params);

    // check if the oldest color is unusable
    let oldest_color_allowed: AllowedColor = world.read_model((id, oldest_color_pallette.color));

    println!(
        "@@@@@ OLDEST_ALLOWED: {}, {} @@@@",
        oldest_color_pallette.color,
        oldest_color_allowed.is_allowed
    );

    let newest_color: PaletteColors = world.read_model((id, 8));
    let newest_color_allowed: AllowedColor = world.read_model((id, newest_color.color));

    println!(
        "@@@@@ NEWEST_ALLOWED: {}, {} @@@@", newest_color.color, newest_color_allowed.is_allowed
    );

    assert(oldest_color_allowed.is_allowed == false, 'the oldest became unusable');
    //print_all_colors(ref world, id);
    assert(newest_color.color == NEW_COLOR, 'newest_color is the new color');
    assert(newest_color_allowed.is_allowed == true, 'the newest is usable');
}

#[test]
#[available_gas(999_999_999)]
fn test_reset_to_white() {
    let (mut world, _core_actions, _player_1, _player_2) = setup_core_initialized();
    let (_world, p_war_actions, propose_action, voting_action, _guild, _allowed_app) = deploy_p_war(
        ref world
    );

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

    voting_action.vote(game_id, proposal_id, VOTE_PIXEL_COUNT, true);

    let proposal: Proposal = world.read_model((game_id, proposal_id));

    print!("proposal.end: {}\n", proposal.end);

    // Fast-forward blocktime by 60 seconds
    set_block_timestamp(get_block_timestamp() + PROPOSAL_DURATION);

    // Activate the proposal
    propose_action.activate_proposal(game_id, proposal_id, array![GAME_PAINT_POSITION].into());

    // Retrieve the pixel that was reset
    assert(
        is_pixel_color(ref world, GAME_PAINT_POSITION, WHITE_COLOR),
        'Pixel should be entirely white'
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

    assert(
        is_pixel_color(ref world, GAME_PAINT_POSITION, RED_COLOR), 'Pixel should be entirely red'
    );

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
        is_pixel_color(ref world, GAME_PAINT_POSITION, WHITE_COLOR),
        'Pixel should be entirely white'
    );
}

#[test]
#[available_gas(999_999_999)]
fn test_expand_area() {
    let (mut world, _core_actions, _player_1, _player_2) = setup_core_initialized();
    let (_world, p_war_actions, propose_action, voting_action, _guild, _allowed_app) = deploy_p_war(
        ref world
    );

    let default_params = DefaultParameters {
        player_override: Option::None,
        system_override: Option::None,
        area_hint: Option::None,
        position: GAME_ORIGIN_POSITION,
        color: WHITE_COLOR
    };

    // create a game
    p_war_actions.interact(default_params);

    let id = p_war_actions
        .get_game_id(Position { x: default_params.position.x, y: default_params.position.y });
    print!("id = {}", id);

    let index = propose_action
        .create_proposal(game_id: id, proposal_type: 4, target_args_1: 20, target_args_2: 30,);

    let vote_px = 3;
    voting_action.vote(id, index, vote_px, true);

    let proposal: Proposal = world.read_model((id, index));

    print!("\n## PROPOSAL INFO ##\n");
    print!("Proposal end: {}\n", proposal.end);

    // should add cheat code to spend time
    set_block_timestamp(proposal.end + PROPOSAL_DURATION);
    propose_action.activate_proposal(id, index, array![default_params.position].into());

    let board: Board = world.read_model(id);

    assert(board.width == DEFAULT_AREA + 20, 'game area extended');
    assert(board.height == DEFAULT_AREA + 30, 'game area extended');
}

#[test]
#[available_gas(999_999_999)]
fn test_extend_game_end() {
    let (mut world, _core_actions, _player_1, _player_2) = setup_core_initialized();
    let (_world, p_war_actions, propose_action, voting_action, _guild, _allowed_app) = deploy_p_war(
        ref world
    );

    let default_params = DefaultParameters {
        player_override: Option::None,
        system_override: Option::None,
        area_hint: Option::None,
        position: GAME_ORIGIN_POSITION,
        color: WHITE_COLOR
    };

    // create a game
    p_war_actions.interact(default_params);

    let id = p_war_actions
        .get_game_id(Position { x: default_params.position.x, y: default_params.position.y });
    println!("id = {}", id);

    let index = propose_action
        .create_proposal(
            game_id: id,
            proposal_type: 3,
            target_args_1: 60 * 60, // extend the game for 1 hour
            target_args_2: 0,
        );

    let vote_px = 3;
    voting_action.vote(id, index, vote_px, true);

    let proposal: Proposal = world.read_model((id, index));

    println!("## PROPOSAL INFO ##");
    println!("Proposal end: {}", proposal.end);

    // should add cheat code to spend time
    set_block_timestamp(proposal.end + 1); // NOTE: we need to set block timestamp forcely
    propose_action.activate_proposal(id, index, array![default_params.position].into());

    let game: Game = world.read_model(id);

    assert(game.end > GAME_DURATION + 60 * 60 - 1, 'game end extended');
}
