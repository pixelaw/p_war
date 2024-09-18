mod tests {
    use starknet::{
        class_hash::Felt252TryIntoClassHash, ContractAddress, testing::{set_block_timestamp},
    };
    // import world dispatcher
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    // import test utils
    use dojo::utils::test::{spawn_test_world, deploy_contract};
    // import test utils
    use p_war::{
        models::{
            game::{Game, game}, board::{Board, GameId, Position, board, game_id},
            proposal::{Proposal}, allowed_app::AllowedApp,
            allowed_color::{AllowedColor, PaletteColors},
        },
        systems::{
            actions::{p_war_actions, IActionsDispatcher, IActionsDispatcherTrait},
            propose::{propose, IProposeDispatcher, IProposeDispatcherTrait},
            voting::{voting, IVotingDispatcher, IVotingDispatcherTrait}
        }
    };

    use p_war::constants::{GAME_DURATION};

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

    const COLOR: u32 = 0xAAAAAAFF;

    #[test]
    #[available_gas(999_999_999)]
    fn test_extend_game_end() {
        // caller
        let caller = starknet::contract_address_const::<0x0>();

        let (world, _, p_war_actions, propose_system, voting_system) = p_war::tests::utils::setup();

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

        let index = propose_system
            .create_proposal(
                game_id: id,
                proposal_type: 3,
                target_args_1: 60 * 60, // extend the game for 1 hour
                target_args_2: 0,
            );

        // let index = propose_system.toggle_allowed_color(id, NEW_COLOR);
        let vote_px = 3;
        voting_system.vote(id, index, vote_px, true);

        let proposal = get!(world, (id, index), (Proposal));

        println!("\n## PROPOSAL INFO ##\n");
        println!("Proposal end: {}\n", proposal.end);

        // should add cheat code to spend time
        set_block_timestamp(proposal.end + 1); // NOTE: we need to set block timestamp forcely
        propose_system.activate_proposal(id, index, array![default_params.position].into());

        // // call place_pixel
        // let new_params = DefaultParameters{
        //     for_player: caller,
        //     for_system: caller,
        //     position: PixelawPosition {
        //         x: 1,
        //         y: 1
        //     },
        //     color: 0xFFFFFFFF
        // };

        // p_war_actions.interact(new_params);

        let game = get!(world, (id), (Game));

        assert(game.end > GAME_DURATION + 60 * 60 - 1, 'game end extended');
    }
}
