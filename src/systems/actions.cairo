use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

use p_war::constants::{
    GAME_DURATION, DEFAULT_AREA, DEFAULT_RECOVERY_RATE, APP_KEY, APP_ICON, APP_MANIFEST,
    INITIAL_COLOR, BASE_COST, DEFAULT_PX
};
use p_war::models::board::Position;
use pixelaw::core::models::pixel::PixelUpdate;
use pixelaw::core::utils::DefaultParameters;
use starknet::ContractAddress;

// define the interface
#[dojo::interface]
trait IActions {
    fn init(ref world: IWorldDispatcher);
    fn interact(ref world: IWorldDispatcher, default_params: DefaultParameters);
    fn create_game(ref world: IWorldDispatcher, origin: Position) -> usize;
    fn get_game_id(ref world: IWorldDispatcher, position: Position) -> usize;
    fn place_pixel(
        ref world: IWorldDispatcher, app: ContractAddress, default_params: DefaultParameters
    );
    fn update_pixel(ref world: IWorldDispatcher, pixel_update: PixelUpdate);
    fn end_game(ref world: IWorldDispatcher, game_id: usize);
}

// dojo decorator
#[dojo::contract(namespace: "pixelaw", nomapping: true)]
mod p_war_actions {
    use p_war::constants::{GAME_ID, OUT_OF_BOUNDS_GAME_ID};
    use p_war::models::{
        game::{Game, Status, GameTrait}, board::{Board, GameId, PWarPixel}, player::{Player},
        proposal::{PixelRecoveryRate},
        allowed_color::{AllowedColor, PaletteColors, InPalette, GamePalette},
        allowed_app::AllowedApp
    };
    use p_war::systems::apps::{IAllowedApp, IAllowedAppDispatcher, IAllowedAppDispatcherTrait};
    use p_war::systems::utils::{recover_px, update_max_px, check_game_status};
    use pixelaw::core::actions::{
        IActionsDispatcher as ICoreActionsDispatcher,
        IActionsDispatcherTrait as ICoreActionsDispatcherTrait
    };
    use pixelaw::core::models::{pixel::PixelUpdate, registry::App};
    use pixelaw::core::traits::IInteroperability;
    use pixelaw::core::utils::{get_core_actions, DefaultParameters, Position};
    use starknet::{
        ContractAddress, get_block_timestamp, get_caller_address, get_contract_address, get_tx_info,
        contract_address_const,
    };
    use super::{
        APP_KEY, APP_ICON, APP_MANIFEST, IActions, IActionsDispatcher, IActionsDispatcherTrait,
        GAME_DURATION, DEFAULT_AREA, BASE_COST, DEFAULT_PX
    };
    use super::{DEFAULT_RECOVERY_RATE, INITIAL_COLOR};

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        StartedGame: StartedGame,
        EndedGame: EndedGame
    }

    #[derive(Drop, Serde, starknet::Event)]
    struct StartedGame {
        id: usize,
        timestamp: u128,
        creator: ContractAddress
    }

    #[derive(Drop, Serde, starknet::Event)]
    struct EndedGame {
        id: usize,
        timestamp: u128,
        // should we emit here the states of the pixel as well?
    }

    #[abi(embed_v0)]
    impl ActionsInteroperability of IInteroperability<ContractState> {
        fn on_pre_update(
            ref world: IWorldDispatcher,
            pixel_update: PixelUpdate,
            app_caller: App,
            player_caller: ContractAddress
        ) {
            // do nothing
            let _world = world;
        }

        fn on_post_update(
            ref world: IWorldDispatcher,
            pixel_update: PixelUpdate,
            app_caller: App,
            player_caller: ContractAddress
        ) {
            // do nothing
            let _world = world;
        }
    }

    #[abi(embed_v0)]
    impl AllowedAppImpl of IAllowedApp<ContractState> {
        fn set_pixel(default_params: DefaultParameters) {
            let actions = IActionsDispatcher { contract_address: get_contract_address() };
            actions
                .update_pixel(
                    PixelUpdate {
                        x: default_params.position.x,
                        y: default_params.position.y,
                        color: Option::Some(default_params.color),
                        timestamp: Option::None,
                        text: Option::None,
                        app: Option::None,
                        owner: Option::None,
                        action: Option::None
                    }
                );
        }
    }

    #[abi(embed_v0)]
    impl ActionsImpl of IActions<ContractState> {
        fn init(ref world: IWorldDispatcher) {
            let core_actions = get_core_actions(world);
            core_actions.new_app(contract_address_const::<0>(), APP_KEY, APP_ICON);
        }

        fn interact(ref world: IWorldDispatcher, default_params: DefaultParameters) {
            let position = Position { x: default_params.position.x, y: default_params.position.y };
            let game_id = self.get_game_id(position);
            if game_id == 0 {
                self.create_game(position);
            } else if game_id == OUT_OF_BOUNDS_GAME_ID {
                // out of bounds
                return;
            } else {
                self.place_pixel(contract_address_const::<0x0>(), default_params);
            };
        }

        fn get_game_id(ref world: IWorldDispatcher, position: Position) -> usize {
            let mut id = world.uuid();
            if id == 0 {
                return 0;
            };

            // set id as GAME_ID=1
            let board = get!(world, (GAME_ID), (Board));

            if position.x < board.origin.x || position.x >= board.origin.x
                + board.width || position.y < board.origin.y || position.y >= board.origin.y
                + board.height {
                return OUT_OF_BOUNDS_GAME_ID; // OUT_OF_BOUNDS_GAME_ID for out of bounds
            };
            return 1;
        }

        fn create_game(ref world: IWorldDispatcher, origin: Position) -> usize {
            println!("create_game BEGIN");

            // check if a game exists
            // let mut tmp_uuid = world.uuid();
            // if tmp_uuid != 0 {
            //     return 0;
            // };

            // if id == 0 {
            //     id = world.uuid();
            // }
            let mut id = GAME_ID; // set as a constant for now.

            let start = get_block_timestamp();
            // let core_actions = get_core_actions(world);
            let player = get_caller_address();
            // let system = get_contract_address();

            let game = Game {
                id,
                start,
                end: start + GAME_DURATION,
                proposal_idx: 0,
                base_cost: BASE_COST,
                const_val: DEFAULT_PX, // Default is 10.
                coeff_own_pixels: 0,
                coeff_commits: 0,
                winner_config: 0,
                winner: starknet::contract_address_const::<0x0>(),
                guild_ids: ArrayTrait::new().span(),
                guild_count: 0
            };

            let board = Board { id, origin, width: DEFAULT_AREA, height: DEFAULT_AREA, };

            // To make a bigger area, we deleted this part.
            // // make sure that game board has been set with game id
            // let mut y = origin.y;
            // loop {
            //     if y >= origin.y + DEFAULT_AREA {
            //         break;
            //     };
            //     let mut x = origin.x;
            //     loop {
            //         if x >= origin.x + DEFAULT_AREA {
            //             break;
            //         };
            //         core_actions
            //             .update_pixel(
            //                 player,
            //                 system,
            //                 PixelUpdate {
            //                     x,
            //                     y,
            //                     color: Option::Some(INITIAL_COLOR),
            //                     timestamp: Option::None,
            //                     text: Option::None,
            //                     app: Option::Some(system),
            //                     owner: Option::None,
            //                     action: Option::None
            //                 }
            //             );
            //         set!(
            //             world,
            //             (
            //                 GameId {
            //                     x,
            //                     y,
            //                     value: id
            //                 }
            //             )
            //         );
            //         x += 1;
            //     };
            //     y += 1;
            // };

            set!(world, (game, board));
            println!("create_game 1");
            // add default colors (changed these to RGBA)
            let mut color_idx = 0;
            let mut a = ArrayTrait::new();
            a.append(0x000000ff);
            a.append(0xffffffff);
            a.append(0x9400d3ff);
            a.append(0x4b0082ff);
            a.append(0x0000ffff);
            a.append(0x00ff00ff);
            a.append(0xffff00ff);
            a.append(0xff7f00ff);
            a.append(0xff0000ff);

            loop {
                if color_idx > 8 {
                    break;
                };
                set!(
                    world,
                    (
                        AllowedColor { game_id: id, color: *a.at(color_idx), is_allowed: true, },
                        PaletteColors { game_id: id, idx: color_idx, color: *a.at(color_idx), },
                        InPalette { game_id: id, color: *a.at(color_idx), value: true }
                    )
                );
                color_idx += 1;
            };

            println!("create_game 2");
            // set default recovery_rate
            set!(
                world,
                (
                    PixelRecoveryRate { game_id: id, rate: DEFAULT_RECOVERY_RATE, },
                    GamePalette { game_id: id, length: 9 }
                )
            );

            println!("create_game 2.1");
            // recover px
            recover_px(world, id, player);

            id
            // emit event that game has started
        }

        // To paint, basically use this function.
        fn place_pixel(
            ref world: IWorldDispatcher, app: ContractAddress, default_params: DefaultParameters
        ) {
            let position = Position { x: default_params.position.x, y: default_params.position.y };

            // let game_id = get!(world, (default_params.position.x, default_params.position.y),
            // GameId);
            let game_id = self.get_game_id(position);
            assert(game_id != 0, 'this game does not exist');

            let allowed_color = get!(world, (game_id, default_params.color), (AllowedColor));
            assert(
                allowed_color.is_allowed, 'color is not allowed'
            ); // cannot test correctly without cheatcodes.

            let allowed_app = get!(world, (game_id, app), (AllowedApp));
            assert(app.is_zero() || allowed_app.is_allowed, 'app is not allowed');

            let contract_address = if app.is_zero() {
                get_contract_address()
            } else {
                app
            };

            let app = IAllowedAppDispatcher { contract_address };

            let player_address = get_tx_info().unbox().account_contract_address;

            // recover px
            recover_px(world, game_id, player_address);

            // if this is first time for the caller, let's set initial px.
            let mut player = get!(world, (player_address), (Player));

            // get the game info
            let game = get!(world, (game_id), (Game));

            // check the current px is eq or larger than cost_paint
            assert(player.current_px >= game.base_cost, 'not enough PX');

            // check the player is banned or not
            assert(player.is_banned == false, 'you are banned');

            // check if the game is ongoing
            assert(check_game_status(game.status()), 'game is not ongoing');

            app.set_pixel(default_params);

            set!(
                world,
                (Player {
                    address: player.address,
                    max_px: player.max_px,
                    num_owns: player.num_owns + 1,
                    num_commit: player.num_commit + game.base_cost,
                    current_px: player.current_px - game.base_cost,
                    last_date: get_block_timestamp(),
                    is_banned: false,
                }),
            );

            // get the previous owner of PWarPixel
            let position = Position { x: default_params.position.x, y: default_params.position.y };
            let previous_pwarpixel = get!(world, (position), (PWarPixel));

            if (previous_pwarpixel.owner != contract_address_const::<0x0>()
                && previous_pwarpixel.owner != player.address) {
                // get the previous player's info
                let mut previous_player = get!(world, (previous_pwarpixel.owner), (Player));

                // decrease the previous player's num_owns
                previous_player.num_owns -= 1;
                set!(world, (previous_player));
            }

            // set the new owner of PWarPixel
            set!(world, (PWarPixel { position: position, owner: player.address }),);

            update_max_px(world, game_id, player.address);
        }

        // only use for expand areas.
        fn update_pixel(ref world: IWorldDispatcher, pixel_update: PixelUpdate) {
            assert(get_caller_address() == get_contract_address(), 'invalid caller');

            let player_address = get_tx_info().unbox().account_contract_address;
            let system = get_contract_address();
            let core_actions = get_core_actions(world);

            core_actions.update_pixel(player_address, system, pixel_update);
        }

        fn end_game(ref world: IWorldDispatcher, game_id: usize) {
            // check if the time is expired.
            let mut game = get!(world, (game_id), (Game));
            assert(get_block_timestamp() >= game.end, 'game is not ended');

            // TODO: emit the status??

            // TODO: get winner correctly
            // let winCondition = 0; // can we customize by contractaddress? or match&implement
            // each?
            let winner = match game.winner_config {
                0 => {
                    // set the person with the most pixels at the end as the winner.
                    // TODO: get such a person. (We need to set  player.num_owns correctly.)
                    contract_address_const::<0x0>()
                },
                1 => {
                    // set the winner by the proposal directly.
                    // already set the winner.
                    game.winner
                },
                2 => {
                    // winner is the person who has committied at the most.
                    // TODO: get such a person.
                    contract_address_const::<0x2>()
                },
                _ => { contract_address_const::<0x99>() },
            };

            game.winner = winner;

            set!(world, (game));
            // TODO: emit the winner!
        }
    }
}
