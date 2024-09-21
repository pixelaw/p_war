// import test utils
use dojo::utils::test::{spawn_test_world, deploy_contract};
// import world dispatcher
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
// import test utils
use p_war::{
    models::{
        player::{player}, game::{Game, game}, board::{Board, GameId, board, game_id, p_war_pixel},
        proposal::{Proposal, pixel_recovery_rate, proposal, player_vote}, guilds::{guild},
        allowed_app::{AllowedApp, allowed_app},
        allowed_color::{AllowedColor, allowed_color, palette_colors, in_palette, game_palette},
    },
    systems::{
        actions::{p_war_actions, IActionsDispatcher, IActionsDispatcherTrait},
        propose::{propose_actions, IProposeDispatcher, IProposeDispatcherTrait},
        voting::{voting_actions, IVotingDispatcher, IVotingDispatcherTrait},
        guilds::{guild_actions, IGuildDispatcher, IGuildDispatcherTrait}
    }
};

use pixelaw::core::{
    models::{
        permissions::{permissions}, pixel::{pixel, Pixel, PixelUpdate}, queue::queue_item,
        registry::{app, app_user, app_name, core_actions_address, instruction},
    },
    actions::{
        actions as core_actions, IActionsDispatcher as ICoreActionsDispatcher,
        IActionsDispatcherTrait as ICoreActionsDispatcherTrait
    },
    utils::{DefaultParameters, Position}
};
use starknet::{class_hash::Felt252TryIntoClassHash, ContractAddress};


pub fn setup() -> (
    IWorldDispatcher,
    ICoreActionsDispatcher,
    IActionsDispatcher,
    IProposeDispatcher,
    IVotingDispatcher,
    IGuildDispatcher
) {
    let mut models = array![
        allowed_app::TEST_CLASS_HASH,
        allowed_color::TEST_CLASS_HASH,
        board::TEST_CLASS_HASH,
        game_id::TEST_CLASS_HASH,
        game::TEST_CLASS_HASH,
        game_palette::TEST_CLASS_HASH,
        in_palette::TEST_CLASS_HASH,
        palette_colors::TEST_CLASS_HASH,
        player::TEST_CLASS_HASH,
        player_vote::TEST_CLASS_HASH,
        pixel_recovery_rate::TEST_CLASS_HASH,
        pixel::TEST_CLASS_HASH,
        p_war_pixel::TEST_CLASS_HASH,
        proposal::TEST_CLASS_HASH,
        app::TEST_CLASS_HASH,
        app_name::TEST_CLASS_HASH,
        app_user::TEST_CLASS_HASH,
        core_actions_address::TEST_CLASS_HASH,
        permissions::TEST_CLASS_HASH,
        queue_item::TEST_CLASS_HASH,
        instruction::TEST_CLASS_HASH,
        guild::TEST_CLASS_HASH
    ];

    // deploy world with models
    let world = spawn_test_world(["pixelaw"].span(), models.into());

    println!("world deployed");

    let core_actions_address = world
        .deploy_contract('salt', core_actions::TEST_CLASS_HASH.try_into().unwrap());

    let core_actions = ICoreActionsDispatcher { contract_address: core_actions_address };

    // deploy systems contract
    let p_war_actions_address = world
        .deploy_contract('salty', p_war_actions::TEST_CLASS_HASH.try_into().unwrap());
    let p_war_actions = IActionsDispatcher { contract_address: p_war_actions_address };

    let propose_address = world
        .deploy_contract('salty1', propose_actions::TEST_CLASS_HASH.try_into().unwrap());
    let propose = IProposeDispatcher { contract_address: propose_address };

    let voting_address = world
        .deploy_contract('salty2', voting_actions::TEST_CLASS_HASH.try_into().unwrap());
    let voting = IVotingDispatcher { contract_address: voting_address };

    let guild_address = world
        .deploy_contract('salty3', guild_actions::TEST_CLASS_HASH.try_into().unwrap());
    let guild = IGuildDispatcher { contract_address: guild_address };

    println!("contracts deployed");

    world.grant_writer(selector_from_tag!("pixelaw-App"), core_actions_address);
    world.grant_writer(selector_from_tag!("pixelaw-AppName"), core_actions_address);
    world.grant_writer(selector_from_tag!("pixelaw-CoreActionsAddress"), core_actions_address);
    world.grant_writer(selector_from_tag!("pixelaw-Pixel"), core_actions_address);

    world.grant_writer(selector_from_tag!("pixelaw-Player"), p_war_actions_address);
    world.grant_writer(selector_from_tag!("pixelaw-Game"), p_war_actions_address);
    world.grant_writer(selector_from_tag!("pixelaw-Board"), p_war_actions_address);
    world.grant_writer(selector_from_tag!("pixelaw-AllowedColor"), p_war_actions_address);
    world.grant_writer(selector_from_tag!("pixelaw-PaletteColors"), p_war_actions_address);
    world.grant_writer(selector_from_tag!("pixelaw-PixelRecoveryRate"), p_war_actions_address);
    world.grant_writer(selector_from_tag!("pixelaw-InPalette"), p_war_actions_address);
    world.grant_writer(selector_from_tag!("pixelaw-GamePalette"), p_war_actions_address);
    world.grant_writer(selector_from_tag!("pixelaw-PWarPixel"), p_war_actions_address);

    world.grant_writer(selector_from_tag!("pixelaw-Player"), propose_address);
    world.grant_writer(selector_from_tag!("pixelaw-Proposal"), propose_address);
    world.grant_writer(selector_from_tag!("pixelaw-AllowedColor"), propose_address);
    world.grant_writer(selector_from_tag!("pixelaw-GamePalette"), propose_address);
    world.grant_writer(selector_from_tag!("pixelaw-InPalette"), propose_address);
    world.grant_writer(selector_from_tag!("pixelaw-PaletteColors"), propose_address);
    world.grant_writer(selector_from_tag!("pixelaw-Game"), propose_address);

    world.grant_writer(selector_from_tag!("pixelaw-Proposal"), voting_address);
    world.grant_writer(selector_from_tag!("pixelaw-Player"), voting_address);
    world.grant_writer(selector_from_tag!("pixelaw-PlayerVote"), voting_address);

    world.grant_writer(selector_from_tag!("pixelaw-Guild"), guild_address);
    world.grant_writer(selector_from_tag!("pixelaw-Game"), guild_address);
    world.grant_writer(selector_from_tag!("pixelaw-Player"), guild_address);
    core_actions.init();

    println!("grants done");

    (world, core_actions, p_war_actions, propose, voting, guild)
}
