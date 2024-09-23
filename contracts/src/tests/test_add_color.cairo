use p_war::{
    models::{
        game::{Game, game}, board::{Board, GameId, Position, board, game_id}, proposal::{Proposal},
        allowed_app::AllowedApp, allowed_color::{AllowedColor, PaletteColors},
    },
    systems::{
        actions::{p_war_actions, IActionsDispatcher, IActionsDispatcherTrait},
        propose::{propose_actions, IProposeDispatcher, IProposeDispatcherTrait},
        voting::{voting_actions, IVotingDispatcher, IVotingDispatcherTrait}
    },
    constants::{PROPOSAL_DURATION}
};

use pixelaw::core::{
    models::{
        permissions::permissions, pixel::{pixel, Pixel, PixelUpdate}, queue::queue_item,
        registry::{app, app_user, app_name, core_actions_address, instruction}
    },
    actions::{
        actions as core_actions, IActionsDispatcher as ICoreActionsDispatcher,
        IActionsDispatcherTrait as ICoreActionsDispatcherTrait
    },
    utils::{DefaultParameters, Position as PixelawPosition}
};
use starknet::{
    class_hash::Felt252TryIntoClassHash, ContractAddress, testing::{set_block_timestamp},
};

const COLOR: u32 = 0xAAAAAAFF;

#[test]
#[available_gas(999_999_999)]
fn test_add_color() {
    // caller
    let caller = starknet::contract_address_const::<0x0>();
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
    println!("id = {}", id);

    let NEW_COLOR: u32 = 0xAABBCCFF;

    // let args = Args{
    //     address: starknet::contract_address_const::<0x0>(),
    //     arg1: NEW_COLOR.into(),
    //     arg2: 0,
    // };

    let index = propose_system
        .create_proposal(
            game_id: id, proposal_type: 1, target_args_1: NEW_COLOR, target_args_2: 0,
        );

    // let game = get!(
    //     world,
    //     (id),
    //     (Game)
    // );

    let oldest_color_palette = get!(world, (id, 0), (PaletteColors));

    // let index = propose_system.toggle_allowed_color(id, NEW_COLOR);
    let vote_px = 3;
    voting_system.vote(id, index, vote_px, true);

    let proposal = get!(world, (id, index), (Proposal));

    println!("\n## PROPOSAL INFO ##");
    println!("Proposal end: {}", proposal.end);

    // should add cheat code to spend time
    set_block_timestamp(
        proposal.end + PROPOSAL_DURATION
    ); // NOTE: we need to set block timestamp forcely
    propose_system.activate_proposal(id, index, array![default_params.position].into());

    // call place_pixel
    let new_params = DefaultParameters {
        for_player: caller,
        for_system: caller,
        position: PixelawPosition { x: 1, y: 1 },
        color: NEW_COLOR
    };

    p_war_actions.interact(new_params);

    // check if the oldest color is unusable
    let oldest_color_allowed = get!(world, (id, oldest_color_palette.color), (AllowedColor));

    println!(
        "@@@@@ OLDEST_ALLOWED: {}, {} @@@@",
        oldest_color_palette.color,
        oldest_color_allowed.is_allowed
    );

    assert(oldest_color_allowed.is_allowed == false, 'the oldest became unusable');
}
