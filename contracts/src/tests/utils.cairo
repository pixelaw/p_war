use dojo::model::{ModelStorage};
use dojo::world::{IWorldDispatcherTrait, WorldStorage, WorldStorageTrait};

use dojo_cairo_test::{
    ContractDef, ContractDefTrait, NamespaceDef, TestResource, WorldStorageTestTrait,
};
use pixelaw::core::models::pixel::{Pixel};


use pixelaw::core::utils::{DefaultParameters, Position, encode_rgba};
use pixelaw_testing::helpers::{set_caller, setup_core, update_test_world};
// import test utils
use pwar::{
    models::{
        player::{m_Player}, game::{m_Game},
        board::{m_Board, m_GameId, m_PWarPixel},
        proposal::{
            m_Proposal, m_PixelRecoveryRate, m_PlayerVote
        },
        guilds::{m_Guild},
        allowed_color::{
            m_AllowedColor, m_PaletteColors, m_InPalette,
            m_GamePalette
        },
    },
    systems::{
        actions::{pwar_actions, IActionsDispatcher, IActionsDispatcherTrait},
        propose::{propose_actions, IProposeDispatcher, IProposeDispatcherTrait},
        voting::{voting_actions, IVotingDispatcher, IVotingDispatcherTrait},
        guilds::{guild_actions, IGuildDispatcher, IGuildDispatcherTrait},
    },
};

pub fn deploy_pwar(
    ref world: WorldStorage
) -> (
    WorldStorage,
    IActionsDispatcher,
    IProposeDispatcher,
    IVotingDispatcher,
    IGuildDispatcher
) {

    let namespace = "pwar";

    world.dispatcher.register_namespace(namespace.clone());
    let ndef = namespace_def(namespace.clone());
    let cdefs = contract_defs(@namespace);

    update_test_world(ref world, [ndef].span());

    world.sync_perms_and_inits(cdefs);

    world.set_namespace(@namespace);

    let (pwar_actions, propose_actions, voting_actions, guild_actions) = setup_pwar_apps(world);

    world.set_namespace(@"pixelaw");

    (world, pwar_actions, propose_actions, voting_actions, guild_actions)
}

pub fn namespace_def(namespace: ByteArray) -> NamespaceDef {
    let ndef = NamespaceDef {
        namespace: namespace,
        resources: [
            TestResource::Model(m_Player::TEST_CLASS_HASH),
            TestResource::Model(m_Game::TEST_CLASS_HASH),
            TestResource::Model(m_Board::TEST_CLASS_HASH),
            TestResource::Model(m_GameId::TEST_CLASS_HASH),
            TestResource::Model(m_Guild::TEST_CLASS_HASH),
            TestResource::Model(m_AllowedColor::TEST_CLASS_HASH),
            TestResource::Model(m_PaletteColors::TEST_CLASS_HASH),
            TestResource::Model(m_InPalette::TEST_CLASS_HASH),
            TestResource::Model(m_GamePalette::TEST_CLASS_HASH),
            TestResource::Model(m_PWarPixel::TEST_CLASS_HASH),
            TestResource::Model(m_Proposal::TEST_CLASS_HASH),
            TestResource::Model(m_PixelRecoveryRate::TEST_CLASS_HASH),
            TestResource::Model(m_PlayerVote::TEST_CLASS_HASH),
            // TestResource::Event(pwar_actions::e_StartedGame::TEST_CLASS_HASH),
            // TestResource::Event(pwar_actions::e_EndedGame::TEST_CLASS_HASH),
            // TestResource::Event(propose_actions::e_ProposalCreated::TEST_CLASS_HASH),
            // TestResource::Event(propose_actions::e_ProposalActivated::TEST_CLASS_HASH),
            // TestResource::Event(guild_actions::e_GuildCreated::TEST_CLASS_HASH),
            // TestResource::Event(guild_actions::e_MemberAdded::TEST_CLASS_HASH),
            // TestResource::Event(guild_actions::e_MemberRemoved::TEST_CLASS_HASH),
            // TestResource::Event(voting_actions::e_Voted::TEST_CLASS_HASH),
            TestResource::Contract(pwar_actions::TEST_CLASS_HASH),
            TestResource::Contract(propose_actions::TEST_CLASS_HASH),
            TestResource::Contract(voting_actions::TEST_CLASS_HASH),
            TestResource::Contract(guild_actions::TEST_CLASS_HASH),
        ].span()
    };

    ndef
}

pub fn contract_defs(namespace: @ByteArray) -> Span<ContractDef> {
    let cdefs: Span<ContractDef> = [
        ContractDefTrait::new(namespace, @"pwar_actions")
            .with_writer_of([dojo::utils::bytearray_hash(namespace)].span()),
        ContractDefTrait::new(namespace, @"propose_actions")
            .with_writer_of([dojo::utils::bytearray_hash(namespace)].span()),
        ContractDefTrait::new(namespace, @"voting_actions")
            .with_writer_of([dojo::utils::bytearray_hash(namespace)].span()),
        ContractDefTrait::new(namespace, @"guild_actions")
            .with_writer_of([dojo::utils::bytearray_hash(namespace)].span()),
    ].span();
    cdefs
}

pub fn setup_pwar_apps(
    world: WorldStorage
) -> (
    IActionsDispatcher,
    IProposeDispatcher,
    IVotingDispatcher,
    IGuildDispatcher,
) {
    let pwar_actions_address = world.dns_address(@"pwar_actions").unwrap();
    let pwar_actions = IActionsDispatcher { contract_address: pwar_actions_address };

    let propose_address = world.dns_address(@"propose_actions").unwrap();
    let propose_actions = IProposeDispatcher { contract_address: propose_address };

    let voting_address = world.dns_address(@"voting_actions").unwrap();
    let voting_actions = IVotingDispatcher { contract_address: voting_address };

    let guild_address = world.dns_address(@"guild_actions").unwrap();
    let guild_actions = IGuildDispatcher { contract_address: guild_address };

    (pwar_actions, propose_actions, voting_actions, guild_actions)
}

// pub fn print_all_colors(ref world: WorldStorage, id: u32) {
//     let mut i = 0;
//     loop {
//         let color: PaletteColors = world.read_model((id, i));
//         let allowed_color: AllowedColor = world.read_model((id, color.color));
//         println!("@@@@@ COLOR: {}, {} @@@@", color.color, allowed_color.is_allowed);
//         i += 1;
//         if i == 9 {
//             break;
//         }
//     }
// }
