#[cfg(test)]
mod tests {
    use starknet::{
        class_hash::Felt252TryIntoClassHash,
        ContractAddress
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
            proposal::{Args, ProposalType, Proposal},
            allowed_app::AllowedApp,
            allowed_color::AllowedColor,
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

    const COLOR: u32 = 123456;

    #[test]
    #[available_gas(999_999_999)]
    fn test_make_a_disaster_by_color() {
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

        let propose_contract_address = world
            .deploy_contract('salty1', propose::TEST_CLASS_HASH.try_into().unwrap());
        let propose_system = IProposeDispatcher { contract_address: propose_contract_address };

        let voting_contract_address = world
            .deploy_contract('salty2', voting::TEST_CLASS_HASH.try_into().unwrap());
        let voting_system = IVotingDispatcher { contract_address: voting_contract_address };

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

        // paint a color one
        let target_color: u32 = 0xff0000;
        let paint_params = DefaultParameters{
            for_player: caller,
            for_system: caller,
            position: PixelawPosition {
                x: 1,
                y: 2
            },
            color: target_color
        };
        

        actions_system.interact(paint_params);

        let id = actions_system.get_game_id(Position { x: default_params.position.x, y: default_params.position.y });
        print!("id = {}", id);
        

        let args = Args{
            address: starknet::contract_address_const::<0x0>(),
            arg1: target_color.into(),
            arg2: 0,
        }; 

        let index = propose_system.create_proposal(
            game_id: id,
            proposal_type: ProposalType::MakeADisasterByCoordinates,
            args: args,
        );


        // let index = propose_system.toggle_allowed_color(id, NEW_COLOR);
        let vote_px = 3;
        voting_system.vote(id, index, vote_px, true);

        let proposal = get!(world, (id, index), (Proposal));

        print!("\n## PROPOSAL INFO ##\n");
        
        print!("Proposal end: {}\n", proposal.end);

        // TODO: should add cheat code to spend time
        propose_system.activate_proposal(id, index);


        // check if the disaster happens.
        // let board = get!(
        //     world,
        //     (id),
        //     (Board)
        // );
        
        // DEFAULT_AREA == 5
        // assert(board.width == 5 + add_w.try_into().unwrap(), 'expanded correctly');

        let pixel = get!(
            world,
            (1, 2),
            (Pixel)
        );

        print!("\n $$$$$$COLORRRRR: {} ######\n", pixel.color);

        assert(pixel.color == 0xffffff, 'got the disaster');
    }
}
