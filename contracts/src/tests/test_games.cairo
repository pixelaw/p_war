use dojo::event::EventStorage;
use dojo::model::{ModelStorage, ModelValueStorage};
use dojo::world::{WorldStorage, WorldStorageTrait};
use p_war::tests::utils::{deploy_p_war};
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
    models::{pixel::{Pixel, PixelUpdate},},
    actions::{
        actions as core_actions, IActionsDispatcher as ICoreActionsDispatcher,
        IActionsDispatcherTrait as ICoreActionsDispatcherTrait
    },
    utils::{DefaultParameters, Position as PixelawPosition}
};
use pixelaw_test_helpers::{setup_core_initialized};
use starknet::{
    class_hash::Felt252TryIntoClassHash, ContractAddress, testing::{set_block_timestamp}
};

const COLOR: u32 = 0x000000ff;

#[test]
#[available_gas(999_999_999)]
fn test_game_created() {
    let (mut world, _core_actions, _player_1, _player_2) = setup_core_initialized();
    let (_world, p_war_actions, _propose_action, _voting_action, _guild, _allowed_app) =
        deploy_p_war(
        ref world
    );
    // caller
    let _caller = starknet::contract_address_const::<0x0>();

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

    assert(id == 1, 'game not created');
}
