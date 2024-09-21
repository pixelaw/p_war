use p_war::constants::{PROPOSAL_DURATION, NEEDED_YES_PX, DISASTER_SIZE, PROPOSAL_FACTOR};
use p_war::models::{game::{Game, Status}, proposal::{Proposal}, board::Position};
use starknet::{ContractAddress, get_caller_address, get_block_timestamp, contract_address_const};

// define the interface
#[dojo::interface]
trait IPropose {
    fn create_proposal(
        ref world: IWorldDispatcher,
        game_id: usize,
        proposal_type: u8,
        target_args_1: u32,
        target_args_2: u32
    ) -> usize;
    fn activate_proposal(
        ref world: IWorldDispatcher, game_id: usize, index: usize, clear_data: Span<Position>
    );
}

// dojo decorator
#[dojo::contract(namespace: "pixelaw", nomapping: true)]
mod propose {
    use p_war::models::{
        game::{Game, Status, GameTrait}, proposal::{Proposal, PixelRecoveryRate},
        board::{GameId, Board, Position, PWarPixel}, player::{Player}, allowed_app::AllowedApp,
        allowed_color::{AllowedColor, PaletteColors, InPalette, GamePalette}
    };
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
    use super::{IPropose, NEEDED_YES_PX, PROPOSAL_DURATION, DISASTER_SIZE, PROPOSAL_FACTOR};


    #[abi(embed_v0)]
    impl ProposeImpl of IPropose<ContractState> {
        fn create_proposal(
            ref world: IWorldDispatcher,
            game_id: usize,
            proposal_type: u8,
            target_args_1: u32,
            target_args_2: u32
        ) -> usize {
            // get the game
            let mut game = get!(world, game_id, (Game));
            assert(check_game_status(game.status()), 'game is not ongoing');

            let player_address = get_tx_info().unbox().account_contract_address;

            // recover px
            recover_px(world, game_id, player_address);

            // if this is first time for the caller, let's set initial px.
            let mut player = get!(world, (player_address), (Player));

            // check the current px is eq or larger than cost_paint
            assert(player.current_px >= game.base_cost * PROPOSAL_FACTOR, 'not enough PX');

            // check the player is banned or not
            assert(player.is_banned == false, 'you are banned');

            let proposal = Proposal {
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

            set!(world, (proposal, game));

            // consume px
            set!(
                world,
                (Player {
                    address: player.address,
                    max_px: player.max_px,
                    num_owns: player.num_owns,
                    num_commit: player.num_commit + (game.base_cost * PROPOSAL_FACTOR),
                    current_px: player.current_px - (game.base_cost * PROPOSAL_FACTOR),
                    last_date: get_block_timestamp(),
                    is_banned: false,
                }),
            );

            proposal.index
        }


        fn activate_proposal(
            ref world: IWorldDispatcher, game_id: usize, index: usize, clear_data: Span<Position>
        ) {
            // get the proposal
            let mut proposal = get!(world, (game_id, index), (Proposal));
            let game = get!(world, (game_id), (Game));
            let current_timestamp = get_block_timestamp();
            assert(current_timestamp >= proposal.end, 'proposal period has not ended');
            assert(proposal.yes_px >= NEEDED_YES_PX, 'did not reach minimum yes_px');
            assert(proposal.yes_px > proposal.no_px, 'yes_px is not more than no_px');
            assert(proposal.is_activated == false, 'this is already activated');
            assert(check_game_status(game.status()), 'game is not ongoing');

            // activate the proposal.
            if proposal.proposal_type == 1 {
                // AddNewColor
                // new feature: if the color is added, the oldest color become unusable.

                let new_color: u32 = proposal.target_args_1;
                let mut new_color_allowed = get!(world, (game_id, new_color), (AllowedColor));

                // only change it if it's not allowed
                if !new_color_allowed.is_allowed {
                    new_color_allowed.is_allowed = !new_color_allowed.is_allowed;

                    set!(world, (new_color_allowed));

                    // check if color already is in the palette
                    let is_in_palette = get!(world, (game_id, new_color), (InPalette));

                    // if aready in the palette early return
                    if is_in_palette.value {
                        return;
                    }

                    let mut game_palette = get!(world, (game_id), (GamePalette));

                    // check if there's less colors in place
                    if game_palette.length < 9 {
                        set!(
                            world,
                            (
                                PaletteColors {
                                    game_id, idx: game_palette.length, color: new_color
                                },
                                InPalette { game_id, color: new_color, value: true },
                                GamePalette { game_id, length: game_palette.length + 1 }
                            )
                        );
                    } else {
                        // get 0 idx
                        let oldest_color = get!(world, (game_id, 0), (PaletteColors));

                        let mut idx = 1;

                        loop {
                            let palette_color = get!(world, (game_id, idx), (PaletteColors));

                            set!(
                                world,
                                (PaletteColors {
                                    game_id, idx: idx - 1, color: palette_color.color
                                })
                            );

                            idx = idx + 1;

                            if idx == 9 {
                                break;
                            };
                        };

                        set!(
                            world,
                            (
                                InPalette { game_id, color: oldest_color.color, value: false },
                                InPalette { game_id, color: new_color, value: true },
                                PaletteColors { game_id, idx: 8, color: new_color },
                                // make it unusable
                                AllowedColor {
                                    game_id, color: oldest_color.color, is_allowed: false
                                },
                            )
                        );
                    };
                };
            } else if proposal.proposal_type == 2 {
                // Reset to white by color
                let core_actions = get_core_actions(
                    world
                ); // TODO: should we use p_war_actions insted of core_actions???
                let system = get_caller_address();

                let target_args_1: u32 = proposal.target_args_1;

                let mut idx: usize = 0;

                loop {
                    let pixel_to_clear = clear_data.get(idx);

                    if let Option::None = pixel_to_clear {
                        break;
                    }

                    let pixel_to_clear = *clear_data.at(idx);

                    let pixel_info = get!(world, (pixel_to_clear.x, pixel_to_clear.y), (Pixel));

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
                                }
                            );

                        // decrease the previous owner's num_owns
                        let position = Position { x: pixel_to_clear.x, y: pixel_to_clear.y };
                        let previous_pwarpixel = get!(world, (position), (PWarPixel));

                        if (previous_pwarpixel.owner != starknet::contract_address_const::<0x0>()) {
                            // get the previous player's info
                            let mut previous_player = get!(
                                world, (previous_pwarpixel.owner), (Player)
                            );

                            previous_player.num_owns -= 1;
                            set!(world, (previous_player));
                        };
                    };
                    idx += 1;
                };
            } else if proposal.proposal_type == 3 { // ProposalType::ExtendGameEndTime
                let mut game = get!(world, (game_id), (Game));
                // let mut board = get!(
                //     world,
                //     (game_id),
                //     (Board)
                // );

                game.end += proposal.target_args_1.into();

                set!(world, (game,));
            } else if proposal.proposal_type == 4 { // ProposalType::ExpandArea
                let mut board = get!(world, (game_id), (Board));
                board.width += proposal.target_args_1.try_into().unwrap();
                board.height += proposal.target_args_2.try_into().unwrap();
                set!(world, (board,));
            } else {
                return;
            };

            // make it activated.
            proposal.is_activated = true;

            set!(world, (proposal));
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
    }
}
