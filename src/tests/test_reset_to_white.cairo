#[cfg(test)]
mod tests {
    use starknet::{class_hash::Felt252TryIntoClassHash, ContractAddress};
    // import world dispatcher
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    // import test utils
    use dojo::utils::test::{spawn_test_world, deploy_contract};
    // import test utils
    use p_war::{
        models::{
            player::{player},
            game::{Game, game}, board::{Board, GameId, board, game_id, p_war_pixel},
            proposal::{Proposal, pixel_recovery_rate, proposal, player_vote}, 
            allowed_app::{AllowedApp, allowed_app},
            allowed_color::{AllowedColor, allowed_color, palette_colors, in_palette, game_palette}, 
        },
        systems::{
            actions::{p_war_actions, IActionsDispatcher, IActionsDispatcherTrait},
            propose::{propose, IProposeDispatcher, IProposeDispatcherTrait},
            voting::{voting, IVotingDispatcher, IVotingDispatcherTrait}
        }
    };

    use pixelaw::core::{
        models::{
            permissions::{permissions}, 
            pixel::{pixel, Pixel, PixelUpdate}, 
            queue::queue_item,
            registry::{app, app_user, app_name, core_actions_address, instruction}
        },
        actions::{
            actions as core_actions, IActionsDispatcher as ICoreActionsDispatcher,
            IActionsDispatcherTrait as ICoreActionsDispatcherTrait
        },
        utils::{DefaultParameters, Position }
    };

    const COLOR: u32 = 0xFFFFFFFF;

    #[test]
    #[available_gas(999_999_999)]
    fn test_reset_to_white() {
        // caller
        let caller = starknet::contract_address_const::<0x0>();

        // models
        let mut models = array![
            allowed_app::TEST_CLASS_HASH,
            allowed_color::TEST_CLASS_HASH,
            board::TEST_CLASS_HASH,
            game_id::TEST_CLASS_HASH,
            game::TEST_CLASS_HASH,
            game_palette::TEST_CLASS_HASH,
            in_palette::TEST_CLASS_HASH,
            palette_colors::TEST_CLASS_HASH,
            player::TEST_CLASS_HASH,
            player_vote::TEST_CLASS_HASH,
            pixel_recovery_rate::TEST_CLASS_HASH,
            pixel::TEST_CLASS_HASH,
            p_war_pixel::TEST_CLASS_HASH,
            proposal::TEST_CLASS_HASH,
            app::TEST_CLASS_HASH,
            app_name::TEST_CLASS_HASH,
            app_user::TEST_CLASS_HASH,
            core_actions_address::TEST_CLASS_HASH,
            permissions::TEST_CLASS_HASH,
            queue_item::TEST_CLASS_HASH,
            instruction::TEST_CLASS_HASH,
        ];

        // deploy world with models
        let world = spawn_test_world(["pixelaw"].span(), models.into());

        let core_actions_address = world
            .deploy_contract('salt', core_actions::TEST_CLASS_HASH.try_into().unwrap());

        let core_actions = ICoreActionsDispatcher { contract_address: core_actions_address };



        // deploy systems contract
        let p_war_actions_address = world
            .deploy_contract('salty', p_war_actions::TEST_CLASS_HASH.try_into().unwrap());
        let p_war_actions = IActionsDispatcher { contract_address: p_war_actions_address };

        let propose_address = world
            .deploy_contract('salty1', propose::TEST_CLASS_HASH.try_into().unwrap());
        let propose = IProposeDispatcher { contract_address: propose_address };

        let voting_address = world
            .deploy_contract('salty2', voting::TEST_CLASS_HASH.try_into().unwrap());
        let voting = IVotingDispatcher { contract_address: voting_address };



        world.grant_writer(selector_from_tag!("pixelaw-App"), core_actions_address);
        world.grant_writer(selector_from_tag!("pixelaw-AppName"), core_actions_address);
        world.grant_writer(selector_from_tag!("pixelaw-CoreActionsAddress"), core_actions_address);
        world.grant_writer(selector_from_tag!("pixelaw-Pixel"), core_actions_address);

        world.grant_writer(selector_from_tag!("pixelaw-Player"), p_war_actions_address);
        world.grant_writer(selector_from_tag!("pixelaw-Game"), p_war_actions_address);
        world.grant_writer(selector_from_tag!("pixelaw-Board"), p_war_actions_address);
        world.grant_writer(selector_from_tag!("pixelaw-AllowedColor"), p_war_actions_address);
        world.grant_writer(selector_from_tag!("pixelaw-PaletteColors"), p_war_actions_address);
        world.grant_writer(selector_from_tag!("pixelaw-PixelRecoveryRate"), p_war_actions_address);
        world.grant_writer(selector_from_tag!("pixelaw-InPalette"), p_war_actions_address);
        world.grant_writer(selector_from_tag!("pixelaw-GamePalette"), p_war_actions_address);
        world.grant_writer(selector_from_tag!("pixelaw-PWarPixel"), p_war_actions_address);

        world.grant_writer(selector_from_tag!("pixelaw-Player"), propose_address);
        world.grant_writer(selector_from_tag!("pixelaw-Proposal"), propose_address);
        world.grant_writer(selector_from_tag!("pixelaw-AllowedColor"), propose_address);
        world.grant_writer(selector_from_tag!("pixelaw-GamePalette"), propose_address);
        world.grant_writer(selector_from_tag!("pixelaw-InPalette"), propose_address);
        world.grant_writer(selector_from_tag!("pixelaw-PaletteColors"), propose_address);
        world.grant_writer(selector_from_tag!("pixelaw-Game"), propose_address);

        world.grant_writer(selector_from_tag!("pixelaw-Proposal"), voting_address);
        world.grant_writer(selector_from_tag!("pixelaw-Player"), voting_address);
        world.grant_writer(selector_from_tag!("pixelaw-PlayerVote"), voting_address);

        core_actions.init();

        let position = Position{x: 1, y:1};

        let default_params = DefaultParameters {
            for_player: caller,
            for_system: caller,
            position,
            color: COLOR
        };
println!("1");
        // create a game
        p_war_actions.interact(default_params);
        println!("2");
        // paint a color one
        let target_args_1: u32 = 0xFF0000FF;
        let paint_params = DefaultParameters {
            for_player: caller,
            for_system: caller,
            position: Position { x: 1, y: 2 },
            color: target_args_1
        };

        p_war_actions.interact(paint_params);

        let id = p_war_actions
            .get_game_id(Position { x: default_params.position.x, y: default_params.position.y });
        print!("id = {}", id);

        // let args = Args{
        //     address: starknet::contract_address_const::<0x0>(),
        //     arg1: target_args_1.into(),
        //     arg2: 0,
        // };

        let index = propose
            .create_proposal(
                game_id: id, proposal_type: 2, target_args_1: target_args_1, target_args_2: 0
            );

        // let index = propose_system.toggle_allowed_color(id, NEW_COLOR);
        let vote_px = 3;
        voting.vote(id, index, vote_px, true);

        let proposal = get!(world, (id, index), (Proposal));

        print!("\n## PROPOSAL INFO ##\n");

        print!("Proposal end: {}\n", proposal.end);

        // TODO: should add cheat code to spend time
        propose.activate_proposal(id, index, array![default_params.position].into());

        // check if the disaster happens.

        // let board = get!(
        //     world,
        //     (id),
        //     (Board)
        // );

        // DEFAULT_AREA == 5
        // assert(board.width == 5 + add_w.try_into().unwrap(), 'expanded correctly');

        let pixel = get!(world, (1, 2), (Pixel));

        print!("\n $$$$$$COLORRRRR: {} ######\n", pixel.color); // 16711680(#000000FF)

        assert(pixel.color == 0xffffffff, 'shold get the disaster');
    }
}
