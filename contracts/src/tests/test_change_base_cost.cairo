#[cfg(test)]
mod tests {
    use starknet::{
        class_hash::Felt252TryIntoClassHash,
        ContractAddress,
        get_caller_address,
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
            player::{Player},
            allowed_app::AllowedApp,
            allowed_color::AllowedColor,
        },
        systems::{
            actions::{p_war_actions, IActionsDispatcher, IActionsDispatcherTrait},
            propose::{propose, IProposeDispatcher, IProposeDispatcherTrait},
            voting::{voting, IVotingDispatcher, IVotingDispatcherTrait},
            utils::update_max_px,
        },
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
    fn test_change_base_cost() {
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

        let id = actions_system.get_game_id(Position { x: default_params.position.x, y: default_params.position.y });
        print!("id = {}", id);

        // change paint cost.
        let args = Args{
            address: starknet::contract_address_const::<0x0>(),
            arg1: 3,
            arg2: 0,
        }; 

        let index = propose_system.create_proposal(
            game_id: id,
            proposal_type: ProposalType::ChangePaintCost,
            args: args,
        );


        let vote_px = 1;
        voting_system.vote(id, index, vote_px, true);

        let proposal = get!(world, (id, index), (Proposal));

        print!("\n## PROPOSAL INFO ##\n");
        print!("Proposal end: {}\n", proposal.end);

        // should add cheat code to spend time
        propose_system.activate_proposal(id, index);

        // interact to update user's status
        let another_params = DefaultParameters{
            for_player: caller,
            for_system: caller,
            position: PixelawPosition {
                x: 3,
                y: 3
            },
            color: 0
        };
        actions_system.interact(another_params);

        let player = get!(
            world,
            (caller),
            (Player),
        );

        // print!("\n\ncu_px: {}", player.current_px);
        assert(player.current_px == 5, 'current px should be 5');

    }
}
