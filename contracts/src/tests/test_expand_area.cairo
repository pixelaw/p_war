use p_war::constants::{DEFAULT_AREA};

use p_war::{
    models::{
        game::{Game, game}, board::{Board, GameId, Position, board, game_id}, proposal::{Proposal},
        allowed_app::AllowedApp, allowed_color::{AllowedColor, PaletteColors},
    },
    systems::{
        actions::{p_war_actions, IActionsDispatcher, IActionsDispatcherTrait},
        propose::{propose, IProposeDispatcher, IProposeDispatcherTrait},
        voting::{voting, IVotingDispatcher, IVotingDispatcherTrait}
    }
};

use pixelaw::core::{utils::{DefaultParameters, Position as PixelawPosition}};
use starknet::{class_hash::Felt252TryIntoClassHash, ContractAddress, contract_address_const};

const COLOR: u32 = 0xAAAAAAFF;

#[test]
#[available_gas(999_999_999)]
fn test_expand_area() {
    // caller
    let caller = contract_address_const::<0x0>();

    let (world, _, p_war_actions, propose_system, voting_system, _) = p_war::tests::utils::setup();

    let default_params = DefaultParameters {
        for_player: caller,
        for_system: caller,
        position: PixelawPosition { x: 0, y: 0 },
        color: COLOR
    };

    // create a game
    p_war_actions.interact(default_params);

    let id = p_war_actions
        .get_game_id(Position { x: default_params.position.x, y: default_params.position.y });
    print!("id = {}", id);

    let index = propose_system
        .create_proposal(game_id: id, proposal_type: 4, target_args_1: 20, target_args_2: 30,);

    // let index = propose_system.toggle_allowed_color(id, NEW_COLOR);
    voting_system.vote(id, index, true);

    let proposal = get!(world, (id, index), (Proposal));

    print!("\n## PROPOSAL INFO ##\n");
    print!("Proposal end: {}\n", proposal.end);

    // should add cheat code to spend time
    propose_system.activate_proposal(id, index);

    let board = get!(world, (id), (Board));

    assert(board.width == DEFAULT_AREA + 20, 'game area extended');
    assert(board.height == DEFAULT_AREA + 30, 'game area extended');
}
