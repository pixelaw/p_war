use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use p_war::models::board::Position;
use p_war::models::game::Game;
use p_war::systems::guilds::{IGuildDispatcher, IGuildDispatcherTrait};
use pixelaw::core::models::pixel::PixelUpdate;
use pixelaw::core::utils::DefaultParameters;
use starknet::ContractAddress;

// define the interface
#[starknet::interface]
pub trait IActions<T> {
    fn init(ref self: T);
    fn interact(ref self: T, default_params: DefaultParameters);
    fn create_game(ref self: T, origin: Position) -> usize;
    fn create_game_guilds(
        ref self: T, game_id: usize, guild_dispatcher: IGuildDispatcher
    ) -> Array<usize>;
    fn get_game_id(self: @T, position: Position) -> usize;
    fn place_pixel(ref self: T, app: ContractAddress, default_params: DefaultParameters);
    fn update_pixel(ref self: T, pixel_update: PixelUpdate);
    fn end_game(ref self: T, game_id: usize);
}

// dojo decorator
#[dojo::contract(namespace: "pixelaw", nomapping: true)]
mod p_war_actions {
    use dojo::event::EventStorage;
    use dojo::model::{ModelStorage, ModelValueStorage};
    use dojo::world::WorldStorageTrait;
    use dojo::world::{IWorldDispatcherTrait};
    use p_war::constants::{
        APP_KEY, APP_ICON, GAME_ID, OUT_OF_BOUNDS_GAME_ID, DEFAULT_RECOVERY_RATE, INITIAL_COLOR,
        GAME_DURATION, DEFAULT_AREA,
    };
    use p_war::models::{
        game::{Game, Status, GameTrait}, board::{Board, GameId, PWarPixel}, player::{Player},
        proposal::{PixelRecoveryRate},
        allowed_color::{AllowedColor, PaletteColors, InPalette, GamePalette},
        allowed_app::AllowedApp
    };
    use p_war::systems::app::{IAllowedApp, IAllowedAppDispatcher, IAllowedAppDispatcherTrait};
    use p_war::systems::guilds::{IGuildDispatcher, IGuildDispatcherTrait};
    use p_war::systems::utils::{check_game_status};
    use pixelaw::core::actions::{
        IActionsDispatcher as ICoreActionsDispatcher,
        IActionsDispatcherTrait as ICoreActionsDispatcherTrait
    };
    use pixelaw::core::models::{pixel::PixelUpdate, registry::App};
    use pixelaw::core::utils::{
        get_callers, get_core_actions, Direction, Position, DefaultParameters
    };
    use starknet::{
        ContractAddress, get_block_timestamp, get_caller_address, get_contract_address, get_tx_info,
        contract_address_const,
    };
    use super::{IActions, IActionsDispatcher, IActionsDispatcherTrait};

    #[derive(Copy, Drop, Serde)]
    #[dojo::event]
    pub struct StartedGame {
        #[key]
        id: usize,
        timestamp: u128,
        creator: ContractAddress
    }

    #[derive(Copy, Drop, Serde)]
    #[dojo::event]
    pub struct EndedGame {
        #[key]
        id: usize,
        timestamp: u128,
    }

    #[abi(embed_v0)]
    impl ActionsImpl of IActions<ContractState> {
        fn init(ref self: ContractState) {
            let mut world = self.world(@"pixelaw");
            let core_actions = get_core_actions(ref world);
            core_actions.new_app(contract_address_const::<0>(), APP_KEY, APP_ICON);
        }

        fn interact(ref self: ContractState, default_params: DefaultParameters) {
            let position = Position { x: default_params.position.x, y: default_params.position.y };
            println!("position x{}, y{}.", default_params.position.x, default_params.position.y);
            let game_id = self.get_game_id(position);
            println!("game id: {}", game_id);
            if game_id == 0 {
                self.create_game(position);
            } else if game_id == OUT_OF_BOUNDS_GAME_ID {
                // out of bounds
                return;
            } else {
                self.place_pixel(contract_address_const::<0x0>(), default_params);
            };
        }

        fn get_game_id(self: @ContractState, position: Position) -> usize {
            let mut world = self.world(@"pixelaw");

            let mut id = world.dispatcher.uuid();
            if id == 0 {
                return 0;
            }

            // set id as GAME_ID=1
            let board: Board = world.read_model(GAME_ID);

            if position.x < board.origin.x || position.x >= board.origin.x
                + (board.width.try_into().unwrap())
                    || position.y < board.origin.y
                    || position.y >= board.origin.y
                + (board.height.try_into().unwrap()) {
                return OUT_OF_BOUNDS_GAME_ID; // OUT_OF_BOUNDS_GAME_ID for out of bounds
            };
            return 1;
        }

        fn create_game(ref self: ContractState, origin: Position) -> usize {
            let mut world = self.world(@"pixelaw");
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

            let game = Game {
                id,
                start,
                end: start + GAME_DURATION,
                proposal_idx: 0,
                coeff_own_pixels: 0,
                coeff_commits: 0,
                winner_config: 0,
                winner: starknet::contract_address_const::<0x0>(),
                guild_ids: ArrayTrait::new().span(),
                guild_count: 0
            };

            let board = Board { id, origin, width: DEFAULT_AREA, height: DEFAULT_AREA, };

            world.write_model(@board); //not sure
            world.write_model(@game);
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
                let allowed_color = AllowedColor {
                    game_id: id, color: *a.at(color_idx), is_allowed: true
                };
                let palette_colors = PaletteColors {
                    game_id: id, idx: color_idx, color: *a.at(color_idx)
                };
                let in_palette = InPalette { game_id: id, color: *a.at(color_idx), value: true };
                world.write_model(@allowed_color);
                world.write_model(@palette_colors);
                world.write_model(@in_palette);
                color_idx += 1;
            };

            println!("create_game 2");
            // set default recovery_rate
            let pixel_recovery_rate = PixelRecoveryRate {
                game_id: id, rate: DEFAULT_RECOVERY_RATE
            };
            let game_palette = GamePalette { game_id: id, length: 9 };
            world.write_model(@pixel_recovery_rate);
            world.write_model(@game_palette);

            println!("create_game 2.1");

            id
            // emit event that game has started
        }

        // initialize guilds for the game
        fn create_game_guilds(
            ref self: ContractState, game_id: usize, guild_dispatcher: IGuildDispatcher
        ) -> Array<usize> {
            let mut guild_ids = ArrayTrait::new();
            guild_ids.append(guild_dispatcher.create_guild(game_id, 'Fire'));
            guild_ids.append(guild_dispatcher.create_guild(game_id, 'Water'));
            guild_ids.append(guild_dispatcher.create_guild(game_id, 'Earth'));
            guild_ids.append(guild_dispatcher.create_guild(game_id, 'Air'));
            guild_ids
        }

        // To paint, basically use this function.
        fn place_pixel(
            ref self: ContractState, app: ContractAddress, default_params: DefaultParameters
        ) {
            let mut world = self.world(@"pixelaw");
            let core_actions = get_core_actions(ref world); //new
            let system = get_contract_address(); //new
            let position = Position { x: default_params.position.x, y: default_params.position.y };
            let game_id = self.get_game_id(position);
            let player_address = get_caller_address();
            assert(game_id != 0, 'this game does not exist');
            println!("color: {}", default_params.color);

            let allowed_color: AllowedColor = world.read_model((game_id, default_params.color));
            assert(
                allowed_color.is_allowed, 'color is not allowed'
            ); // cannot test correctly without cheatcodes.

            let allowed_app: AllowedApp = world.read_model((game_id, app));
            assert(app.is_zero() || allowed_app.is_allowed, 'app is not allowed');

            // let contract_address = if app.is_zero() {
            //     get_contract_address()
            // } else {
            //     app
            // };

            //let app = IAllowedAppDispatcher { contract_address }; old
            // println!("app: {}", app);
            // recover px
            //recover_px(ref world, game_id, player_address);

            // if this is first time for the caller, let's set initial px.
            let mut player: Player = world.read_model(player_address);

            // get the game info
            let game: Game = world.read_model(game_id);

            // check the player is banned or not
            assert(player.is_banned == false, 'you are banned');

            // check if the game is ongoing
            assert(check_game_status(game.status()), 'game is not ongoing: actions1');

            println!("set_pixel BEGIN");
            core_actions
                .update_pixel( //new
                    player_address,
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
                    },
                    Option::None,
                    false
                );
            println!("set_pixel END");

            player.num_owns += 1;
            player.num_commit += 1;
            println!("player.num_commit: {}", player.num_commit);
            player.last_date = get_block_timestamp();
            world.write_model(@player);

            // get the previous owner of PWarPixel
            let position = Position { x: default_params.position.x, y: default_params.position.y };
            let mut previous_pwarpixel: PWarPixel = world.read_model(position);

            if (previous_pwarpixel.owner != contract_address_const::<0x0>()
                && previous_pwarpixel.owner != player.address) {
                // get the previous player's info
                let mut previous_player: Player = world.read_model(previous_pwarpixel.owner);
                // decrease the previous player's num_owns
                previous_player.num_owns -= 1;
                world.write_model(@previous_player);
            }

            // set the new owner of PWarPixel
            previous_pwarpixel.owner = player.address;
            world.write_model(@previous_pwarpixel);
        }

        // only use for expand areas.
        fn update_pixel(ref self: ContractState, pixel_update: PixelUpdate) {
            let mut world = self.world(@"pixelaw");
            assert(get_caller_address() == get_contract_address(), 'invalid caller');
            let player_address = get_tx_info().unbox().account_contract_address;
            let system = get_contract_address();
            let core_actions = get_core_actions(ref world);

            core_actions.update_pixel(player_address, system, pixel_update, Option::None, false);
        }

        fn end_game(ref self: ContractState, game_id: usize) {
            // check if the time is expired.
            let mut world = self.world(@"pixelaw");
            let mut game: Game = world.read_model(game_id);
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

            world.write_model(@game);
            // TODO: emit the winner!
        }
    }
}
