use p_war::tests::utils::{deploy_p_war};
use dojo::model::{ModelStorage, ModelValueStorage};
use dojo::world::{WorldStorage, WorldStorageTrait};
use dojo::event::EventStorage;
use pixelaw_test_helpers::{setup_core_initialized};
use starknet::{class_hash::Felt252TryIntoClassHash, ContractAddress, testing::{set_block_timestamp}, get_tx_info};
use p_war::{
    models::{
        game::{Game}, board::{Board, GameId, Position}, proposal::{Proposal},
        player::{Player},
        allowed_app::AllowedApp, allowed_color::{AllowedColor, PaletteColors},
    },
    systems::{
        actions::{p_war_actions, IActionsDispatcher, IActionsDispatcherTrait},
        propose::{propose_actions, IProposeDispatcher, IProposeDispatcherTrait},
        voting::{voting_actions, IVotingDispatcher, IVotingDispatcherTrait}
    },
    constants::{DEFAULT_AREA, PROPOSAL_DURATION}
};
use pixelaw::core::{
    models::{
        pixel::{Pixel, PixelUpdate},
    },
    actions::{
        actions as core_actions, IActionsDispatcher as ICoreActionsDispatcher,
        IActionsDispatcherTrait as ICoreActionsDispatcherTrait
    },
    utils::{DefaultParameters, Position as PixelawPosition}
};

const COLOR: u32 = 0x000000ff;

#[test]
#[available_gas(999_999_999)]
fn test_expand_area() {
    let (mut world, _core_actions, _player_1, _player_2) = setup_core_initialized();
    let (_world, p_war_actions, propose_action, voting_action, _guild, _allowed_app) = deploy_p_war(ref world);

    let default_params = DefaultParameters {
        player_override: Option::None,
        system_override: Option::None,
        area_hint: Option::None,
        position: PixelawPosition { x: 0, y: 0 },
        color: COLOR
    };

    // create a game
    p_war_actions.interact(default_params);

    let id = p_war_actions
        .get_game_id(Position { x: default_params.position.x, y: default_params.position.y });
    print!("id = {}", id);

    let index = propose_action
        .create_proposal(game_id: id, proposal_type: 4, target_args_1: 20, target_args_2: 30,);

    // let index = propose_system.toggle_allowed_color(id, NEW_COLOR);
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
