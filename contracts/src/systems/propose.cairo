use p_war::models::{board::Position};

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
mod propose_actions {
    use p_war::constants::{
        PROPOSAL_DURATION, DISASTER_SIZE, PROPOSAL_FACTOR, NEEDED_YES_VOTING_POWER
    };
    use p_war::models::{
        game::{Game, Status, GameTrait}, proposal::{Proposal, PixelRecoveryRate},
        board::{GameId, Board, Position, PWarPixel}, player::{Player}, allowed_app::AllowedApp,
        allowed_color::{AllowedColor, PaletteColors, InPalette, GamePalette}
    };
    use p_war::systems::utils::{check_game_status};
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

    #[derive(Drop, Serde, starknet::Event)]
    pub struct ProposalCreated {
        game_id: usize,
        index: usize,
        proposal_type: u8,
        target_args_1: u32,
        target_args_2: u32
    }

    #[derive(Drop, Serde, starknet::Event)]
    pub struct ProposalActivated {
        game_id: usize,
        index: usize,
        proposal_type: u8,
        target_args_1: u32,
        target_args_2: u32
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        ProposalCreated: ProposalCreated,
        ProposalActivated: ProposalActivated
    }

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

            let mut player = get!(world, (player_address), (Player));

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
                yes_voting_power: 0,
                no_voting_power: 0,
                is_activated: false
            };

            game.proposal_idx += 1;

            set!(world, (proposal, game));

            set!(
                world,
                (Player {
                    address: player.address,
                    num_owns: player.num_owns,
                    last_date: get_block_timestamp(),
                    num_commit: player.num_commit + 1,
                    is_banned: false,
                }),
            );

            emit!(
                world,
                (Event::ProposalCreated(
                    ProposalCreated {
                        game_id,
                        index: game.proposal_idx,
                        proposal_type: proposal.proposal_type,
                        target_args_1,
                        target_args_2
                    }
                ))
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
            assert(
                proposal.yes_voting_power >= NEEDED_YES_VOTING_POWER, 'did not reach minimum yes'
            );
            assert(proposal.yes_voting_power > proposal.no_voting_power, 'yes is not more than no');
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

            emit!(
                world,
                (Event::ProposalActivated(
                    ProposalActivated {
                        game_id,
                        index,
                        proposal_type: proposal.proposal_type,
                        target_args_1: proposal.target_args_1,
                        target_args_2: proposal.target_args_2
                    }
                ))
            );
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
