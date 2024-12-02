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
    constants::{PROPOSAL_DURATION}
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

fn test_add_color() {
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

    let NEW_COLOR: u32 = 0xAABBCCFF;

    // let args = Args{
    //     address: starknet::contract_address_const::<0x0>(),
    //     arg1: NEW_COLOR.into(),
    //     arg2: 0,
    // };

    let index = propose_action
        .create_proposal(
            game_id: id, proposal_type: 1, target_args_1: NEW_COLOR, target_args_2: 0,
        );

    // let game = get!(
    //     world,
    //     (id),
    //     (Game)
    // );

    let oldest_color_pallette: PaletteColors = world.read_model((id, 0));

    // let index = propose_system.toggle_allowed_color(id, NEW_COLOR);
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
        position: PixelawPosition { x: 1, y: 1 },
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
        "@@@@@ NEWEST_ALLOWED: {}, {} @@@@",
        newest_color.color,
        newest_color_allowed.is_allowed
    );

    assert(oldest_color_allowed.is_allowed == false, 'the oldest became unusable');
    //print_all_colors(ref world, id);
    assert(newest_color.color == NEW_COLOR, 'newest_color is the new color');
    assert(newest_color_allowed.is_allowed == true, 'the newest is usable');
}
