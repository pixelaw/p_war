mod tests {
    // import test utils
    use dojo::utils::test::{spawn_test_world, deploy_contract};
    // import world dispatcher
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    // import test utils
    use p_war::{
        models::{
            game::{Game, game}, board::{Board, GameId, Position, board, game_id}, player::{Player},
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
        class_hash::Felt252TryIntoClassHash, ContractAddress, get_caller_address, get_tx_info,
    };

    const COLOR: u32 = 0xFF0000FF;

    #[test]
    #[available_gas(999_999_999)]
    fn test_create_game() {
        // caller
        let caller = starknet::contract_address_const::<0x0>();
        let (world, _, p_war_actions, _, _, _) = p_war::tests::utils::setup();

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

        // call place_pixel
        let NEW_COLOR: u32 = 0xFFFFFFFF;

        let allowed_color = get!(world, (id, NEW_COLOR), (AllowedColor));

        println!("\n allowed_color: {} \n", allowed_color.is_allowed);

        let new_params = DefaultParameters {
            for_player: caller,
            for_system: caller,
            position: PixelawPosition { x: 1, y: 1 },
            color: NEW_COLOR
        };
        p_war_actions.interact(new_params);

        let player = get!(world, (get_tx_info().unbox().account_contract_address), (Player));

        assert(player.current_px == 9, 'current px should be 9');
    }
}
