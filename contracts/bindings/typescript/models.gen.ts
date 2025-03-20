import type { SchemaType as ISchemaType } from "@dojoengine/sdk";

import { BigNumberish } from 'starknet';

// Type definition for `p_war::models::allowed_app::AllowedApp` struct
export interface AllowedApp {
	game_id: BigNumberish;
	contract: string;
	is_allowed: boolean;
}

// Type definition for `p_war::models::allowed_app::AllowedAppValue` struct
export interface AllowedAppValue {
	is_allowed: boolean;
}

// Type definition for `p_war::models::allowed_color::AllowedColor` struct
export interface AllowedColor {
	game_id: BigNumberish;
	color: BigNumberish;
	is_allowed: boolean;
}

// Type definition for `p_war::models::allowed_color::AllowedColorValue` struct
export interface AllowedColorValue {
	is_allowed: boolean;
}

// Type definition for `p_war::models::allowed_color::GamePalette` struct
export interface GamePalette {
	game_id: BigNumberish;
	length: BigNumberish;
}

// Type definition for `p_war::models::allowed_color::GamePaletteValue` struct
export interface GamePaletteValue {
	length: BigNumberish;
}

// Type definition for `p_war::models::allowed_color::InPalette` struct
export interface InPalette {
	game_id: BigNumberish;
	color: BigNumberish;
	value: boolean;
}

// Type definition for `p_war::models::allowed_color::InPaletteValue` struct
export interface InPaletteValue {
	value: boolean;
}

// Type definition for `p_war::models::allowed_color::PaletteColors` struct
export interface PaletteColors {
	game_id: BigNumberish;
	idx: BigNumberish;
	color: BigNumberish;
}

// Type definition for `p_war::models::allowed_color::PaletteColorsValue` struct
export interface PaletteColorsValue {
	color: BigNumberish;
}

// Type definition for `p_war::models::board::Board` struct
export interface Board {
	id: BigNumberish;
	origin: Position;
	width: BigNumberish;
	height: BigNumberish;
}

// Type definition for `p_war::models::board::BoardValue` struct
export interface BoardValue {
	origin: Position;
	width: BigNumberish;
	height: BigNumberish;
}

// Type definition for `p_war::models::board::GameId` struct
export interface GameId {
	x: BigNumberish;
	y: BigNumberish;
	value: BigNumberish;
}

// Type definition for `p_war::models::board::GameIdValue` struct
export interface GameIdValue {
	value: BigNumberish;
}

// Type definition for `p_war::models::board::PWarPixel` struct
export interface PWarPixel {
	position: Position;
	owner: string;
}

// Type definition for `p_war::models::board::PWarPixelValue` struct
export interface PWarPixelValue {
	owner: string;
}

// Type definition for `p_war::models::game::Game` struct
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

// Type definition for `p_war::models::game::GameValue` struct
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

// Type definition for `p_war::models::guilds::Guild` struct
export interface Guild {
	game_id: BigNumberish;
	guild_id: BigNumberish;
	guild_name: BigNumberish;
	creator: string;
	members: Array<string>;
	member_count: BigNumberish;
}

// Type definition for `p_war::models::guilds::GuildValue` struct
export interface GuildValue {
	guild_name: BigNumberish;
	creator: string;
	members: Array<string>;
	member_count: BigNumberish;
}

// Type definition for `p_war::models::player::Player` struct
export interface Player {
	address: string;
	num_owns: BigNumberish;
	num_commit: BigNumberish;
	last_date: BigNumberish;
	is_banned: boolean;
}

// Type definition for `p_war::models::player::PlayerValue` struct
export interface PlayerValue {
	num_owns: BigNumberish;
	num_commit: BigNumberish;
	last_date: BigNumberish;
	is_banned: boolean;
}

// Type definition for `p_war::models::proposal::PixelRecoveryRate` struct
export interface PixelRecoveryRate {
	game_id: BigNumberish;
	rate: BigNumberish;
}

// Type definition for `p_war::models::proposal::PixelRecoveryRateValue` struct
export interface PixelRecoveryRateValue {
	rate: BigNumberish;
}

// Type definition for `p_war::models::proposal::PlayerVote` struct
export interface PlayerVote {
	player: string;
	game_id: BigNumberish;
	index: BigNumberish;
	is_in_favor: boolean;
	voting_power: BigNumberish;
}

// Type definition for `p_war::models::proposal::PlayerVoteValue` struct
export interface PlayerVoteValue {
	is_in_favor: boolean;
	voting_power: BigNumberish;
}

// Type definition for `p_war::models::proposal::Proposal` struct
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

// Type definition for `p_war::models::proposal::ProposalValue` struct
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

// Type definition for `pixelaw::core::utils::Position` struct
export interface Position {
	x: BigNumberish;
	y: BigNumberish;
}

// Type definition for `p_war::systems::actions::p_war_actions::EndedGame` struct
export interface EndedGame {
	id: BigNumberish;
	timestamp: BigNumberish;
}

// Type definition for `p_war::systems::actions::p_war_actions::EndedGameValue` struct
export interface EndedGameValue {
	timestamp: BigNumberish;
}

// Type definition for `p_war::systems::actions::p_war_actions::StartedGame` struct
export interface StartedGame {
	id: BigNumberish;
	timestamp: BigNumberish;
	creator: string;
}

// Type definition for `p_war::systems::actions::p_war_actions::StartedGameValue` struct
export interface StartedGameValue {
	timestamp: BigNumberish;
	creator: string;
}

// Type definition for `p_war::systems::guilds::guild_actions::GuildCreated` struct
export interface GuildCreated {
	game_id: BigNumberish;
	guild_id: BigNumberish;
	guild_name: BigNumberish;
	creator: string;
}

// Type definition for `p_war::systems::guilds::guild_actions::GuildCreatedValue` struct
export interface GuildCreatedValue {
	guild_id: BigNumberish;
	guild_name: BigNumberish;
	creator: string;
}

// Type definition for `p_war::systems::guilds::guild_actions::MemberAdded` struct
export interface MemberAdded {
	game_id: BigNumberish;
	guild_id: BigNumberish;
	member: string;
}

// Type definition for `p_war::systems::guilds::guild_actions::MemberAddedValue` struct
export interface MemberAddedValue {
	guild_id: BigNumberish;
	member: string;
}

// Type definition for `p_war::systems::guilds::guild_actions::MemberRemoved` struct
export interface MemberRemoved {
	game_id: BigNumberish;
	guild_id: BigNumberish;
	member: string;
}

// Type definition for `p_war::systems::guilds::guild_actions::MemberRemovedValue` struct
export interface MemberRemovedValue {
	guild_id: BigNumberish;
	member: string;
}

// Type definition for `p_war::systems::propose::propose_actions::ProposalActivated` struct
export interface ProposalActivated {
	game_id: BigNumberish;
	index: BigNumberish;
	proposal_type: BigNumberish;
	target_args_1: BigNumberish;
	target_args_2: BigNumberish;
}

// Type definition for `p_war::systems::propose::propose_actions::ProposalActivatedValue` struct
export interface ProposalActivatedValue {
	index: BigNumberish;
	proposal_type: BigNumberish;
	target_args_1: BigNumberish;
	target_args_2: BigNumberish;
}

// Type definition for `p_war::systems::propose::propose_actions::ProposalCreated` struct
export interface ProposalCreated {
	game_id: BigNumberish;
	index: BigNumberish;
	proposal_type: BigNumberish;
	target_args_1: BigNumberish;
	target_args_2: BigNumberish;
}

// Type definition for `p_war::systems::propose::propose_actions::ProposalCreatedValue` struct
export interface ProposalCreatedValue {
	index: BigNumberish;
	proposal_type: BigNumberish;
	target_args_1: BigNumberish;
	target_args_2: BigNumberish;
}

// Type definition for `p_war::systems::voting::voting_actions::Voted` struct
export interface Voted {
	game_id: BigNumberish;
	index: BigNumberish;
	timestamp: BigNumberish;
	voter: string;
	is_in_favor: boolean;
}

// Type definition for `p_war::systems::voting::voting_actions::VotedValue` struct
export interface VotedValue {
	index: BigNumberish;
	timestamp: BigNumberish;
	voter: string;
	is_in_favor: boolean;
}

export interface SchemaType extends ISchemaType {
	p_war: {
		AllowedApp: AllowedApp,
		AllowedAppValue: AllowedAppValue,
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
	},
	pixelaw: {
		Position: Position,
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
	p_war: {
		AllowedApp: {
			game_id: 0,
			contract: "",
			is_allowed: false,
		},
		AllowedAppValue: {
			is_allowed: false,
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
		Position: {
			x: 0,
			y: 0,
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
	AllowedApp = 'p_war-AllowedApp',
	AllowedAppValue = 'p_war-AllowedAppValue',
	AllowedColor = 'p_war-AllowedColor',
	AllowedColorValue = 'p_war-AllowedColorValue',
	GamePalette = 'p_war-GamePalette',
	GamePaletteValue = 'p_war-GamePaletteValue',
	InPalette = 'p_war-InPalette',
	InPaletteValue = 'p_war-InPaletteValue',
	PaletteColors = 'p_war-PaletteColors',
	PaletteColorsValue = 'p_war-PaletteColorsValue',
	Board = 'p_war-Board',
	BoardValue = 'p_war-BoardValue',
	GameId = 'p_war-GameId',
	GameIdValue = 'p_war-GameIdValue',
	PWarPixel = 'p_war-PWarPixel',
	PWarPixelValue = 'p_war-PWarPixelValue',
	Game = 'p_war-Game',
	GameValue = 'p_war-GameValue',
	Guild = 'p_war-Guild',
	GuildValue = 'p_war-GuildValue',
	Player = 'p_war-Player',
	PlayerValue = 'p_war-PlayerValue',
	PixelRecoveryRate = 'p_war-PixelRecoveryRate',
	PixelRecoveryRateValue = 'p_war-PixelRecoveryRateValue',
	PlayerVote = 'p_war-PlayerVote',
	PlayerVoteValue = 'p_war-PlayerVoteValue',
	Proposal = 'p_war-Proposal',
	ProposalValue = 'p_war-ProposalValue',
	Position = 'pixelaw-Position',
	EndedGame = 'p_war-EndedGame',
	EndedGameValue = 'p_war-EndedGameValue',
	StartedGame = 'p_war-StartedGame',
	StartedGameValue = 'p_war-StartedGameValue',
	GuildCreated = 'p_war-GuildCreated',
	GuildCreatedValue = 'p_war-GuildCreatedValue',
	MemberAdded = 'p_war-MemberAdded',
	MemberAddedValue = 'p_war-MemberAddedValue',
	MemberRemoved = 'p_war-MemberRemoved',
	MemberRemovedValue = 'p_war-MemberRemovedValue',
	ProposalActivated = 'p_war-ProposalActivated',
	ProposalActivatedValue = 'p_war-ProposalActivatedValue',
	ProposalCreated = 'p_war-ProposalCreated',
	ProposalCreatedValue = 'p_war-ProposalCreatedValue',
	Voted = 'p_war-Voted',
	VotedValue = 'p_war-VotedValue',
}