#[cfg(test)]
mod tests {
    use starknet::{
        class_hash::Felt252TryIntoClassHash,
        ContractAddress,
        get_caller_address,
        get_tx_info,
    };
    // import world dispatcher
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    // import test utils
    use dojo::test_utils::{spawn_test_world, deploy_contract};
    // import test utils
    use p_war::{
        models::{
            game::{Game, game},
            board::{Board, GameId, Position, board, game_id},
            player::{Player},
            allowed_color::AllowedColor
        },
        systems::{
            actions::{p_war_actions, IActionsDispatcher, IActionsDispatcherTrait},
            propose::{propose, IProposeDispatcher, IProposeDispatcherTrait},
            voting::{voting, IVotingDispatcher, IVotingDispatcherTrait}
        }
    };
    use pixelaw::core::{
        models::{
            permissions::permissions,
            pixel::{pixel, Pixel, PixelUpdate},
            queue::queue_item,
            registry::{app, app_user, app_name, core_actions_address, instruction}
        },
        actions::{
            actions as core_actions,
            IActionsDispatcher as ICoreActionsDispatcher,
            IActionsDispatcherTrait as ICoreActionsDispatcherTrait
        },
        utils::{DefaultParameters, Position as PixelawPosition}
    };

    const COLOR: u32 = 0xFF000000;

    #[test]
    #[available_gas(999_999_999)]
    fn test_create_game() {
        // caller
        let caller = starknet::contract_address_const::<0x0>();

        // models
        let mut models = array![
            app::TEST_CLASS_HASH,
            app_name::TEST_CLASS_HASH,
            app_user::TEST_CLASS_HASH,
            core_actions_address::TEST_CLASS_HASH,
            core_actions_address::TEST_CLASS_HASH,
            permissions::TEST_CLASS_HASH,
            queue_item::TEST_CLASS_HASH,

            game::TEST_CLASS_HASH,
            board::TEST_CLASS_HASH,
            game_id::TEST_CLASS_HASH
        ];

        // deploy world with models
        let world = spawn_test_world(models);

        let core_actions_contract_address = world
            .deploy_contract('salt', core_actions::TEST_CLASS_HASH.try_into().unwrap());
        let core_actions = ICoreActionsDispatcher { contract_address: core_actions_contract_address };

        core_actions.init();

        // deploy systems contract
        let contract_address = world
            .deploy_contract('salty', p_war_actions::TEST_CLASS_HASH.try_into().unwrap());
        let actions_system = IActionsDispatcher { contract_address };

        let default_params = DefaultParameters{
            for_player: caller,
            for_system: caller,
            position: PixelawPosition {
                x: 0,
                y: 0
            },
            color: COLOR
        };
        
        // create a game
        actions_system.interact(default_params);
        let id = actions_system.get_game_id(Position { x: default_params.position.x, y: default_params.position.y });
        print!("id = {}", id);

        // call place_pixel
        let NEW_COLOR: u32 = 0xFFFFFF00;

        let allowed_color = get!(world, (id, NEW_COLOR), (AllowedColor));

        print!("\n allowed_color: {} \n", allowed_color.is_allowed);

        let new_params = DefaultParameters{
            for_player: caller,
            for_system: caller,
            position: PixelawPosition {
                x: 1,
                y: 1
            },
            color: NEW_COLOR
        };
        actions_system.interact(new_params);

        let player = get!(
            world,
            (get_tx_info().unbox().account_contract_address),
            (Player)
        );

        assert(player.current_px == 9, 'current px should be 9');

    }
}
