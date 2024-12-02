use p_war::models::{
    game::{Game, Status, GameTrait}, proposal::{Proposal, PixelRecoveryRate},
    board::{GameId, Board, Position, PWarPixel}, player::{Player}, allowed_app::AllowedApp,
    allowed_color::{AllowedColor, PaletteColors, InPalette, GamePalette}
};

// define the interface
#[starknet::interface]
pub trait IPropose<T> {
    fn create_proposal(
        ref self: T,
        game_id: usize,
        proposal_type: u8,
        target_args_1: u32,
        target_args_2: u32
    ) -> usize;
    fn activate_proposal(
        ref self: T, game_id: usize, index: usize, clear_data: Span<Position>
    );
    fn add_new_color(ref self: T, game_id: usize, index: usize, game: Game, proposal: Proposal);
    fn reset_to_white(ref self: T, game_id: usize, index: usize, game: Game, proposal: Proposal, clear_data: Span<Position>);
}

// dojo decorator
#[dojo::contract(namespace: "pixelaw", nomapping: true)]
mod propose_actions {
    use p_war::constants::{PROPOSAL_DURATION, NEEDED_YES_PX, DISASTER_SIZE, PROPOSAL_FACTOR};
    use p_war::systems::utils::{recover_px, check_game_status};
    use pixelaw::core::actions::{
        IActionsDispatcher as ICoreActionsDispatcher,
        IActionsDispatcherTrait as ICoreActionsDispatcherTrait
    };
    use pixelaw::core::models::{pixel::PixelUpdate, pixel::Pixel};
    use pixelaw::core::utils::{get_core_actions, DefaultParameters};
    use starknet::{
        ContractAddress, get_block_timestamp, get_caller_address, get_contract_address, get_tx_info
    };
    use super::{IPropose};
    use dojo::model::{ModelStorage, ModelValueStorage};
    use dojo::world::WorldStorageTrait;
    use dojo::event::EventStorage;
    use p_war::models::{
        game::{Game, Status, GameTrait}, proposal::{Proposal, PixelRecoveryRate},
        board::{GameId, Board, Position, PWarPixel}, player::{Player}, allowed_app::AllowedApp,
        allowed_color::{AllowedColor, PaletteColors, InPalette, GamePalette}
    };
    
    #[derive(Copy, Drop, Serde)]
    #[dojo::event]
    pub struct ProposalCreated {
        #[key]
        game_id: usize,
        index: usize,
        proposal_type: u8,
        target_args_1: u32,
        target_args_2: u32
    }
    
    #[derive(Copy, Drop, Serde)]
    #[dojo::event]
    pub struct ProposalActivated {
        #[key]
        game_id: usize,
        index: usize,
        proposal_type: u8,
        target_args_1: u32,
        target_args_2: u32
    }

    #[abi(embed_v0)]
    impl ProposeImpl of IPropose<ContractState> {
        fn create_proposal(
            ref self: ContractState,
            game_id: usize,
            proposal_type: u8,
            target_args_1: u32,
            target_args_2: u32
        ) -> usize {
            //get world
            let mut world = self.world(@"pixelaw");
            // get models
            let mut game: Game = world.read_model(game_id);
            // println!("game status: {}", game.status());
            assert(check_game_status(game.status()), 'game is not ongoing: propose1');
            let player_address = get_tx_info().unbox().account_contract_address;

            // recover px
            recover_px(ref world, game_id, player_address);

            // if this is first time for the caller, let's set initial px.
            let mut player: Player = world.read_model(player_address);

            // check the current px is eq or larger than cost_paint
            assert(player.current_px >= game.base_cost * PROPOSAL_FACTOR, 'not enough PX');

            // check the player is banned or not
            assert(player.is_banned == false, 'you are banned');

            let new_proposal = Proposal {
                game_id: game_id,
                index: game.proposal_idx,
                author: get_caller_address(),
                proposal_type: proposal_type,
                target_args_1: target_args_1,
                target_args_2: target_args_2,
                start: get_block_timestamp(),
                end: get_block_timestamp() + PROPOSAL_DURATION,
                yes_px: 0,
                no_px: 0,
                is_activated: false
            };

            game.proposal_idx += 1;

            world.write_model(@new_proposal);
            world.write_model(@game);

            player.num_commit + (game.base_cost * PROPOSAL_FACTOR);
            player.current_px - (game.base_cost * PROPOSAL_FACTOR);
            world.write_model(@player);

            // consume px
            // set!(
            //     world,
            //     (Player {
            //         address: player.address,
            //         max_px: player.max_px,
            //         num_owns: player.num_owns,
            //         num_commit: player.num_commit + (game.base_cost * PROPOSAL_FACTOR),
            //         current_px: player.current_px - (game.base_cost * PROPOSAL_FACTOR),
            //         last_date: get_block_timestamp(),
            //         is_banned: false,
            //     }),
            // );

            world.emit_event(@ProposalCreated { game_id, index: game.proposal_idx, proposal_type, target_args_1, target_args_2 });
            new_proposal.index
        }

        fn activate_proposal(
            ref self: ContractState, game_id: usize, index: usize, clear_data: Span<Position>
        ) {
            // get the proposal
            let mut world = self.world(@"pixelaw");
            let mut proposal: Proposal = world.read_model((game_id, index));
            let mut game: Game = world.read_model(game_id);
            let current_timestamp = get_block_timestamp();
            assert(current_timestamp >= proposal.end, 'proposal period has not ended');
            assert(proposal.yes_px >= NEEDED_YES_PX, 'did not reach minimum yes_px');
            assert(proposal.yes_px > proposal.no_px, 'yes_px is not more than no_px');
            assert(proposal.is_activated == false, 'this is already activated');
            assert(check_game_status(game.status()), 'game is not ongoing: propose2');
            
            // activate the proposal.
            if proposal.proposal_type == 1 {
                self.add_new_color(game_id, index, game, proposal);
            } else if proposal.proposal_type == 2 {
                self.reset_to_white(game_id, index, game, proposal, clear_data)
            } else if proposal.proposal_type == 3 { // ProposalType::ExtendGameEndTime
                let mut game: Game = world.read_model(game_id);
                game.end += proposal.target_args_1.into();
                world.write_model(@game);
            } else if proposal.proposal_type == 4 { // ProposalType::ExpandArea
                let mut board: Board = world.read_model(game_id);
                board.width += proposal.target_args_1.try_into().unwrap();
                board.height += proposal.target_args_2.try_into().unwrap();
                world.write_model(@board);
            } else {
                return;
            };

            // make it activated.
            proposal.is_activated = true;

            world.write_model(@proposal);
            world.emit_event(@ProposalActivated {game_id, index, proposal_type: proposal.proposal_type, target_args_1: proposal.target_args_1, target_args_2: proposal.target_args_2})
            // // Qustion: should we panish the author if the proposal is denied?
            // // add author's commitment points
            // let mut author = get!(
            //     world,
            //     (proposal.author),
            //     (Player)
            // );

                // author.num_commit += 10; // get 10 commitments if the proposal is accepted
            // set!(
            //     world,
            //     (author)
            // );
        }

        // add new color to the palette, if the color is added, the oldest color become unusable.
        fn add_new_color(
            ref self: ContractState, game_id: usize, index: usize, game: Game, proposal: Proposal
        ) {
            assert(proposal.proposal_type == 1, 'not add new color proposal');
            let mut world = self.world(@"pixelaw");
            let new_color: u32 = proposal.target_args_1;
            let mut new_color_allowed: AllowedColor = world.read_model((game_id, new_color));
            // only change it if it's not allowed
            if !new_color_allowed.is_allowed {
                new_color_allowed.is_allowed = !new_color_allowed.is_allowed;
                world.write_model(@new_color_allowed);

                // check if color already is in the palette
                let mut is_in_palette: InPalette = world.read_model((game_id, new_color));
                // if aready in the palette early return
                if is_in_palette.value {
                    return;
                }

                let mut game_palette: GamePalette = world.read_model(game_id);

                // check if there's less colors in place
                if game_palette.length < 9 {
                    is_in_palette.value = true;
                    world.write_model(@is_in_palette);

                    let mut palette_color: PaletteColors = world.read_model((game_id, game_palette.length));
                    palette_color.color = new_color;
                    world.write_model(@palette_color);

                    game_palette.length += 1;
                    world.write_model(@game_palette);
                } else {
                    // get 0 idx
                    let oldest_color: PaletteColors = world.read_model((game_id, 0));
                    let mut idx = 1;

                    loop {
                        let mut palette_color: PaletteColors = world.read_model((game_id, idx));
                        let prev_color: PaletteColors = world.read_model((game_id, idx));
                        palette_color.idx = idx - 1;
                        palette_color.color = prev_color.color;
                        world.write_model(@palette_color);

                        idx = idx + 1;
                        if idx == 9 {
                            break;
                        };
                    };

                    // Set the new color in the last position
                    let mut last_palette_color: PaletteColors = world.read_model((game_id, 8));
                    last_palette_color.color = new_color;
                    world.write_model(@last_palette_color);

                    let mut old_in_pallet: InPalette = world.read_model((game_id, oldest_color.color));
                    old_in_pallet.value = false;
                    world.write_model(@old_in_pallet);

                    is_in_palette.value = true;
                    world.write_model(@is_in_palette);

                    let mut old_color_allowed: AllowedColor = world.read_model((game_id, oldest_color.color));
                    old_color_allowed.is_allowed = false;
                    world.write_model(@old_color_allowed);


                    //feel like the below is not needed
                    //PaletteColors { game_id, idx: 8, color: new_color }
                };
            };
        }

        fn reset_to_white(
            ref self: ContractState, game_id: usize, index: usize, game: Game, proposal: Proposal, clear_data: Span<Position>
        ) {
            assert(proposal.proposal_type == 2, 'not reset to white proposal');
            let mut world = self.world(@"pixelaw");
            // Reset to white by color
            let core_actions = get_core_actions(ref world); // TODO: should we use p_war_actions insted of core_actions???
            let system = get_caller_address();

            let target_args_1: u32 = proposal.target_args_1;

            let mut idx: usize = 0;

            loop {
                let pixel_to_clear = clear_data.get(idx);

                if let Option::None = pixel_to_clear {
                    break;
                }

                let pixel_to_clear = *clear_data.at(idx);

                let pixel_info: Pixel = world.read_model((pixel_to_clear.x, pixel_to_clear.y));

                if pixel_info.color == target_args_1 {
                    // make it white
                    core_actions
                        .update_pixel(
                            get_caller_address(), // is it okay?
                            system,
                            PixelUpdate {
                                x: pixel_to_clear.x,
                                y: pixel_to_clear.y,
                                color: Option::Some(0xffffffff),
                                timestamp: Option::None,
                                text: Option::None,
                                app: Option::Some(system),
                                owner: Option::None,
                                action: Option::None
                            },
                            Option::None,
                            false
                        );

                    // decrease the previous owner's num_owns
                    let position = Position { x: pixel_to_clear.x, y: pixel_to_clear.y };
                    let previous_pwarpixel: PWarPixel = world.read_model(position);

                    if (previous_pwarpixel.owner != starknet::contract_address_const::<0x0>()) {
                        // get the previous player's info
                        let mut previous_player: Player = world.read_model(previous_pwarpixel.owner);

                        previous_player.num_owns -= 1;
                        world.write_model(@previous_player);
                    };
                };
                idx += 1;
            };
        }
    }
}
