use pixelaw::core::{utils::{DefaultParameters, Position}};
use pixelaw_testing::helpers::{setup_core};
use pwar::tests::utils::deploy_pwar;
use super::super::systems::actions::IActionsDispatcherTrait;

const COLOR: u32 = 0x000000ff;

#[test]
#[available_gas(999_999_999)]
fn test_game_created() {
    let (mut world, _core_actions, _player_1, _player_2) = setup_core();
    let (pwar_actions, _propose_action, _voting_action, _guild) = deploy_pwar(ref world);
    // caller
    let _caller = starknet::contract_address_const::<0x0>();

    let default_params = DefaultParameters {
        player_override: Option::None,
        system_override: Option::None,
        area_hint: Option::None,
        position: Position { x: 0, y: 0 },
        color: COLOR,
    };

    // create a game
    pwar_actions.interact(default_params);

    let id = pwar_actions
        .get_game_id(Position { x: default_params.position.x, y: default_params.position.y });
    println!("id = {}", id);

    assert(id == 1, 'game not created');
}
