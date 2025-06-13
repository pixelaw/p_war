use dojo::world::{IWorldDispatcherTrait, WorldStorage, WorldStorageTrait};
use dojo_cairo_test::{
    ContractDef, ContractDefTrait, NamespaceDef, TestResource, WorldStorageTestTrait,
};
use pixelaw_testing::helpers::{update_test_world};

// Import pwar models
use pwar::models::allowed_color::{
    AllowedColor, GamePalette, InPalette, PaletteColors, m_AllowedColor, m_GamePalette, m_InPalette,
    m_PaletteColors,
};
use pwar::models::board::{Board, PWarPixel, m_Board, m_PWarPixel};
use pwar::models::game::{Game, m_Game};
use pwar::models::guilds::{Guild, m_Guild};
use pwar::models::player::{Player, m_Player};
use pwar::models::proposal::{
    PixelRecoveryRate, PlayerVote, Proposal, m_PixelRecoveryRate, m_PlayerVote, m_Proposal,
};

// Import pwar systems
use pwar::systems::actions::{IActionsDispatcher, pwar_actions};
use pwar::systems::guilds::{IGuildDispatcher, guild_actions};
use pwar::systems::propose::{IProposeDispatcher, propose_actions};
use pwar::systems::voting::{IVotingDispatcher, voting_actions};

// Constants for testing
const DEFAULT_COLOR: u32 = 0x000000FF; // Black with full alpha
const NEW_COLOR: u32 = 0xFF5500FF; // Orange with full alpha

fn namespace_def() -> NamespaceDef {
    let ndef = NamespaceDef {
        namespace: "pwar",
        resources: [
            // Models as TestResources
            TestResource::Model(m_Game::TEST_CLASS_HASH),
            TestResource::Model(m_Player::TEST_CLASS_HASH),
            TestResource::Model(m_Board::TEST_CLASS_HASH),
            TestResource::Model(m_PWarPixel::TEST_CLASS_HASH),
            TestResource::Model(m_Proposal::TEST_CLASS_HASH),
            TestResource::Model(m_PlayerVote::TEST_CLASS_HASH),
            TestResource::Model(m_PixelRecoveryRate::TEST_CLASS_HASH),
            TestResource::Model(m_Guild::TEST_CLASS_HASH),
            TestResource::Model(m_AllowedColor::TEST_CLASS_HASH),
            TestResource::Model(m_GamePalette::TEST_CLASS_HASH),
            TestResource::Model(m_InPalette::TEST_CLASS_HASH),
            TestResource::Model(m_PaletteColors::TEST_CLASS_HASH),
            // Contracts
            TestResource::Contract(pwar_actions::TEST_CLASS_HASH),
            TestResource::Contract(propose_actions::TEST_CLASS_HASH),
            TestResource::Contract(voting_actions::TEST_CLASS_HASH),
            TestResource::Contract(guild_actions::TEST_CLASS_HASH),
        ]
            .span(),
    };

    ndef
}

fn contract_defs() -> Span<ContractDef> {
    [
        ContractDefTrait::new(@"pwar", @"pwar_actions")
            .with_writer_of([dojo::utils::bytearray_hash(@"pwar")].span()),
        ContractDefTrait::new(@"pwar", @"propose_actions")
            .with_writer_of([dojo::utils::bytearray_hash(@"pwar")].span()),
        ContractDefTrait::new(@"pwar", @"voting_actions")
            .with_writer_of([dojo::utils::bytearray_hash(@"pwar")].span()),
        ContractDefTrait::new(@"pwar", @"guild_actions")
            .with_writer_of([dojo::utils::bytearray_hash(@"pwar")].span()),
    ]
        .span()
}

// Helper function to deploy pwar systems
pub fn deploy_pwar(
    ref world: WorldStorage,
) -> (IActionsDispatcher, IProposeDispatcher, IVotingDispatcher, IGuildDispatcher) {
    // Register the pwar namespace
    let namespace = "pwar";
    world.dispatcher.register_namespace(namespace.clone());

    // Get namespace and contract definitions
    let ndef = namespace_def();
    let cdefs = contract_defs();
    println!("name space definitions");

    // Update the test world with our namespace
    update_test_world(ref world, [ndef].span());

    // Sync permissions and initializations
    world.sync_perms_and_inits(cdefs);

    // Set the namespace to pwar to find the contract addresses
    world.set_namespace(@namespace);

    // Get the contract addresses from DNS
    let pwar_actions_address = world.dns_address(@"pwar_actions").unwrap();
    let propose_address = world.dns_address(@"propose_actions").unwrap();
    let voting_address = world.dns_address(@"voting_actions").unwrap();
    let guild_address = world.dns_address(@"guild_actions").unwrap();

    // Create the dispatchers
    let pwar_actions = IActionsDispatcher { contract_address: pwar_actions_address };
    let propose_actions = IProposeDispatcher { contract_address: propose_address };
    let voting_actions = IVotingDispatcher { contract_address: voting_address };
    let guild_actions = IGuildDispatcher { contract_address: guild_address };

    // Set the namespace back to pixelaw
    world.set_namespace(@"pixelaw");

    println!("pwar deployment finished");

    (pwar_actions, propose_actions, voting_actions, guild_actions)
}
