// import test utils
// import world dispatcher
use debug::PrintTrait;
use dojo::model::{ModelStorage};
use dojo::world::{world, IWorldDispatcher, IWorldDispatcherTrait, WorldStorageTrait, WorldStorage};
use dojo_cairo_test::{
    spawn_test_world, NamespaceDef, TestResource, ContractDefTrait, ContractDef,
    WorldStorageTestTrait
};
// import test utils
use p_war::{
    models::{
        player::{Player, m_Player}, game::{Game, m_Game},
        board::{Board, m_Board, GameId, m_GameId, PWarPixel, m_PWarPixel},
        proposal::{
            Proposal, m_Proposal, PixelRecoveryRate, m_PixelRecoveryRate, PlayerVote, m_PlayerVote
        },
        guilds::{Guild, m_Guild}, allowed_app::{AllowedApp, m_AllowedApp},
        allowed_color::{
            AllowedColor, m_AllowedColor, PaletteColors, m_PaletteColors, InPalette, m_InPalette,
            GamePalette, m_GamePalette
        },
    },
    systems::{
        actions::{p_war_actions, IActionsDispatcher, IActionsDispatcherTrait},
        propose::{propose_actions, IProposeDispatcher, IProposeDispatcherTrait},
        voting::{voting_actions, IVotingDispatcher, IVotingDispatcherTrait},
        guilds::{guild_actions, IGuildDispatcher, IGuildDispatcherTrait},
        app::{allowed_app_actions, IAllowedAppDispatcher, IAllowedAppDispatcherTrait}
    },
};

use pixelaw::core::utils::{
    get_core_actions, encode_rgba, decode_rgba, Direction, Position, DefaultParameters
};
use pixelaw_test_helpers::{
    update_test_world, setup_core, setup_core_initialized, setup_apps, setup_apps_initialized,
    ZERO_ADDRESS, set_caller, drop_all_events, TEST_POSITION, WHITE_COLOR, RED_COLOR
};
use starknet::class_hash::Felt252TryIntoClassHash;

use zeroable::Zeroable;

pub fn deploy_p_war(
    ref world: WorldStorage
) -> (
    WorldStorage,
    IActionsDispatcher,
    IProposeDispatcher,
    IVotingDispatcher,
    IGuildDispatcher,
    IAllowedAppDispatcher
) {
    let ndef = namespace_def();
    let cdefs = contract_defs();

    update_test_world(ref world, [ndef].span());

    world.sync_perms_and_inits(cdefs);

    let (p_war_actions, propose, voting, guild, allowed_app) = setup_pwar_apps_initialized(world);

    (world, p_war_actions, propose, voting, guild, allowed_app)
}

pub fn namespace_def() -> NamespaceDef {
    let ndef = NamespaceDef {
        namespace: "pixelaw", resources: [
            TestResource::Model(m_Player::TEST_CLASS_HASH),
            TestResource::Model(m_Game::TEST_CLASS_HASH),
            TestResource::Model(m_Board::TEST_CLASS_HASH),
            TestResource::Model(m_GameId::TEST_CLASS_HASH),
            TestResource::Model(m_Guild::TEST_CLASS_HASH),
            TestResource::Model(m_AllowedApp::TEST_CLASS_HASH),
            TestResource::Model(m_AllowedColor::TEST_CLASS_HASH),
            TestResource::Model(m_PaletteColors::TEST_CLASS_HASH),
            TestResource::Model(m_InPalette::TEST_CLASS_HASH),
            TestResource::Model(m_GamePalette::TEST_CLASS_HASH),
            TestResource::Model(m_PWarPixel::TEST_CLASS_HASH),
            TestResource::Model(m_Proposal::TEST_CLASS_HASH),
            TestResource::Model(m_PixelRecoveryRate::TEST_CLASS_HASH),
            TestResource::Model(m_PlayerVote::TEST_CLASS_HASH),
            TestResource::Event(p_war_actions::e_StartedGame::TEST_CLASS_HASH),
            TestResource::Event(p_war_actions::e_EndedGame::TEST_CLASS_HASH),
            TestResource::Event(propose_actions::e_ProposalCreated::TEST_CLASS_HASH),
            TestResource::Event(propose_actions::e_ProposalActivated::TEST_CLASS_HASH),
            TestResource::Event(guild_actions::e_GuildCreated::TEST_CLASS_HASH),
            TestResource::Event(guild_actions::e_MemberAdded::TEST_CLASS_HASH),
            TestResource::Event(guild_actions::e_MemberRemoved::TEST_CLASS_HASH),
            TestResource::Event(voting_actions::e_Voted::TEST_CLASS_HASH),
            TestResource::Contract(p_war_actions::TEST_CLASS_HASH),
            TestResource::Contract(propose_actions::TEST_CLASS_HASH),
            TestResource::Contract(voting_actions::TEST_CLASS_HASH),
            TestResource::Contract(guild_actions::TEST_CLASS_HASH),
            TestResource::Contract(allowed_app_actions::TEST_CLASS_HASH),
        ].span()
    };

    ndef
}

pub fn contract_defs() -> Span<ContractDef> {
    let cdefs: Span<ContractDef> = [
        ContractDefTrait::new(@"pixelaw", @"p_war_actions")
            .with_writer_of([dojo::utils::bytearray_hash(@"pixelaw")].span()),
        ContractDefTrait::new(@"pixelaw", @"propose_actions")
            .with_writer_of([dojo::utils::bytearray_hash(@"pixelaw")].span()),
        ContractDefTrait::new(@"pixelaw", @"voting_actions")
            .with_writer_of([dojo::utils::bytearray_hash(@"pixelaw")].span()),
        ContractDefTrait::new(@"pixelaw", @"guild_actions")
            .with_writer_of([dojo::utils::bytearray_hash(@"pixelaw")].span()),
        ContractDefTrait::new(@"pixelaw", @"allowed_app_actions")
            .with_writer_of([dojo::utils::bytearray_hash(@"pixelaw")].span()),
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
    IAllowedAppDispatcher
) {
    let (p_war_actions_address, _) = world.dns(@"p_war_actions").unwrap();
    let p_war_actions = IActionsDispatcher { contract_address: p_war_actions_address };

    let (propose_address, _) = world.dns(@"propose_actions").unwrap();
    let propose_actions = IProposeDispatcher { contract_address: propose_address };

    let (voting_address, _) = world.dns(@"voting_actions").unwrap();
    let voting_actions = IVotingDispatcher { contract_address: voting_address };

    let (guild_address, _) = world.dns(@"guild_actions").unwrap();
    let guild_actions = IGuildDispatcher { contract_address: guild_address };

    let (allowed_app_address, _) = world.dns(@"allowed_app_actions").unwrap();
    let allowed_app_actions = IAllowedAppDispatcher { contract_address: allowed_app_address };

    (p_war_actions, propose_actions, voting_actions, guild_actions, allowed_app_actions)
}

pub fn setup_pwar_apps_initialized(
    world: WorldStorage
) -> (
    IActionsDispatcher,
    IProposeDispatcher,
    IVotingDispatcher,
    IGuildDispatcher,
    IAllowedAppDispatcher
) {
    let (
        p_war_actions, propose_actions, voting_actions, guild_actions, allowed_app_actions
    ): (
        IActionsDispatcher,
        IProposeDispatcher,
        IVotingDispatcher,
        IGuildDispatcher,
        IAllowedAppDispatcher
    ) =
        setup_pwar_apps(
        world
    );
    p_war_actions.init();
    // propose_actions.init();
    // voting_actions.init();
    // guild_actions.init();
    // allowed_app_actions.init();

    (p_war_actions, propose_actions, voting_actions, guild_actions, allowed_app_actions)
}

pub fn print_all_colors(ref world: WorldStorage, id: u32) {
    let mut i = 0;
    loop {
        let color: PaletteColors = world.read_model((id, i));
        let allowed_color: AllowedColor = world.read_model((id, color.color));
        println!("@@@@@ COLOR: {}, {} @@@@", color.color, allowed_color.is_allowed);
        i += 1;
        if i == 9 {
            break;
        }
    }
}
