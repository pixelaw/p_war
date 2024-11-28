use p_war::{
    models::{guilds::{Guild, guild}},
    systems::{
        actions::{p_war_actions, IActionsDispatcher, IActionsDispatcherTrait},
        guilds::{guild_actions, IGuildDispatcher, IGuildDispatcherTrait}
    }
};

use pixelaw::core::{
    models::{
        permissions::{permissions}, pixel::{pixel, Pixel, PixelUpdate}, queue::queue_item,
        registry::{app, app_user, app_name, core_actions_address, instruction}
    },
    utils::{DefaultParameters, Position}
};
use starknet::{
    class_hash::Felt252TryIntoClassHash, ContractAddress,
    testing::{set_block_timestamp, set_account_contract_address, set_contract_address},
    get_block_timestamp, contract_address_const
};

const WHITE_COLOR: u32 = 0xFFFFFFFF;
const RED_COLOR: u32 = 0xFF000000;
const GAME_ORIGIN_POSITION: Position = Position { x: 0, y: 0 };
const GAME_PAINT_POSITION: Position = Position { x: 1, y: 1 };
const GAME_PAINT_POSITION_2: Position = Position { x: 2, y: 2 };
#[test]
#[available_gas(999_999_999)]
fn test_guild_operations() {
    println!("start test");

    let ZERO_ADDRESS: ContractAddress = contract_address_const::<0>();

    // Initialize the world and the actions
    let (world, _core_actions, p_war_actions, _propose, _voting, guild_actions, _guild_contract_address) =
        p_war::tests::utils::setup();

    println!("setup");

    // Setup players
    let PLAYER_1 = contract_address_const::<0x1337>();
    let PLAYER_2 = contract_address_const::<0x42>();
    // let PLAYER_3 = contract_address_const::<0x43>();

    println!("setup players");

    // Impersonate player1
    set_account_contract_address(PLAYER_1);

    println!("impersonate player1");

    // Create a game
    p_war_actions
        .interact(
            DefaultParameters {
                for_player: ZERO_ADDRESS,
                for_system: ZERO_ADDRESS,
                position: GAME_ORIGIN_POSITION,
                color: WHITE_COLOR
            }
        );

    let game_id = p_war_actions.get_game_id(GAME_ORIGIN_POSITION);
    println!("game created: game_id = {}", game_id);

    //was not able to import set_call from core::helpers
    set_account_contract_address(PLAYER_1);
    set_contract_address(PLAYER_1);
    let guild_id = guild_actions.create_guild(game_id, 'Test Guild');
    println!("guild created: guild_id = {}", guild_id);

    // Check if the guild was created
    let guild: Guild = world.read_model(game_id, guild_id);
    assert(guild.guild_name == 'Test Guild', 'Guild name mismatch');
    assert(guild.creator == PLAYER_1, 'Guild creator mismatch');
    assert(guild.member_count == 1, 'create, should be 1');

    println!("check guild passed");

    // Add a member
    set_account_contract_address(PLAYER_1);
    set_contract_address(PLAYER_1);
    guild_actions.add_member(game_id, guild_id, PLAYER_2);

    // Check if the member was added
    let updated_guild: Guild = world.read_model(game_id, guild_id);
    assert(updated_guild.member_count == 2, 'Member count should be 2');

    // Remove a member
    guild_actions.remove_member(game_id, guild_id, PLAYER_2);

    // Check if the member was removed
    let final_guild: Guild = world.read_model(game_id, guild_id);
    assert(final_guild.member_count == 1, 'remove, should be 1');

    println!("guild operations passed");
}

#[test]
#[available_gas(999_999_999)]
#[should_panic(expected: 'Guild points mismatch')]
fn test_guild_points() {

    // Initialize the world and the actions
    let (_world, _core_actions, p_war_actions, _propose, _voting, guild_actions, _guild_contract_address) =
    p_war::tests::utils::setup();
    println!("setup");

    let ZERO_ADDRESS: ContractAddress = contract_address_const::<0>();
    let PLAYER_1 = contract_address_const::<0x1337>();
    set_account_contract_address(PLAYER_1);
    set_contract_address(PLAYER_1);
    p_war_actions
        .interact(
            DefaultParameters {
                for_player: ZERO_ADDRESS, // Leave this 0 if not processing the Queue
                for_system: ZERO_ADDRESS, // Leave this 0 if not processing the Queue
                position: GAME_ORIGIN_POSITION,
                color: WHITE_COLOR
            }
        );
    let game_id = p_war_actions.get_game_id(GAME_ORIGIN_POSITION);
    println!("game created: game_id = {}", game_id);

    //was not able to import set_call from core::helpers
    set_account_contract_address(PLAYER_1);
    set_contract_address(PLAYER_1);
    let guild_id = guild_actions.create_guild(game_id, 'Test Guild');
    println!("guild created: guild_id = {}", guild_id);
    //place a pixel
    p_war_actions
        .interact(
            DefaultParameters {
                for_player: ZERO_ADDRESS, // Leave this 0 if not processing the Queue
                for_system: ZERO_ADDRESS, // Leave this 0 if not processing the Queue
                position: GAME_PAINT_POSITION,
                color: WHITE_COLOR
            }
        );
    p_war_actions
        .interact(
            DefaultParameters {
                for_player: ZERO_ADDRESS, // Leave this 0 if not processing the Queue
                for_system: ZERO_ADDRESS, // Leave this 0 if not processing the Queue
                position: GAME_PAINT_POSITION_2,
                color: WHITE_COLOR
            }
        );
    let guild_points = guild_actions.get_guild_points(game_id, guild_id);
    println!("test: guild_points: {}", guild_points);
    assert(guild_points == 1, 'Guild points mismatch');
}

#[test]
#[available_gas(999_999_999)]
fn test_guild_creation() {
    // Initialize the world and the actions
    let (world, _core_actions, p_war_actions, _propose, _voting, _guild_actions, guild_contract_address) =
        p_war::tests::utils::setup();

    // Setup players
    let PLAYER_1 = contract_address_const::<0x1337>();
    let ZERO_ADDRESS: ContractAddress = contract_address_const::<0>();

    // Impersonate player1
    set_account_contract_address(PLAYER_1);

    // Create a game
    p_war_actions
        .interact(
            DefaultParameters {
                for_player: ZERO_ADDRESS,
                for_system: ZERO_ADDRESS,
                position: GAME_ORIGIN_POSITION,
                color: WHITE_COLOR
            }
        );

    let game_id: u32 = p_war_actions.get_game_id(GAME_ORIGIN_POSITION);

    //p_war_actions.set_guild_contract_address(game_id, guild_contract_address);

    set_account_contract_address(PLAYER_1);
    set_contract_address(PLAYER_1);
    // Create guilds for the game
    let guild_ids: Array<u32> = p_war_actions.create_game_guilds(game_id, guild_contract_address);
    
    // Create a guild
    let guild_id: u32 = *guild_ids.at(0);
    println!("guild_id: {}", guild_id);
    let guild: Guild = world.read_model(game_id, guild_id);
    assert(guild.guild_name == 'Fire', 'Guild name mismatch');
    
    let guild_id_2 = *guild_ids.at(1);
    println!("guild_id_2: {}", guild_id_2);
    let guild: Guild = world.read_model(game_id, guild_id_2);
    assert(guild.guild_name == 'Water', 'Guild name mismatch');
    
    let guild_id_3 = *guild_ids.at(2);
    println!("guild_id_3: {}", guild_id_3);
    let guild: Guild = world.read_model(game_id, guild_id_3);
    assert(guild.guild_name == 'Earth', 'Guild name mismatch');
    
    let guild_id_4 = *guild_ids.at(3);
    println!("guild_id_4: {}", guild_id_4);
    let guild: Guild = world.read_model(game_id, guild_id_4);
    assert(guild.guild_name == 'Air', 'Guild name mismatch');
    println!("Guild creation tests passed successfully");
}
