import type { SchemaType as ISchemaType } from "@dojoengine/sdk";

import { CairoOption, CairoOptionVariant, BigNumberish } from 'starknet';

// Type definition for `pixelaw::core::models::area::Area` struct
export interface Area {
	id: BigNumberish;
	app: string;
	owner: string;
	color: BigNumberish;
}

// Type definition for `pixelaw::core::models::area::AreaValue` struct
export interface AreaValue {
	app: string;
	owner: string;
	color: BigNumberish;
}

// Type definition for `pixelaw::core::models::area::RTree` struct
export interface RTree {
	id: BigNumberish;
	children: BigNumberish;
}

// Type definition for `pixelaw::core::models::area::RTreeValue` struct
export interface RTreeValue {
	children: BigNumberish;
}

// Type definition for `pixelaw::core::models::dummy::Dummy` struct
export interface Dummy {
	id: BigNumberish;
	defaultParams: DefaultParameters;
	bounds: Bounds;
	pixelUpdate: PixelUpdate;
	emoji: Emoji;
}

// Type definition for `pixelaw::core::models::dummy::DummyValue` struct
export interface DummyValue {
	defaultParams: DefaultParameters;
	bounds: Bounds;
	pixelUpdate: PixelUpdate;
	emoji: Emoji;
}

// Type definition for `pixelaw::core::models::pixel::Pixel` struct
export interface Pixel {
	position: Position;
	app: string;
	color: BigNumberish;
	created_at: BigNumberish;
	updated_at: BigNumberish;
	timestamp: BigNumberish;
	owner: string;
	text: BigNumberish;
	action: BigNumberish;
}

// Type definition for `pixelaw::core::models::pixel::PixelUpdate` struct
export interface PixelUpdate {
	position: Position;
	color: CairoOption<BigNumberish>;
	owner: CairoOption<string>;
	app: CairoOption<string>;
	text: CairoOption<BigNumberish>;
	timestamp: CairoOption<BigNumberish>;
	action: CairoOption<BigNumberish>;
}

// Type definition for `pixelaw::core::models::pixel::PixelValue` struct
export interface PixelValue {
	app: string;
	color: BigNumberish;
	created_at: BigNumberish;
	updated_at: BigNumberish;
	timestamp: BigNumberish;
	owner: string;
	text: BigNumberish;
	action: BigNumberish;
}

// Type definition for `pixelaw::core::models::queue::QueueItem` struct
export interface QueueItem {
	id: BigNumberish;
	valid: boolean;
}

// Type definition for `pixelaw::core::models::queue::QueueItemValue` struct
export interface QueueItemValue {
	valid: boolean;
}

// Type definition for `pixelaw::core::models::registry::App` struct
export interface App {
	system: string;
	name: BigNumberish;
	icon: BigNumberish;
	action: BigNumberish;
}

// Type definition for `pixelaw::core::models::registry::AppName` struct
export interface AppName {
	name: BigNumberish;
	system: string;
}

// Type definition for `pixelaw::core::models::registry::AppNameValue` struct
export interface AppNameValue {
	system: string;
}

// Type definition for `pixelaw::core::models::registry::AppValue` struct
export interface AppValue {
	name: BigNumberish;
	icon: BigNumberish;
	action: BigNumberish;
}

// Type definition for `pixelaw::core::models::registry::CoreActionsAddress` struct
export interface CoreActionsAddress {
	key: BigNumberish;
	value: string;
}

// Type definition for `pixelaw::core::models::registry::CoreActionsAddressValue` struct
export interface CoreActionsAddressValue {
	value: string;
}

// Type definition for `pixelaw::core::utils::Bounds` struct
export interface Bounds {
	x_min: BigNumberish;
	y_min: BigNumberish;
	x_max: BigNumberish;
	y_max: BigNumberish;
}

// Type definition for `pixelaw::core::utils::DefaultParameters` struct
export interface DefaultParameters {
	player_override: CairoOption<string>;
	system_override: CairoOption<string>;
	area_hint: CairoOption<BigNumberish>;
	position: Position;
	color: BigNumberish;
}

// Type definition for `pixelaw::core::utils::Emoji` struct
export interface Emoji {
	value: BigNumberish;
}

// Type definition for `pixelaw::core::utils::Position` struct
export interface Position {
	x: BigNumberish;
	y: BigNumberish;
}

// Type definition for `pwar::models::allowed_color::AllowedColor` struct
export interface AllowedColor {
	game_id: BigNumberish;
	color: BigNumberish;
	is_allowed: boolean;
}

// Type definition for `pwar::models::allowed_color::AllowedColorValue` struct
export interface AllowedColorValue {
	is_allowed: boolean;
}

// Type definition for `pwar::models::allowed_color::GamePalette` struct
export interface GamePalette {
	game_id: BigNumberish;
	length: BigNumberish;
}

// Type definition for `pwar::models::allowed_color::GamePaletteValue` struct
export interface GamePaletteValue {
	length: BigNumberish;
}

// Type definition for `pwar::models::allowed_color::InPalette` struct
export interface InPalette {
	game_id: BigNumberish;
	color: BigNumberish;
	value: boolean;
}

// Type definition for `pwar::models::allowed_color::InPaletteValue` struct
export interface InPaletteValue {
	value: boolean;
}

// Type definition for `pwar::models::allowed_color::PaletteColors` struct
export interface PaletteColors {
	game_id: BigNumberish;
	idx: BigNumberish;
	color: BigNumberish;
}

// Type definition for `pwar::models::allowed_color::PaletteColorsValue` struct
export interface PaletteColorsValue {
	color: BigNumberish;
}

// Type definition for `pwar::models::board::Board` struct
export interface Board {
	id: BigNumberish;
	origin: Position;
	width: BigNumberish;
	height: BigNumberish;
}

// Type definition for `pwar::models::board::BoardValue` struct
export interface BoardValue {
	origin: Position;
	width: BigNumberish;
	height: BigNumberish;
}

// Type definition for `pwar::models::board::GameId` struct
export interface GameId {
	x: BigNumberish;
	y: BigNumberish;
	value: BigNumberish;
}

// Type definition for `pwar::models::board::GameIdValue` struct
export interface GameIdValue {
	value: BigNumberish;
}

// Type definition for `pwar::models::board::PWarPixel` struct
export interface PWarPixel {
	position: Position;
	owner: string;
}

// Type definition for `pwar::models::board::PWarPixelValue` struct
export interface PWarPixelValue {
	owner: string;
}

// Type definition for `pwar::models::game::Game` struct
export interface Game {
	id: BigNumberish;
	start: BigNumberish;
	end: BigNumberish;
	proposal_idx: BigNumberish;
	coeff_own_pixels: BigNumberish;
	coeff_commits: BigNumberish;
	winner_config: BigNumberish;
	winner: string;
	guild_ids: Array<BigNumberish>;
	guild_count: BigNumberish;
}

// Type definition for `pwar::models::game::GameValue` struct
export interface GameValue {
	start: BigNumberish;
	end: BigNumberish;
	proposal_idx: BigNumberish;
	coeff_own_pixels: BigNumberish;
	coeff_commits: BigNumberish;
	winner_config: BigNumberish;
	winner: string;
	guild_ids: Array<BigNumberish>;
	guild_count: BigNumberish;
}

// Type definition for `pwar::models::guilds::Guild` struct
export interface Guild {
	game_id: BigNumberish;
	guild_id: BigNumberish;
	guild_name: BigNumberish;
	creator: string;
	members: Array<string>;
	member_count: BigNumberish;
}

// Type definition for `pwar::models::guilds::GuildValue` struct
export interface GuildValue {
	guild_name: BigNumberish;
	creator: string;
	members: Array<string>;
	member_count: BigNumberish;
}

// Type definition for `pwar::models::player::Player` struct
export interface Player {
	address: string;
	num_owns: BigNumberish;
	num_commit: BigNumberish;
	last_date: BigNumberish;
	is_banned: boolean;
}

// Type definition for `pwar::models::player::PlayerValue` struct
export interface PlayerValue {
	num_owns: BigNumberish;
	num_commit: BigNumberish;
	last_date: BigNumberish;
	is_banned: boolean;
}

// Type definition for `pwar::models::proposal::PixelRecoveryRate` struct
export interface PixelRecoveryRate {
	game_id: BigNumberish;
	rate: BigNumberish;
}

// Type definition for `pwar::models::proposal::PixelRecoveryRateValue` struct
export interface PixelRecoveryRateValue {
	rate: BigNumberish;
}

// Type definition for `pwar::models::proposal::PlayerVote` struct
export interface PlayerVote {
	player: string;
	game_id: BigNumberish;
	index: BigNumberish;
	is_in_favor: boolean;
	voting_power: BigNumberish;
}

// Type definition for `pwar::models::proposal::PlayerVoteValue` struct
export interface PlayerVoteValue {
	is_in_favor: boolean;
	voting_power: BigNumberish;
}

// Type definition for `pwar::models::proposal::Proposal` struct
export interface Proposal {
	game_id: BigNumberish;
	index: BigNumberish;
	author: string;
	proposal_type: BigNumberish;
	target_args_1: BigNumberish;
	target_args_2: BigNumberish;
	start: BigNumberish;
	end: BigNumberish;
	yes_voting_power: BigNumberish;
	no_voting_power: BigNumberish;
	is_activated: boolean;
}

// Type definition for `pwar::models::proposal::ProposalValue` struct
export interface ProposalValue {
	author: string;
	proposal_type: BigNumberish;
	target_args_1: BigNumberish;
	target_args_2: BigNumberish;
	start: BigNumberish;
	end: BigNumberish;
	yes_voting_power: BigNumberish;
	no_voting_power: BigNumberish;
	is_activated: boolean;
}

// Type definition for `pixelaw::core::events::QueueScheduled` struct
export interface QueueScheduled {
	id: BigNumberish;
	timestamp: BigNumberish;
	called_system: string;
	selector: BigNumberish;
	calldata: Array<BigNumberish>;
}

// Type definition for `pixelaw::core::events::QueueScheduledValue` struct
export interface QueueScheduledValue {
	timestamp: BigNumberish;
	called_system: string;
	selector: BigNumberish;
	calldata: Array<BigNumberish>;
}

// Type definition for `pwar::systems::actions::pwar_actions::EndedGame` struct
export interface EndedGame {
	id: BigNumberish;
	timestamp: BigNumberish;
}

// Type definition for `pwar::systems::actions::pwar_actions::EndedGameValue` struct
export interface EndedGameValue {
	timestamp: BigNumberish;
}

// Type definition for `pwar::systems::actions::pwar_actions::StartedGame` struct
export interface StartedGame {
	id: BigNumberish;
	timestamp: BigNumberish;
	creator: string;
}

// Type definition for `pwar::systems::actions::pwar_actions::StartedGameValue` struct
export interface StartedGameValue {
	timestamp: BigNumberish;
	creator: string;
}

// Type definition for `pwar::systems::guilds::guild_actions::GuildCreated` struct
export interface GuildCreated {
	game_id: BigNumberish;
	guild_id: BigNumberish;
	guild_name: BigNumberish;
	creator: string;
}

// Type definition for `pwar::systems::guilds::guild_actions::GuildCreatedValue` struct
export interface GuildCreatedValue {
	guild_id: BigNumberish;
	guild_name: BigNumberish;
	creator: string;
}

// Type definition for `pwar::systems::guilds::guild_actions::MemberAdded` struct
export interface MemberAdded {
	game_id: BigNumberish;
	guild_id: BigNumberish;
	member: string;
}

// Type definition for `pwar::systems::guilds::guild_actions::MemberAddedValue` struct
export interface MemberAddedValue {
	guild_id: BigNumberish;
	member: string;
}

// Type definition for `pwar::systems::guilds::guild_actions::MemberRemoved` struct
export interface MemberRemoved {
	game_id: BigNumberish;
	guild_id: BigNumberish;
	member: string;
}

// Type definition for `pwar::systems::guilds::guild_actions::MemberRemovedValue` struct
export interface MemberRemovedValue {
	guild_id: BigNumberish;
	member: string;
}

// Type definition for `pwar::systems::propose::propose_actions::ProposalActivated` struct
export interface ProposalActivated {
	game_id: BigNumberish;
	index: BigNumberish;
	proposal_type: BigNumberish;
	target_args_1: BigNumberish;
	target_args_2: BigNumberish;
}

// Type definition for `pwar::systems::propose::propose_actions::ProposalActivatedValue` struct
export interface ProposalActivatedValue {
	index: BigNumberish;
	proposal_type: BigNumberish;
	target_args_1: BigNumberish;
	target_args_2: BigNumberish;
}

// Type definition for `pwar::systems::propose::propose_actions::ProposalCreated` struct
export interface ProposalCreated {
	game_id: BigNumberish;
	index: BigNumberish;
	proposal_type: BigNumberish;
	target_args_1: BigNumberish;
	target_args_2: BigNumberish;
}

// Type definition for `pwar::systems::propose::propose_actions::ProposalCreatedValue` struct
export interface ProposalCreatedValue {
	index: BigNumberish;
	proposal_type: BigNumberish;
	target_args_1: BigNumberish;
	target_args_2: BigNumberish;
}

// Type definition for `pwar::systems::voting::voting_actions::Voted` struct
export interface Voted {
	game_id: BigNumberish;
	index: BigNumberish;
	timestamp: BigNumberish;
	voter: string;
	is_in_favor: boolean;
}

// Type definition for `pwar::systems::voting::voting_actions::VotedValue` struct
export interface VotedValue {
	index: BigNumberish;
	timestamp: BigNumberish;
	voter: string;
	is_in_favor: boolean;
}

export interface SchemaType extends ISchemaType {
	pixelaw: {
		Area: Area,
		AreaValue: AreaValue,
		RTree: RTree,
		RTreeValue: RTreeValue,
		Dummy: Dummy,
		DummyValue: DummyValue,
		Pixel: Pixel,
		PixelUpdate: PixelUpdate,
		PixelValue: PixelValue,
		QueueItem: QueueItem,
		QueueItemValue: QueueItemValue,
		App: App,
		AppName: AppName,
		AppNameValue: AppNameValue,
		AppValue: AppValue,
		CoreActionsAddress: CoreActionsAddress,
		CoreActionsAddressValue: CoreActionsAddressValue,
		Bounds: Bounds,
		DefaultParameters: DefaultParameters,
		Emoji: Emoji,
		Position: Position,
	},
	pwar: {
		AllowedColor: AllowedColor,
		AllowedColorValue: AllowedColorValue,
		GamePalette: GamePalette,
		GamePaletteValue: GamePaletteValue,
		InPalette: InPalette,
		InPaletteValue: InPaletteValue,
		PaletteColors: PaletteColors,
		PaletteColorsValue: PaletteColorsValue,
		Board: Board,
		BoardValue: BoardValue,
		GameId: GameId,
		GameIdValue: GameIdValue,
		PWarPixel: PWarPixel,
		PWarPixelValue: PWarPixelValue,
		Game: Game,
		GameValue: GameValue,
		Guild: Guild,
		GuildValue: GuildValue,
		Player: Player,
		PlayerValue: PlayerValue,
		PixelRecoveryRate: PixelRecoveryRate,
		PixelRecoveryRateValue: PixelRecoveryRateValue,
		PlayerVote: PlayerVote,
		PlayerVoteValue: PlayerVoteValue,
		Proposal: Proposal,
		ProposalValue: ProposalValue,
		QueueScheduled: QueueScheduled,
		QueueScheduledValue: QueueScheduledValue,
		EndedGame: EndedGame,
		EndedGameValue: EndedGameValue,
		StartedGame: StartedGame,
		StartedGameValue: StartedGameValue,
		GuildCreated: GuildCreated,
		GuildCreatedValue: GuildCreatedValue,
		MemberAdded: MemberAdded,
		MemberAddedValue: MemberAddedValue,
		MemberRemoved: MemberRemoved,
		MemberRemovedValue: MemberRemovedValue,
		ProposalActivated: ProposalActivated,
		ProposalActivatedValue: ProposalActivatedValue,
		ProposalCreated: ProposalCreated,
		ProposalCreatedValue: ProposalCreatedValue,
		Voted: Voted,
		VotedValue: VotedValue,
	},
}
export const schema: SchemaType = {
	pixelaw: {
		Area: {
			id: 0,
			app: "",
			owner: "",
			color: 0,
		},
		AreaValue: {
			app: "",
			owner: "",
			color: 0,
		},
		RTree: {
			id: 0,
			children: 0,
		},
		RTreeValue: {
			children: 0,
		},
		Dummy: {
			id: 0,
		defaultParams: { player_override: new CairoOption(CairoOptionVariant.None), system_override: new CairoOption(CairoOptionVariant.None), area_hint: new CairoOption(CairoOptionVariant.None), position: { x: 0, y: 0, }, color: 0, },
		bounds: { x_min: 0, y_min: 0, x_max: 0, y_max: 0, },
		pixelUpdate: { position: { x: 0, y: 0, }, color: new CairoOption(CairoOptionVariant.None), owner: new CairoOption(CairoOptionVariant.None), app: new CairoOption(CairoOptionVariant.None), text: new CairoOption(CairoOptionVariant.None), timestamp: new CairoOption(CairoOptionVariant.None), action: new CairoOption(CairoOptionVariant.None), },
		emoji: { value: 0, },
		},
		DummyValue: {
		defaultParams: { player_override: new CairoOption(CairoOptionVariant.None), system_override: new CairoOption(CairoOptionVariant.None), area_hint: new CairoOption(CairoOptionVariant.None), position: { x: 0, y: 0, }, color: 0, },
		bounds: { x_min: 0, y_min: 0, x_max: 0, y_max: 0, },
		pixelUpdate: { position: { x: 0, y: 0, }, color: new CairoOption(CairoOptionVariant.None), owner: new CairoOption(CairoOptionVariant.None), app: new CairoOption(CairoOptionVariant.None), text: new CairoOption(CairoOptionVariant.None), timestamp: new CairoOption(CairoOptionVariant.None), action: new CairoOption(CairoOptionVariant.None), },
		emoji: { value: 0, },
		},
		Pixel: {
		position: { x: 0, y: 0, },
			app: "",
			color: 0,
			created_at: 0,
			updated_at: 0,
			timestamp: 0,
			owner: "",
			text: 0,
			action: 0,
		},
		PixelUpdate: {
		position: { x: 0, y: 0, },
		color: new CairoOption(CairoOptionVariant.None),
		owner: new CairoOption(CairoOptionVariant.None),
		app: new CairoOption(CairoOptionVariant.None),
		text: new CairoOption(CairoOptionVariant.None),
		timestamp: new CairoOption(CairoOptionVariant.None),
		action: new CairoOption(CairoOptionVariant.None),
		},
		PixelValue: {
			app: "",
			color: 0,
			created_at: 0,
			updated_at: 0,
			timestamp: 0,
			owner: "",
			text: 0,
			action: 0,
		},
		QueueItem: {
			id: 0,
			valid: false,
		},
		QueueItemValue: {
			valid: false,
		},
		App: {
			system: "",
			name: 0,
			icon: 0,
			action: 0,
		},
		AppName: {
			name: 0,
			system: "",
		},
		AppNameValue: {
			system: "",
		},
		AppValue: {
			name: 0,
			icon: 0,
			action: 0,
		},
		CoreActionsAddress: {
			key: 0,
			value: "",
		},
		CoreActionsAddressValue: {
			value: "",
		},
		Bounds: {
			x_min: 0,
			y_min: 0,
			x_max: 0,
			y_max: 0,
		},
		DefaultParameters: {
		player_override: new CairoOption(CairoOptionVariant.None),
		system_override: new CairoOption(CairoOptionVariant.None),
		area_hint: new CairoOption(CairoOptionVariant.None),
		position: { x: 0, y: 0, },
			color: 0,
		},
		Emoji: {
			value: 0,
		},
		Position: {
			x: 0,
			y: 0,
		},
		AllowedColor: {
			game_id: 0,
			color: 0,
			is_allowed: false,
		},
		AllowedColorValue: {
			is_allowed: false,
		},
		GamePalette: {
			game_id: 0,
			length: 0,
		},
		GamePaletteValue: {
			length: 0,
		},
		InPalette: {
			game_id: 0,
			color: 0,
			value: false,
		},
		InPaletteValue: {
			value: false,
		},
		PaletteColors: {
			game_id: 0,
			idx: 0,
			color: 0,
		},
		PaletteColorsValue: {
			color: 0,
		},
		Board: {
			id: 0,
		origin: { x: 0, y: 0, },
			width: 0,
			height: 0,
		},
		BoardValue: {
		origin: { x: 0, y: 0, },
			width: 0,
			height: 0,
		},
		GameId: {
			x: 0,
			y: 0,
			value: 0,
		},
		GameIdValue: {
			value: 0,
		},
		PWarPixel: {
		position: { x: 0, y: 0, },
			owner: "",
		},
		PWarPixelValue: {
			owner: "",
		},
		Game: {
			id: 0,
			start: 0,
			end: 0,
			proposal_idx: 0,
			coeff_own_pixels: 0,
			coeff_commits: 0,
			winner_config: 0,
			winner: "",
			guild_ids: [0],
			guild_count: 0,
		},
		GameValue: {
			start: 0,
			end: 0,
			proposal_idx: 0,
			coeff_own_pixels: 0,
			coeff_commits: 0,
			winner_config: 0,
			winner: "",
			guild_ids: [0],
			guild_count: 0,
		},
		Guild: {
			game_id: 0,
			guild_id: 0,
			guild_name: 0,
			creator: "",
			members: [""],
			member_count: 0,
		},
		GuildValue: {
			guild_name: 0,
			creator: "",
			members: [""],
			member_count: 0,
		},
		Player: {
			address: "",
			num_owns: 0,
			num_commit: 0,
			last_date: 0,
			is_banned: false,
		},
		PlayerValue: {
			num_owns: 0,
			num_commit: 0,
			last_date: 0,
			is_banned: false,
		},
		PixelRecoveryRate: {
			game_id: 0,
			rate: 0,
		},
		PixelRecoveryRateValue: {
			rate: 0,
		},
		PlayerVote: {
			player: "",
			game_id: 0,
			index: 0,
			is_in_favor: false,
			voting_power: 0,
		},
		PlayerVoteValue: {
			is_in_favor: false,
			voting_power: 0,
		},
		Proposal: {
			game_id: 0,
			index: 0,
			author: "",
			proposal_type: 0,
			target_args_1: 0,
			target_args_2: 0,
			start: 0,
			end: 0,
			yes_voting_power: 0,
			no_voting_power: 0,
			is_activated: false,
		},
		ProposalValue: {
			author: "",
			proposal_type: 0,
			target_args_1: 0,
			target_args_2: 0,
			start: 0,
			end: 0,
			yes_voting_power: 0,
			no_voting_power: 0,
			is_activated: false,
		},
		QueueScheduled: {
			id: 0,
			timestamp: 0,
			called_system: "",
			selector: 0,
			calldata: [0],
		},
		QueueScheduledValue: {
			timestamp: 0,
			called_system: "",
			selector: 0,
			calldata: [0],
		},
		EndedGame: {
			id: 0,
			timestamp: 0,
		},
		EndedGameValue: {
			timestamp: 0,
		},
		StartedGame: {
			id: 0,
			timestamp: 0,
			creator: "",
		},
		StartedGameValue: {
			timestamp: 0,
			creator: "",
		},
		GuildCreated: {
			game_id: 0,
			guild_id: 0,
			guild_name: 0,
			creator: "",
		},
		GuildCreatedValue: {
			guild_id: 0,
			guild_name: 0,
			creator: "",
		},
		MemberAdded: {
			game_id: 0,
			guild_id: 0,
			member: "",
		},
		MemberAddedValue: {
			guild_id: 0,
			member: "",
		},
		MemberRemoved: {
			game_id: 0,
			guild_id: 0,
			member: "",
		},
		MemberRemovedValue: {
			guild_id: 0,
			member: "",
		},
		ProposalActivated: {
			game_id: 0,
			index: 0,
			proposal_type: 0,
			target_args_1: 0,
			target_args_2: 0,
		},
		ProposalActivatedValue: {
			index: 0,
			proposal_type: 0,
			target_args_1: 0,
			target_args_2: 0,
		},
		ProposalCreated: {
			game_id: 0,
			index: 0,
			proposal_type: 0,
			target_args_1: 0,
			target_args_2: 0,
		},
		ProposalCreatedValue: {
			index: 0,
			proposal_type: 0,
			target_args_1: 0,
			target_args_2: 0,
		},
		Voted: {
			game_id: 0,
			index: 0,
			timestamp: 0,
			voter: "",
			is_in_favor: false,
		},
		VotedValue: {
			index: 0,
			timestamp: 0,
			voter: "",
			is_in_favor: false,
		},
	},
};
export enum ModelsMapping {
	Area = 'pixelaw-Area',
	AreaValue = 'pixelaw-AreaValue',
	RTree = 'pixelaw-RTree',
	RTreeValue = 'pixelaw-RTreeValue',
	Dummy = 'pixelaw-Dummy',
	DummyValue = 'pixelaw-DummyValue',
	Pixel = 'pixelaw-Pixel',
	PixelUpdate = 'pixelaw-PixelUpdate',
	PixelValue = 'pixelaw-PixelValue',
	QueueItem = 'pixelaw-QueueItem',
	QueueItemValue = 'pixelaw-QueueItemValue',
	App = 'pixelaw-App',
	AppName = 'pixelaw-AppName',
	AppNameValue = 'pixelaw-AppNameValue',
	AppValue = 'pixelaw-AppValue',
	CoreActionsAddress = 'pixelaw-CoreActionsAddress',
	CoreActionsAddressValue = 'pixelaw-CoreActionsAddressValue',
	Bounds = 'pixelaw-Bounds',
	DefaultParameters = 'pixelaw-DefaultParameters',
	Emoji = 'pixelaw-Emoji',
	Position = 'pixelaw-Position',
	AllowedColor = 'pwar-AllowedColor',
	AllowedColorValue = 'pwar-AllowedColorValue',
	GamePalette = 'pwar-GamePalette',
	GamePaletteValue = 'pwar-GamePaletteValue',
	InPalette = 'pwar-InPalette',
	InPaletteValue = 'pwar-InPaletteValue',
	PaletteColors = 'pwar-PaletteColors',
	PaletteColorsValue = 'pwar-PaletteColorsValue',
	Board = 'pwar-Board',
	BoardValue = 'pwar-BoardValue',
	GameId = 'pwar-GameId',
	GameIdValue = 'pwar-GameIdValue',
	PWarPixel = 'pwar-PWarPixel',
	PWarPixelValue = 'pwar-PWarPixelValue',
	Game = 'pwar-Game',
	GameValue = 'pwar-GameValue',
	Guild = 'pwar-Guild',
	GuildValue = 'pwar-GuildValue',
	Player = 'pwar-Player',
	PlayerValue = 'pwar-PlayerValue',
	PixelRecoveryRate = 'pwar-PixelRecoveryRate',
	PixelRecoveryRateValue = 'pwar-PixelRecoveryRateValue',
	PlayerVote = 'pwar-PlayerVote',
	PlayerVoteValue = 'pwar-PlayerVoteValue',
	Proposal = 'pwar-Proposal',
	ProposalValue = 'pwar-ProposalValue',
	QueueScheduled = 'pixelaw-QueueScheduled',
	QueueScheduledValue = 'pixelaw-QueueScheduledValue',
	EndedGame = 'pwar-EndedGame',
	EndedGameValue = 'pwar-EndedGameValue',
	StartedGame = 'pwar-StartedGame',
	StartedGameValue = 'pwar-StartedGameValue',
	GuildCreated = 'pwar-GuildCreated',
	GuildCreatedValue = 'pwar-GuildCreatedValue',
	MemberAdded = 'pwar-MemberAdded',
	MemberAddedValue = 'pwar-MemberAddedValue',
	MemberRemoved = 'pwar-MemberRemoved',
	MemberRemovedValue = 'pwar-MemberRemovedValue',
	ProposalActivated = 'pwar-ProposalActivated',
	ProposalActivatedValue = 'pwar-ProposalActivatedValue',
	ProposalCreated = 'pwar-ProposalCreated',
	ProposalCreatedValue = 'pwar-ProposalCreatedValue',
	Voted = 'pwar-Voted',
	VotedValue = 'pwar-VotedValue',
}