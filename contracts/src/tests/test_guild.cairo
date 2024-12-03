use p_war::tests::utils::{deploy_p_war, print_all_colors};
use dojo::model::{ModelStorage, ModelValueStorage};
use dojo::world::{WorldStorage, WorldStorageTrait};
use dojo::event::EventStorage;
use pixelaw_test_helpers::{setup_core_initialized};
use starknet::{class_hash::Felt252TryIntoClassHash, ContractAddress,
    testing::{set_block_timestamp, set_account_contract_address, set_contract_address},
    get_block_timestamp, contract_address_const};
use p_war::{
    models::{
        game::{Game}, board::{Board, GameId, Position}, proposal::{Proposal},
        guilds::{Guild},
        allowed_app::AllowedApp, allowed_color::{AllowedColor, PaletteColors},
    },
    systems::{
        actions::{p_war_actions, IActionsDispatcher, IActionsDispatcherTrait},
        propose::{propose_actions, IProposeDispatcher, IProposeDispatcherTrait},
        voting::{voting_actions, IVotingDispatcher, IVotingDispatcherTrait},
        guilds::{guild_actions, IGuildDispatcher, IGuildDispatcherTrait}
    },
    constants::{GAME_DURATION, PROPOSAL_DURATION}
};
use pixelaw::core::{
    models::{
        pixel::{Pixel, PixelUpdate},
    },
    actions::{
        actions as core_actions, IActionsDispatcher as ICoreActionsDispatcher,
        IActionsDispatcherTrait as ICoreActionsDispatcherTrait
    },
    utils::{DefaultParameters, Position as PixelawPosition, is_pixel_color}
};

const WHITE_COLOR: u32 = 0xFFFFFFFF;
const RED_COLOR: u32 = 0xFF000000;
const GAME_ORIGIN_POSITION: Position = Position { x: 0, y: 0 };
const GAME_PAINT_POSITION: Position = Position { x: 1, y: 1 };
const GAME_PAINT_POSITION_2: Position = Position { x: 2, y: 2 };

// #[test]
// #[available_gas(999_999_999)]
// fn test_guild_operations() {
//     println!("start test");

//     // Initialize the world and the actions
//     let (mut world, _core_actions, _player_1, _player_2) = setup_core_initialized();
//     let (_world, p_war_actions, _propose_action, _voting_action, guild_actions, _allowed_app) = deploy_p_war(ref world);

//     println!("setup done");

//     // Setup players
//     let PLAYER_1 = contract_address_const::<0x1337>();
//     let PLAYER_2 = contract_address_const::<0x42>();
//     // let PLAYER_3 = contract_address_const::<0x43>();

//     // Create a game
//     p_war_actions
//         .interact(
//             DefaultParameters {
//                 player_override: Option::None,
//                 system_override: Option::None,
//                 area_hint: Option::None,
//                 position: GAME_ORIGIN_POSITION,
//                 color: WHITE_COLOR
//             }
//         );

//     let game_id = p_war_actions.get_game_id(GAME_ORIGIN_POSITION);
//     println!("game created: game_id = {}", game_id);

//     //was not able to import set_call from core::helpers
//     set_account_contract_address(PLAYER_1);
//     set_contract_address(PLAYER_1);
//     let guild_id = guild_actions.create_guild(game_id, 'Test Guild');
//     println!("guild created: guild_id = {}", guild_id);

//     // Check if the guild was created
//     let guild: Guild = world.read_model((game_id, guild_id));
//     println!("guild name: {:?}", guild.guild_name);
//     println!("guild creator: {:?}", guild.creator);
//     assert(guild.guild_name == 'Test Guild', 'Guild name mismatch');
//     assert(guild.creator == PLAYER_1, 'Guild creator mismatch');
//     assert(guild.member_count == 1, 'create, should be 1');

//     println!("check guild passed");

//     // Add a member
//     set_account_contract_address(PLAYER_1);
//     set_contract_address(PLAYER_1);
//     guild_actions.add_member(game_id, guild_id, PLAYER_2);

//     // Check if the member was added
//     let updated_guild: Guild = world.read_model((game_id, guild_id));
//     assert(updated_guild.member_count == 2, 'Member count should be 2');

//     // Remove a member
//     set_account_contract_address(PLAYER_1);
//     set_contract_address(PLAYER_1);
//     guild_actions.remove_member(game_id, guild_id, PLAYER_2);

//     // Check if the member was removed
//     let final_guild: Guild = world.read_model((game_id, guild_id));
//     assert(final_guild.member_count == 1, 'remove, should be 1');

//     println!("guild operations passed");
// }

#[test]
#[available_gas(999_999_999)]
fn test_guild_points() {
    // Initialize the world and the actions
    let (mut world, _core_actions, _player_1, _player_2) = setup_core_initialized();
    let (_world, p_war_actions, _propose_action, _voting_action, guild_actions, _allowed_app) = deploy_p_war(ref world);
    println!("setup");

    let PLAYER_1 = contract_address_const::<0x1337>();
    let PLAYER_2 = contract_address_const::<0x42>();

    p_war_actions
        .interact(
            DefaultParameters {
                player_override: Option::None,
                system_override: Option::None,
                area_hint: Option::None,
                position: GAME_ORIGIN_POSITION,
                color: WHITE_COLOR
            }
        );
    let game_id = p_war_actions.get_game_id(GAME_ORIGIN_POSITION);
    println!("game created: game_id = {}", game_id);

    //create guild
    set_account_contract_address(PLAYER_1);
    set_contract_address(PLAYER_1);
    let guild_id = guild_actions.create_guild(game_id, 'Test Guild');
    println!("guild created: guild_id = {}", guild_id);
    //place a pixel
    set_account_contract_address(PLAYER_1);
    set_contract_address(PLAYER_1);
    p_war_actions
        .interact(
            DefaultParameters {
                player_override: Option::None,
                system_override: Option::None,
                area_hint: Option::None,
                position: GAME_PAINT_POSITION,
                color: WHITE_COLOR
            }
        );
    p_war_actions
        .interact(
            DefaultParameters {
                player_override: Option::None,
                system_override: Option::None,
                area_hint: Option::None,
                position: GAME_PAINT_POSITION_2,
                color: WHITE_COLOR
            }
        );
    
    //add member
    set_account_contract_address(PLAYER_1);
    set_contract_address(PLAYER_1);
    guild_actions.add_member(game_id, guild_id, PLAYER_2);
    let updated_guild: Guild = world.read_model((game_id, guild_id));
    assert(updated_guild.member_count == 2, 'Member count should be 2');

    set_account_contract_address(PLAYER_2);
    set_contract_address(PLAYER_2);
    p_war_actions
    .interact(
        DefaultParameters {
            player_override: Option::None,
            system_override: Option::None,
            area_hint: Option::None,
            position: GAME_PAINT_POSITION,
            color: WHITE_COLOR
        }
    );
    p_war_actions
        .interact(
            DefaultParameters {
                player_override: Option::None,
                system_override: Option::None,
                area_hint: Option::None,
                position: GAME_PAINT_POSITION_2,
                color: WHITE_COLOR
            }
        );


    let guild_points = guild_actions.get_guild_points(game_id, guild_id);
    println!("test: guild_points: {}", guild_points);
    assert(guild_points == 4, 'Guild points mismatch');
}

// #[test]
// #[available_gas(999_999_999)]
// fn test_guild_creation() {
//     // Initialize the world and the actions
//     let (mut world, _core_actions, _player_1, _player_2) = setup_core_initialized();
//     let (_world, p_war_actions, _propose_action, _voting_action, guild_actions, _allowed_app) = deploy_p_war(ref world);

//     // Setup players
//     let PLAYER_1 = contract_address_const::<0x1337>();

//     // Create a game
//     p_war_actions
//         .interact(
//             DefaultParameters {
//                 player_override: Option::None,
//                 system_override: Option::None,
//                 area_hint: Option::None,
//                 position: GAME_ORIGIN_POSITION,
//                 color: WHITE_COLOR
//             }
//         );

//     let game_id: u32 = p_war_actions.get_game_id(GAME_ORIGIN_POSITION);
    
//     // Create guilds for the game
//     set_account_contract_address(PLAYER_1);
//     set_contract_address(PLAYER_1);
//     let guild_ids: Array<u32> = p_war_actions.create_game_guilds(game_id, guild_actions);
    
//     // Create a guild
//     let guild_id: u32 = *guild_ids.at(0);
//     println!("guild_id: {}", guild_id);
//     let guild: Guild = world.read_model((game_id, guild_id));
//     println!("guild_name: {:?}", guild.guild_name);
//     assert(guild.guild_name == 'Fire', 'Guild name mismatch');
    
//     let guild_id_2 = *guild_ids.at(1);
//     println!("guild_id_2: {}", guild_id_2);
//     let guild: Guild = world.read_model((game_id, guild_id_2));
//     println!("guild_name_2: {:?}", guild.guild_name);
//     assert(guild.guild_name == 'Water', 'Guild name mismatch');
    
//     let guild_id_3 = *guild_ids.at(2);
//     println!("guild_id_3: {}", guild_id_3);
//     let guild: Guild = world.read_model((game_id, guild_id_3));
//     println!("guild_name_3: {:?}", guild.guild_name);
//     assert(guild.guild_name == 'Earth', 'Guild name mismatch');
    
//     let guild_id_4 = *guild_ids.at(3);
//     println!("guild_id_4: {}", guild_id_4);
//     let guild: Guild = world.read_model((game_id, guild_id_4));
//     println!("guild_name_4: {:?}", guild.guild_name);
//     assert(guild.guild_name == 'Air', 'Guild name mismatch');
//     println!("Guild creation tests passed successfully");
// }
