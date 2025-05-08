use pwar::models::{
    game::{Game}, 
    proposal::Proposal,
};

use pixelaw::core::utils::Position;

// define the interface
#[starknet::interface]
pub trait IPropose<T> {
    fn create_proposal(
        ref self: T, game_id: u32, proposal_type: u8, target_args_1: u32, target_args_2: u32
    ) -> u32;
    fn activate_proposal(ref self: T, game_id: u32, index: u32, clear_data: Span<Position>);
    fn add_new_color(ref self: T, game_id: u32, index: u32, game: Game, proposal: Proposal);
    fn reset_to_white(
        ref self: T,
        game_id: u32,
        index: u32,
        game: Game,
        proposal: Proposal,
        clear_data: Span<Position>
    );
}

// dojo decorator
#[dojo::contract]
pub mod propose_actions {
    use dojo::event::EventStorage;
    use dojo::model::ModelStorage;
    use pwar::constants::{
        PROPOSAL_DURATION, NEEDED_YES_VOTING_POWER
    };
    use pwar::models::{
        game::{Game, GameTrait}, 
        proposal::Proposal,
        board::{Board, PWarPixel},
        allowed_color::{AllowedColor, PaletteColors, GamePalette, InPalette},
        player::Player
    };
    use pwar::systems::utils::check_game_status;
    use pixelaw::core::actions::{
        IActionsDispatcherTrait as ICoreActionsDispatcherTrait
    };
    use pixelaw::core::models::{pixel::PixelUpdate, pixel::Pixel};
    use pixelaw::core::utils::{get_core_actions, Position, get_callers};
    use starknet::{
        get_caller_address, 
        get_tx_info,
        get_block_timestamp
    };
    use super::IPropose;

    #[derive(Copy, Drop, Serde)]
    #[dojo::event]
    pub struct ProposalCreated {
        #[key]
        game_id: u32,
        index: u32,
        proposal_type: u8,
        target_args_1: u32,
        target_args_2: u32
    }

    #[derive(Copy, Drop, Serde)]
    #[dojo::event]
    pub struct ProposalActivated {
        #[key]
        game_id: u32,
        index: u32,
        proposal_type: u8,
        target_args_1: u32,
        target_args_2: u32
    }

    #[abi(embed_v0)]
    impl ProposeImpl of IPropose<ContractState> {
        fn create_proposal(
            ref self: ContractState,
            game_id: u32,
            proposal_type: u8,
            target_args_1: u32,
            target_args_2: u32
        ) -> u32 {
            //get world
            let mut world = self.world(@"pwar");
            // get models
            let mut game: Game = world.read_model(game_id);
            // println!("game status: {}", game.status());
            assert(check_game_status(game.status()), 'game is not ongoing: propose1');
            let player_address = get_tx_info().unbox().account_contract_address;

            // if this is first time for the caller, let's set initial px.
            let mut player: Player = world.read_model(player_address);

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
                yes_voting_power: 0,
                no_voting_power: 0,
                is_activated: false
            };

            game.proposal_idx += 1;

            world.write_model(@new_proposal);
            world.write_model(@game);

            player.num_commit = player.num_commit + 1;
            world.write_model(@player);

            world
                .emit_event(
                    @ProposalCreated {
                        game_id,
                        index: game.proposal_idx,
                        proposal_type,
                        target_args_1,
                        target_args_2
                    }
                );
            new_proposal.index
        }

        fn activate_proposal(
            ref self: ContractState, game_id: u32, index: u32, clear_data: Span<Position>
        ) {
            // get the proposal
            let mut world = self.world(@"pwar");
            let mut proposal: Proposal = world.read_model((game_id, index));
            let mut game: Game = world.read_model(game_id);
            let current_timestamp = get_block_timestamp();
            assert(current_timestamp >= proposal.end, 'proposal period has not ended');
            assert(
                proposal.yes_voting_power >= NEEDED_YES_VOTING_POWER, 'did not reach minimum yes'
            );
            assert(proposal.yes_voting_power > proposal.no_voting_power, 'yes is not more than no');
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
            world
                .emit_event(
                    @ProposalActivated {
                        game_id,
                        index,
                        proposal_type: proposal.proposal_type,
                        target_args_1: proposal.target_args_1,
                        target_args_2: proposal.target_args_2
                    }
                )
        }

        // add new color to the palette, if the color is added, the oldest color become unusable.
        fn add_new_color(
            ref self: ContractState, game_id: u32, index: u32, game: Game, proposal: Proposal
        ) {
            assert(proposal.proposal_type == 1, 'not add new color proposal');
            let mut world = self.world(@"pwar");
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

                    let mut palette_color: PaletteColors = world
                        .read_model((game_id, game_palette.length));
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

                    let mut old_in_pallet: InPalette = world
                        .read_model((game_id, oldest_color.color));
                    old_in_pallet.value = false;
                    world.write_model(@old_in_pallet);

                    is_in_palette.value = true;
                    world.write_model(@is_in_palette);

                    let mut old_color_allowed: AllowedColor = world
                        .read_model((game_id, oldest_color.color));
                    old_color_allowed.is_allowed = false;
                    world.write_model(@old_color_allowed);
                };
            };
        }

        fn reset_to_white(
            ref self: ContractState,
            game_id: u32,
            index: u32,
            game: Game,
            proposal: Proposal,
            clear_data: Span<Position>
        ) {
            assert(proposal.proposal_type == 2, 'not reset to white proposal');
            let mut core_world = self.world(@"pixelaw");
            let mut app_world = self.world(@"myapp");
            let mut world = self.world(@"pwar");
            // Reset to white by color
            let core_actions = get_core_actions(
                ref world
            ); // TODO: should we use pwar_actions insted of core_actions???
            let system = get_caller_address();

            let target_args_1: u32 = proposal.target_args_1;

            let mut idx: u32 = 0;

            loop {
                let pixel_to_clear = clear_data.get(idx);

                if let Option::None = pixel_to_clear {
                    break;
                }

                let pixel_to_clear = *clear_data.at(idx);
                let pixel_info: Pixel = core_world.read_model((pixel_to_clear.x, pixel_to_clear.y));
                let position = Position { x: pixel_to_clear.x, y: pixel_to_clear.y };

                if pixel_info.color == target_args_1 {
                    core_actions
                        .update_pixel(
                            get_caller_address(),
                            system,
                            PixelUpdate {
                                position,
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
                    let previous_pwarpixel: PWarPixel = app_world.read_model(position);

                    if (previous_pwarpixel.owner != starknet::contract_address_const::<0x0>()) {
                        // get the previous player's info
                        let mut previous_player: Player = app_world
                            .read_model(previous_pwarpixel.owner);

                        previous_player.num_owns -= 1;
                        app_world.write_model(@previous_player);
                    };
                };
                idx += 1;
            };
        }
    }
}
