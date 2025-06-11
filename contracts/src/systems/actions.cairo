use pixelaw::core::utils::{DefaultParameters, Position};
use pwar::models::game::Game;
use pwar::systems::guilds::{IGuildDispatcher};
use starknet::{ContractAddress};

// define the interface
#[starknet::interface]
pub trait IActions<T> {
    fn interact(ref self: T, default_params: DefaultParameters);
    fn create_game(ref self: T, origin: Position) -> u32;
    fn create_game_guilds(
        ref self: T, game_id: u32, guild_dispatcher: IGuildDispatcher,
    ) -> Array<u32>;
    fn get_game_id(self: @T, position: Position) -> u32;
    fn get_game(self: @T, id: u32) -> Game;
    fn place_pixel(ref self: T, app: ContractAddress, default_params: DefaultParameters);
    fn end_game(ref self: T, game_id: u32);
}

// dojo decorator
#[dojo::contract]
pub mod pwar_actions {
    use dojo::model::{ModelStorage};
    use dojo::world::{IWorldDispatcherTrait};
    use pixelaw::core::actions::{IActionsDispatcherTrait as ICoreActionsDispatcherTrait};
    use pixelaw::core::models::pixel::{PixelUpdate, PixelUpdateResultTraitImpl};
    use pixelaw::core::utils::{DefaultParameters, Position, get_callers, get_core_actions};
    use pwar::constants::{
        APP_ICON, APP_KEY, DEFAULT_AREA, DEFAULT_RECOVERY_RATE, GAME_DURATION, GAME_ID,
        OUT_OF_BOUNDS_GAME_ID,
    };
    use pwar::models::{
        allowed_color::{AllowedColor, GamePalette, InPalette, PaletteColors},
        board::{Board, PWarPixel}, game::{Game, GameTrait}, player::{Player},
        proposal::{PixelRecoveryRate},
    };
    use pwar::systems::guilds::{IGuildDispatcher, IGuildDispatcherTrait};
    use pwar::systems::utils::{check_game_status};
    use starknet::{ContractAddress, contract_address_const, get_block_timestamp};
    use super::{IActions};

    #[derive(Copy, Drop, Serde)]
    #[dojo::event]
    pub struct StartedGame {
        #[key]
        id: u32,
        timestamp: u128,
        creator: ContractAddress,
    }

    #[derive(Copy, Drop, Serde)]
    #[dojo::event]
    pub struct EndedGame {
        #[key]
        id: u32,
        timestamp: u128,
    }

    fn dojo_init(ref self: ContractState) {
        let mut core_world = self.world(@"pixelaw");
        let core_actions = pixelaw::core::utils::get_core_actions(ref core_world);
        core_actions.new_app(contract_address_const::<0>(), APP_KEY, APP_ICON);
    }

    #[abi(embed_v0)]
    impl ActionsImpl of IActions<ContractState> {
        fn interact(ref self: ContractState, default_params: DefaultParameters) {
            let position = default_params.position;
            println!("position x{}, y{}.", position.x, position.y);
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

        fn get_game_id(self: @ContractState, position: Position) -> u32 {
            let mut app_world = self.world(@"pwar");

            let mut id = app_world.dispatcher.uuid();
            if id == 0 {
                return 0;
            }

            // set id as GAME_ID=1
            let board: Board = app_world.read_model(GAME_ID);

            if position.x < board.origin.x || position.x >= board.origin.x
                + (board.width.try_into().unwrap())
                    || position.y < board.origin.y
                    || position.y >= board.origin.y
                + (board.height.try_into().unwrap()) {
                return OUT_OF_BOUNDS_GAME_ID; // OUT_OF_BOUNDS_GAME_ID for out of bounds
            };
            return 1;
        }

        fn get_game(self: @ContractState, id: u32) -> Game {
            let mut app_world = self.world(@"pwar");
            let game: Game = app_world.read_model((id));
            game
        }

        fn create_game(ref self: ContractState, origin: Position) -> u32 {
            let mut app_world = self.world(@"pwar");
            println!("create_game function called at x:{} and y:{}", origin.x, origin.y);

            let mut id = GAME_ID;

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
                guild_count: 0,
            };

            let board = Board { id, origin, width: DEFAULT_AREA, height: DEFAULT_AREA };

            app_world.write_model(@board); //not sure
            app_world.write_model(@game);

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
                    game_id: id, color: *a.at(color_idx), is_allowed: true,
                };
                let palette_colors = PaletteColors {
                    game_id: id, idx: color_idx, color: *a.at(color_idx),
                };
                let in_palette = InPalette { game_id: id, color: *a.at(color_idx), value: true };
                app_world.write_model(@allowed_color);
                app_world.write_model(@palette_colors);
                app_world.write_model(@in_palette);
                color_idx += 1;
            };

            // set default recovery_rate
            let pixel_recovery_rate = PixelRecoveryRate {
                game_id: id, rate: DEFAULT_RECOVERY_RATE,
            };
            let game_palette = GamePalette { game_id: id, length: 9 };
            app_world.write_model(@pixel_recovery_rate);
            app_world.write_model(@game_palette);

            id
            // emit event that game has started
        }

        // initialize guilds for the game
        fn create_game_guilds(
            ref self: ContractState, game_id: u32, guild_dispatcher: IGuildDispatcher,
        ) -> Array<u32> {
            let mut guild_ids = ArrayTrait::new();
            guild_ids.append(guild_dispatcher.create_guild(game_id, 'Fire'));
            guild_ids.append(guild_dispatcher.create_guild(game_id, 'Water'));
            guild_ids.append(guild_dispatcher.create_guild(game_id, 'Earth'));
            guild_ids.append(guild_dispatcher.create_guild(game_id, 'Air'));
            guild_ids
        }

        // To paint, basically use this function.
        fn place_pixel(
            ref self: ContractState, app: ContractAddress, default_params: DefaultParameters,
        ) {
            // Load important variables
            let mut core_world = self.world(@"pixelaw");
            let mut app_world = self.world(@"pwar");
            let core_actions = get_core_actions(ref core_world);
            let (player, system) = get_callers(ref core_world, default_params);
            let position = default_params.position;
            let game_id = self.get_game_id(position);
            assert(game_id != 0, 'this game does not exist');

            let allowed_color: AllowedColor = app_world.read_model((game_id, default_params.color));
            assert(
                allowed_color.is_allowed, 'color is not allowed',
            ); // cannot test correctly without cheatcodes.

            let mut pwarPlayer: Player = app_world.read_model(player);

            // get the game info
            let game: Game = app_world.read_model(game_id);

            // check the player is banned or not
            assert(pwarPlayer.is_banned == false, 'you are banned');

            // check if the game is ongoing
            assert(check_game_status(game.status()), 'game is not ongoing: actions1');

            println!("set_pixel BEGIN");
            let position = default_params.position;
            core_actions
                .update_pixel( //new
                    pwarPlayer.address,
                    system,
                    PixelUpdate {
                        position,
                        color: Option::Some(default_params.color),
                        timestamp: Option::None,
                        text: Option::None,
                        app: Option::None,
                        owner: Option::Some(pwarPlayer.address),
                        action: Option::None,
                    },
                    Option::None,
                    false,
                );
            println!("set_pixel END");

            pwarPlayer.num_owns += 1;
            pwarPlayer.num_commit += 1;
            println!("player.num_commit: {}", pwarPlayer.num_commit);
            pwarPlayer.last_date = get_block_timestamp();
            app_world.write_model(@pwarPlayer);

            // get the previous owner of PWarPixel
            let mut previous_pwarpixel: PWarPixel = app_world.read_model(position);

            if (previous_pwarpixel.owner != contract_address_const::<0x0>()
                && previous_pwarpixel.owner != pwarPlayer.address) {
                // get the previous player's info
                let mut previous_player: Player = app_world.read_model(previous_pwarpixel.owner);
                // decrease the previous player's num_owns
                previous_player.num_owns -= 1;
                app_world.write_model(@previous_player);
            }

            // set the new owner of PWarPixel
            previous_pwarpixel.owner = pwarPlayer.address;
            app_world.write_model(@previous_pwarpixel);
        }

        fn end_game(ref self: ContractState, game_id: u32) {
            // check if the time is expired.
            let mut app_world = self.world(@"pwar");
            let mut game: Game = app_world.read_model(game_id);
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

            app_world.write_model(@game);
            // TODO: emit the winner!
        }
    }
}
