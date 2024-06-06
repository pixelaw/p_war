use pixelaw::core::utils::DefaultParameters;
use pixelaw::core::models::pixel::PixelUpdate;
use starknet::ContractAddress;
use p_war::models::board::Position;

const GAME_DURATION: u64 = 111;
const DEFAULT_AREA: u32 = 5;
const DEFAULT_COLOR_0: u32 = 0;
const DEFAULT_RECOVERY_RATE: u64 = 10;
const DEFAULT_COLOR_1: u32 = 0xffffff;
const APP_KEY: felt252 = 'p_war';
const APP_ICON: felt252 = 'U+2694';
/// BASE means using the server's default manifest.json handler
const APP_MANIFEST: felt252 = 'BASE/manifests/p_war';

// define the interface
#[dojo::interface]
trait IActions {
    fn init();
    fn interact(default_params: DefaultParameters);
    fn create_game(origin: Position) -> usize;
    fn get_game_id(position: Position) -> usize;
    fn place_pixel(app: ContractAddress, default_params: DefaultParameters);
    fn update_pixel(pixel_update: PixelUpdate);
    fn end_game(game_id: usize);
}

// dojo decorator
#[dojo::contract]
mod p_war_actions {
    use super::{APP_KEY, APP_ICON, APP_MANIFEST, IActions, IActionsDispatcher, IActionsDispatcherTrait, GAME_DURATION, DEFAULT_AREA};
    use super::{DEFAULT_RECOVERY_RATE, DEFAULT_COLOR_0, DEFAULT_COLOR_1};
    use p_war::models::{
        game::{Game, Status},
        board::{Board, GameId, Position},
        player::{Player},
        proposal::{PixelRecoveryRate},
        allowed_color::AllowedColor,
        allowed_app::AllowedApp
    };
    use starknet::{ContractAddress, get_block_timestamp, get_caller_address, get_contract_address, get_tx_info};
    use pixelaw::core::actions::{
        IActionsDispatcher as ICoreActionsDispatcher,
        IActionsDispatcherTrait as ICoreActionsDispatcherTrait
    };
    use pixelaw::core::utils::{get_core_actions, DefaultParameters};
    use pixelaw::core::models::{ pixel::PixelUpdate, registry::App };
    use pixelaw::core::traits::IInteroperability;
    use p_war::systems::apps::{IAllowedApp, IAllowedAppDispatcher, IAllowedAppDispatcherTrait};
    use p_war::systems::utils::recover_px;

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
            pixel_update: PixelUpdate,
            app_caller: App,
            player_caller: ContractAddress
        ) {
            // do nothing
        }

        fn on_post_update(
            pixel_update: PixelUpdate,
            app_caller: App,
            player_caller: ContractAddress
        ) {
            // do nothing
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

        fn init(world: IWorldDispatcher) {
            let core_actions = get_core_actions(world);
            core_actions.update_app(APP_KEY, APP_ICON, APP_MANIFEST);
        }

        fn interact(default_params: DefaultParameters) {
            let position = Position {
                                x: default_params.position.x,
                                y: default_params.position.y
                            };
            let game_id = self.get_game_id(position);
            if game_id == 0 {
                self.create_game(position);
            } else {
                self.place_pixel(starknet::contract_address_const::<0x0>(), default_params);
            };
        }

        fn get_game_id(world: IWorldDispatcher, position: Position) -> usize {
            let game_id = get!(world, (position.x, position.y), GameId);
            game_id.value
        }

        fn create_game(world: IWorldDispatcher, origin: Position) -> usize {

            // check if a game exists
            let mut id = world.uuid();

            if id == 0 {
                id = world.uuid();
            }

            let start = get_block_timestamp();
            let core_actions = get_core_actions(world);
            let player = get_caller_address();
            let system = get_contract_address();

            let game = Game {
                id,
                start,
                end: start + GAME_DURATION,
                proposal_idx: 0,
                const_val: 10, // Default is 10.
                coeff_own_pixels: 10,
                coeff_commits: 10,
                winner_config: 0,
                winner: starknet::contract_address_const::<0x0>(),
            };

            let board = Board {
                id,
                origin,
                width: DEFAULT_AREA,
                height: DEFAULT_AREA,
            };

            // make sure that game board has been set with game id
            let mut y = origin.y;
            loop {
                if y >= origin.y + DEFAULT_AREA {
                    break;
                };
                let mut x = origin.x;
                loop {
                    if x >= origin.x + DEFAULT_AREA {
                        break;
                    };
                    core_actions
                        .update_pixel(
                            player,
                            system,
                            PixelUpdate {
                                x,
                                y,
                                color: Option::None,
                                timestamp: Option::None,
                                text: Option::None,
                                app: Option::Some(system),
                                owner: Option::None,
                                action: Option::None
                            }
                        );
                    set!(
                        world,
                        (
                            GameId {
                                x,
                                y,
                                value: id
                            }
                        )
                    );
                    x += 1;
                };
                y += 1;
            };


            set!(
                world,
                (
                    game,
                    board
                )
            );

            // add default colors
            set!(
                world,
                (AllowedColor{
                    game_id: id,
                    color: DEFAULT_COLOR_0,
                    is_allowed: true,
                })
            );

            set!(
                world,
                (AllowedColor{
                    game_id: id,
                    color: DEFAULT_COLOR_1,
                    is_allowed: true,
                })
            );

            // set default recovery_rate
            set!(
                world,
                (PixelRecoveryRate{
                    game_id: id,
                    rate: DEFAULT_RECOVERY_RATE,
                })
            );

            id
            // emit event that game has started
        }

        fn place_pixel(world: IWorldDispatcher, app: ContractAddress, default_params: DefaultParameters) {
            let game_id = get!(world, (default_params.position.x, default_params.position.y), GameId);
            assert(game_id.value != 0, 'this game does not exist');

            let allowed_color = get!(world, (game_id.value, default_params.color), (AllowedColor));
            assert(allowed_color.is_allowed, 'color is not allowed');

            let allowed_app = get!(world, (game_id.value, app), (AllowedApp));
            assert(app.is_zero() || allowed_app.is_allowed, 'app is not allowed');

            let contract_address = if app.is_zero() {
                get_contract_address()
            } else {
              app
            };

            let app = IAllowedAppDispatcher { contract_address };

            let player_address = get_tx_info().unbox().account_contract_address;

            // recover px
            recover_px(world, game_id.value, player_address);

            // if this is first time for the caller, let's set initial px.
            let mut player = get!(
                world,
                (player_address),
                (Player)
            );

            // check the current px is not 0
            assert(player.current_px > 0, 'you cannot paint');

            // check the player is banned or not
            assert(player.is_banned == false, 'you are banned');

            app.set_pixel(default_params);

            set!(
                world,
                (Player{
                    address: player.address,
                    max_px: player.max_px,
                    num_owns: player.num_owns + 1,
                    num_commit: player.num_commit + 1,
                    current_px: player.current_px - 1,
                    last_date: get_block_timestamp(),
                    is_banned: false,
                }),
            );

            // TODO: should reduce the num_owns of previous user.
        }

        fn update_pixel(world: IWorldDispatcher, pixel_update: PixelUpdate) {
            assert(get_caller_address() == get_contract_address(), 'invalid caller');

            let player_address = get_tx_info().unbox().account_contract_address;
            let system = get_contract_address();
            let core_actions = get_core_actions(world);

            core_actions
                .update_pixel(
                player_address,
                system,
                pixel_update
            );
        }

        fn end_game(world: IWorldDispatcher, game_id: usize) {
            // check if the time is expired.
            let mut game = get!(
                world,
                (game_id),
                (Game)
            );
            assert(get_block_timestamp() >= game.end, 'game is not ended');

            // TODO: emit the status??

            // TODO: get winner correctly
            // let winCondition = 0; // can we customize by contractaddress? or match&implement each?
            let winner = starknet::contract_address_const::<0x0>(); // set for now.

            game.winner = winner;

            set!(
                world,
                (game)
            );
        }
    }
}