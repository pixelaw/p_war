use pixelaw::core::utils::DefaultParameters;
use starknet::ContractAddress;
use p_war::models::board::Position;

const GAME_DURATION: u64 = 111;
const DEFAULT_AREA: u32 = 5;

// define the interface
#[dojo::interface]
trait IActions {
    fn create_game(origin: Position) -> usize;
    fn place_pixel(app: ContractAddress, default_params: DefaultParameters);
    // fn end_game(game_id: usize);
}

// dojo decorator
#[dojo::contract]
mod actions {
    use super::{IActions, GAME_DURATION, DEFAULT_AREA};
    use p_war::models::{game::{Game, Status}, board::{Board, GameId, Position}, allowed_color::AllowedColor, allowed_app::AllowedApp};
    use starknet::{ContractAddress, get_block_timestamp, get_caller_address, get_contract_address};
    use pixelaw::core::actions::{
        IActionsDispatcher as ICoreActionsDispatcher,
        IActionsDispatcherTrait as ICoreActionsDispatcherTrait
    };
    use pixelaw::core::utils::{get_core_actions, DefaultParameters};
    use pixelaw::core::models::pixel::PixelUpdate;
    use p_war::systems::apps::{IAllowedApp, IAllowedAppDispatcher, IAllowedAppDispatcherTrait};

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
    impl AllowedAppImpl of IAllowedApp<ContractState> {
        fn set_pixel(world: IWorldDispatcher, default_params: DefaultParameters) {

        let player = get_caller_address();
        let system = get_contract_address();
        let core_actions = get_core_actions(world);

        core_actions
            .update_pixel(
            player,
            system,
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
                proposals: 0
            };

            let board = Board {
                id,
                origin,
                length: DEFAULT_AREA,
                width: DEFAULT_AREA
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
                                app: Option::None,
                                // owner should be p_war
                                owner: Option::Some(player),
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
            app.set_pixel(default_params);

        }
    }
}