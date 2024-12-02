use p_war::tests::utils::{deploy_p_war, print_all_colors};
use dojo::model::{ModelStorage, ModelValueStorage};
use dojo::world::{WorldStorage, WorldStorageTrait};
use dojo::event::EventStorage;
use pixelaw_test_helpers::{setup_core_initialized};
use starknet::{class_hash::Felt252TryIntoClassHash, ContractAddress, testing::{set_block_timestamp}};
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
    constants::{GAME_DURATION}
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

const COLOR: u32 = 0xAAAAAAFF;

#[test]
#[available_gas(999_999_999)]
fn test_extend_game_end() {
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
