// Generated by dojo-bindgen on Tue, 24 Sep 2024 21:20:34 +0000. Do not modify this file manually.
// Import the necessary types from the recs SDK
// generate again with `sozo build --typescript`
import { defineComponent, Type as RecsType, World } from "@dojoengine/recs";

export type ContractComponents = Awaited<ReturnType<typeof defineContractComponents>>;

// Type definition for `dojo::model::layout::Layout` enum
export type Layout =
  | { type: "Fixed"; value: RecsType.NumberArray }
  | { type: "Struct"; value: RecsType.StringArray }
  | { type: "Tuple"; value: RecsType.StringArray }
  | { type: "Array"; value: RecsType.StringArray }
  | { type: "ByteArray" }
  | { type: "Enum"; value: RecsType.StringArray };

export const LayoutDefinition = {
  type: RecsType.String,
  value: RecsType.String,
};

// Type definition for `p_war::models::allowed_app::AllowedApp` struct
export interface AllowedApp {
  game_id: number;
  contract: bigint;
  is_allowed: boolean;
}
export const AllowedAppDefinition = {
  game_id: RecsType.Number,
  contract: RecsType.BigInt,
  is_allowed: RecsType.Boolean,
};

// Type definition for `core::byte_array::ByteArray` struct
export interface ByteArray {
  data: string[];
  pending_word: bigint;
  pending_word_len: number;
}
export const ByteArrayDefinition = {
  data: RecsType.StringArray,
  pending_word: RecsType.BigInt,
  pending_word_len: RecsType.Number,
};

// Type definition for `dojo::model::layout::FieldLayout` struct
export interface FieldLayout {
  selector: bigint;
  layout: Layout;
}
export const FieldLayoutDefinition = {
  selector: RecsType.BigInt,
  layout: LayoutDefinition,
};

// Type definition for `p_war::models::allowed_color::AllowedColor` struct
export interface AllowedColor {
  game_id: number;
  color: number;
  is_allowed: boolean;
}
export const AllowedColorDefinition = {
  game_id: RecsType.Number,
  color: RecsType.Number,
  is_allowed: RecsType.Boolean,
};

// Type definition for `pixelaw::core::models::registry::App` struct
export interface App {
  system: bigint;
  name: bigint;
  icon: bigint;
  action: bigint;
}
export const AppDefinition = {
  system: RecsType.BigInt,
  name: RecsType.BigInt,
  icon: RecsType.BigInt,
  action: RecsType.BigInt,
};

// Type definition for `pixelaw::core::models::registry::AppName` struct
export interface AppName {
  name: bigint;
  system: bigint;
}
export const AppNameDefinition = {
  name: RecsType.BigInt,
  system: RecsType.BigInt,
};

// Type definition for `pixelaw::core::models::registry::AppUser` struct
export interface AppUser {
  system: bigint;
  player: bigint;
  action: bigint;
}
export const AppUserDefinition = {
  system: RecsType.BigInt,
  player: RecsType.BigInt,
  action: RecsType.BigInt,
};

// Type definition for `pixelaw::core::utils::Position` struct
export interface Position {
  x: number;
  y: number;
}
export const PositionDefinition = {
  x: RecsType.Number,
  y: RecsType.Number,
};

// Type definition for `p_war::models::board::Board` struct
export interface Board {
  id: number;
  origin: Position;
  width: number;
  height: number;
}
export const BoardDefinition = {
  id: RecsType.Number,
  origin: PositionDefinition,
  width: RecsType.Number,
  height: RecsType.Number,
};

// Type definition for `pixelaw::core::models::registry::CoreActionsAddress` struct
export interface CoreActionsAddress {
  key: bigint;
  value: bigint;
}
export const CoreActionsAddressDefinition = {
  key: RecsType.BigInt,
  value: RecsType.BigInt,
};

// Type definition for `p_war::models::game::Game` struct
export interface Game {
  id: number;
  start: number;
  end: number;
  proposal_idx: number;
  coeff_own_pixels: number;
  coeff_commits: number;
  winner_config: number;
  winner: bigint;
  guild_ids: number[];
  guild_count: number;
}
export const GameDefinition = {
  id: RecsType.Number,
  start: RecsType.Number,
  end: RecsType.Number,
  proposal_idx: RecsType.Number,
  coeff_own_pixels: RecsType.Number,
  coeff_commits: RecsType.Number,
  winner_config: RecsType.Number,
  winner: RecsType.BigInt,
  guild_ids: RecsType.NumberArray,
  guild_count: RecsType.Number,
};

// Type definition for `p_war::models::board::GameId` struct
export interface GameId {
  x: number;
  y: number;
  value: number;
}
export const GameIdDefinition = {
  x: RecsType.Number,
  y: RecsType.Number,
  value: RecsType.Number,
};

// Type definition for `p_war::models::allowed_color::GamePalette` struct
export interface GamePalette {
  game_id: number;
  length: number;
}
export const GamePaletteDefinition = {
  game_id: RecsType.Number,
  length: RecsType.Number,
};

// Type definition for `p_war::models::guilds::Guild` struct
export interface Guild {
  game_id: number;
  guild_id: number;
  guild_name: bigint;
  creator: bigint;
  members: bigint[];
  member_count: number;
}
export const GuildDefinition = {
  game_id: RecsType.Number,
  guild_id: RecsType.Number,
  guild_name: RecsType.BigInt,
  creator: RecsType.BigInt,
  members: RecsType.BigIntArray,
  member_count: RecsType.Number,
};

// Type definition for `p_war::models::allowed_color::InPalette` struct
export interface InPalette {
  game_id: number;
  color: number;
  value: boolean;
}
export const InPaletteDefinition = {
  game_id: RecsType.Number,
  color: RecsType.Number,
  value: RecsType.Boolean,
};

// Type definition for `pixelaw::core::models::registry::Instruction` struct
export interface Instruction {
  system: bigint;
  selector: bigint;
  instruction: bigint;
}
export const InstructionDefinition = {
  system: RecsType.BigInt,
  selector: RecsType.BigInt,
  instruction: RecsType.BigInt,
};

// Type definition for `p_war::models::board::PWarPixel` struct
export interface PWarPixel {
  position: Position;
  owner: bigint;
}
export const PWarPixelDefinition = {
  position: PositionDefinition,
  owner: RecsType.BigInt,
};

// Type definition for `p_war::models::allowed_color::PaletteColors` struct
export interface PaletteColors {
  game_id: number;
  idx: number;
  color: number;
}
export const PaletteColorsDefinition = {
  game_id: RecsType.Number,
  idx: RecsType.Number,
  color: RecsType.Number,
};

// Type definition for `pixelaw::core::models::permissions::Permission` struct
export interface Permission {
  app: boolean;
  color: boolean;
  owner: boolean;
  text: boolean;
  timestamp: boolean;
  action: boolean;
}
export const PermissionDefinition = {
  app: RecsType.Boolean,
  color: RecsType.Boolean,
  owner: RecsType.Boolean,
  text: RecsType.Boolean,
  timestamp: RecsType.Boolean,
  action: RecsType.Boolean,
};

// Type definition for `pixelaw::core::models::permissions::Permissions` struct
export interface Permissions {
  allowing_app: bigint;
  allowed_app: bigint;
  permission: Permission;
}
export const PermissionsDefinition = {
  allowing_app: RecsType.BigInt,
  allowed_app: RecsType.BigInt,
  permission: PermissionDefinition,
};

// Type definition for `pixelaw::core::models::pixel::Pixel` struct
export interface Pixel {
  x: number;
  y: number;
  app: bigint;
  color: number;
  created_at: number;
  updated_at: number;
  timestamp: number;
  owner: bigint;
  text: bigint;
  action: bigint;
}
export const PixelDefinition = {
  x: RecsType.Number,
  y: RecsType.Number,
  app: RecsType.BigInt,
  color: RecsType.Number,
  created_at: RecsType.Number,
  updated_at: RecsType.Number,
  timestamp: RecsType.Number,
  owner: RecsType.BigInt,
  text: RecsType.BigInt,
  action: RecsType.BigInt,
};

export interface PixelUpdate {
  x: number;
  y: number;
  color?: number;
  owner?: bigint;
  app?: bigint;
  text?: bigint;
  timestamp?: number;
  action?: bigint;
}
export const PixelUpdateDefinition = {
  x: RecsType.Number,
  y: RecsType.Number,
  color: RecsType.OptionalNumber,
  owner: RecsType.OptionalBigInt,
  app: RecsType.OptionalBigInt,
  text: RecsType.OptionalBigInt,
  timestamp: RecsType.OptionalNumber,
  action: RecsType.OptionalBigInt,
};

// Type definition for `p_war::models::proposal::PixelRecoveryRate` struct
export interface PixelRecoveryRate {
  game_id: number;
  rate: number;
}
export const PixelRecoveryRateDefinition = {
  game_id: RecsType.Number,
  rate: RecsType.Number,
};

// Type definition for `p_war::models::player::Player` struct
export interface Player {
  address: bigint;
  num_owns: number;
  num_commit: number;
  last_date: number;
  is_banned: boolean;
}
export const PlayerDefinition = {
  address: RecsType.BigInt,
  num_owns: RecsType.Number,
  num_commit: RecsType.Number,
  last_date: RecsType.Number,
  is_banned: RecsType.Boolean,
};

// Type definition for `p_war::models::proposal::PlayerVote` struct
export interface PlayerVote {
  player: bigint;
  game_id: number;
  index: number;
  is_in_favor: boolean;
  voting_power: number;
}
export const PlayerVoteDefinition = {
  player: RecsType.BigInt,
  game_id: RecsType.Number,
  index: RecsType.Number,
  is_in_favor: RecsType.Boolean,
  voting_power: RecsType.Number,
};

// Type definition for `p_war::models::proposal::Proposal` struct
export interface Proposal {
  game_id: number;
  index: number;
  author: bigint;
  proposal_type: number;
  target_args_1: number;
  target_args_2: number;
  start: number;
  end: number;
  yes_voting_power: number;
  no_voting_power: number;
  is_activated: boolean;
}
export const ProposalDefinition = {
  game_id: RecsType.Number,
  index: RecsType.Number,
  author: RecsType.BigInt,
  proposal_type: RecsType.Number,
  target_args_1: RecsType.Number,
  target_args_2: RecsType.Number,
  start: RecsType.Number,
  end: RecsType.Number,
  yes_voting_power: RecsType.Number,
  no_voting_power: RecsType.Number,
  is_activated: RecsType.Boolean,
};

// Type definition for `pixelaw::core::models::queue::QueueItem` struct
export interface QueueItem {
  id: bigint;
  valid: boolean;
}
export const QueueItemDefinition = {
  id: RecsType.BigInt,
  valid: RecsType.Boolean,
};

// Type definition for `DefaultParameters` struct
export interface DefaultParameters {
  for_player: bigint;
  for_system: bigint;
  position: Position;
  color: number;
}

export const DefaultParametersDefinition = {
  for_player: RecsType.BigInt,
  for_system: RecsType.BigInt,
  position: PositionDefinition,
  color: RecsType.Number,
};

export function defineContractComponents(world: World) {
  return {
    // Model definition for `p_war::models::allowed_app::AllowedApp` model
    AllowedApp: (() => {
      return defineComponent(
        world,
        {
          game_id: RecsType.Number,
          contract: RecsType.BigInt,
          is_allowed: RecsType.Boolean,
        },
        {
          metadata: {
            namespace: "pixelaw",
            name: "AllowedApp",
            types: ["u32", "ContractAddress", "bool"],
            customTypes: [],
          },
        },
      );
    })(),

    // Model definition for `p_war::models::allowed_color::AllowedColor` model
    AllowedColor: (() => {
      return defineComponent(
        world,
        {
          game_id: RecsType.Number,
          color: RecsType.Number,
          is_allowed: RecsType.Boolean,
        },
        {
          metadata: {
            namespace: "pixelaw",
            name: "AllowedColor",
            types: ["u32", "u32", "bool"],
            customTypes: [],
          },
        },
      );
    })(),

    // Model definition for `pixelaw::core::models::registry::App` model
    App: (() => {
      return defineComponent(
        world,
        {
          system: RecsType.BigInt,
          name: RecsType.BigInt,
          icon: RecsType.BigInt,
          action: RecsType.BigInt,
        },
        {
          metadata: {
            namespace: "pixelaw",
            name: "App",
            types: ["ContractAddress", "felt252", "felt252", "felt252"],
            customTypes: [],
          },
        },
      );
    })(),

    // Model definition for `pixelaw::core::models::registry::AppName` model
    AppName: (() => {
      return defineComponent(
        world,
        {
          name: RecsType.BigInt,
          system: RecsType.BigInt,
        },
        {
          metadata: {
            namespace: "pixelaw",
            name: "AppName",
            types: ["felt252", "ContractAddress"],
            customTypes: [],
          },
        },
      );
    })(),

    // Model definition for `pixelaw::core::models::registry::AppUser` model
    AppUser: (() => {
      return defineComponent(
        world,
        {
          system: RecsType.BigInt,
          player: RecsType.BigInt,
          action: RecsType.BigInt,
        },
        {
          metadata: {
            namespace: "pixelaw",
            name: "AppUser",
            types: ["ContractAddress", "ContractAddress", "felt252"],
            customTypes: [],
          },
        },
      );
    })(),

    // Model definition for `p_war::models::board::Board` model
    Board: (() => {
      return defineComponent(
        world,
        {
          id: RecsType.Number,
          origin: PositionDefinition,
          width: RecsType.Number,
          height: RecsType.Number,
        },
        {
          metadata: {
            namespace: "pixelaw",
            name: "Board",
            types: ["u32", "u32", "u32"],
            customTypes: ["Position"],
          },
        },
      );
    })(),

    // Model definition for `pixelaw::core::models::registry::CoreActionsAddress` model
    CoreActionsAddress: (() => {
      return defineComponent(
        world,
        {
          key: RecsType.BigInt,
          value: RecsType.BigInt,
        },
        {
          metadata: {
            namespace: "pixelaw",
            name: "CoreActionsAddress",
            types: ["felt252", "ContractAddress"],
            customTypes: [],
          },
        },
      );
    })(),

    // Model definition for `p_war::models::game::Game` model
    Game: (() => {
      return defineComponent(
        world,
        {
          id: RecsType.Number,
          start: RecsType.Number,
          end: RecsType.Number,
          proposal_idx: RecsType.Number,
          coeff_own_pixels: RecsType.Number,
          coeff_commits: RecsType.Number,
          winner_config: RecsType.Number,
          winner: RecsType.BigInt,
          guild_ids: RecsType.NumberArray,
          guild_count: RecsType.Number,
        },
        {
          metadata: {
            namespace: "pixelaw",
            name: "Game",
            types: ["u32", "u64", "u64", "u32", "u32", "u32", "u32", "ContractAddress", "array", "u32"],
            customTypes: [],
          },
        },
      );
    })(),

    // Model definition for `p_war::models::board::GameId` model
    GameId: (() => {
      return defineComponent(
        world,
        {
          x: RecsType.Number,
          y: RecsType.Number,
          value: RecsType.Number,
        },
        {
          metadata: {
            namespace: "pixelaw",
            name: "GameId",
            types: ["u32", "u32", "u32"],
            customTypes: [],
          },
        },
      );
    })(),

    // Model definition for `p_war::models::allowed_color::GamePalette` model
    GamePalette: (() => {
      return defineComponent(
        world,
        {
          game_id: RecsType.Number,
          length: RecsType.Number,
        },
        {
          metadata: {
            namespace: "pixelaw",
            name: "GamePalette",
            types: ["u32", "u32"],
            customTypes: [],
          },
        },
      );
    })(),

    // Model definition for `p_war::models::guilds::Guild` model
    Guild: (() => {
      return defineComponent(
        world,
        {
          game_id: RecsType.Number,
          guild_id: RecsType.Number,
          guild_name: RecsType.BigInt,
          creator: RecsType.BigInt,
          members: RecsType.BigIntArray,
          member_count: RecsType.Number,
        },
        {
          metadata: {
            namespace: "pixelaw",
            name: "Guild",
            types: ["u32", "u32", "felt252", "ContractAddress", "array", "u32"],
            customTypes: [],
          },
        },
      );
    })(),

    // Model definition for `p_war::models::allowed_color::InPalette` model
    InPalette: (() => {
      return defineComponent(
        world,
        {
          game_id: RecsType.Number,
          color: RecsType.Number,
          value: RecsType.Boolean,
        },
        {
          metadata: {
            namespace: "pixelaw",
            name: "InPalette",
            types: ["u32", "u32", "bool"],
            customTypes: [],
          },
        },
      );
    })(),

    // Model definition for `pixelaw::core::models::registry::Instruction` model
    Instruction: (() => {
      return defineComponent(
        world,
        {
          system: RecsType.BigInt,
          selector: RecsType.BigInt,
          instruction: RecsType.BigInt,
        },
        {
          metadata: {
            namespace: "pixelaw",
            name: "Instruction",
            types: ["ContractAddress", "felt252", "felt252"],
            customTypes: [],
          },
        },
      );
    })(),

    // Model definition for `p_war::models::board::PWarPixel` model
    PWarPixel: (() => {
      return defineComponent(
        world,
        {
          position: PositionDefinition,
          owner: RecsType.BigInt,
        },
        {
          metadata: {
            namespace: "pixelaw",
            name: "PWarPixel",
            types: ["ContractAddress"],
            customTypes: ["Position"],
          },
        },
      );
    })(),

    // Model definition for `p_war::models::allowed_color::PaletteColors` model
    PaletteColors: (() => {
      return defineComponent(
        world,
        {
          game_id: RecsType.Number,
          idx: RecsType.Number,
          color: RecsType.Number,
        },
        {
          metadata: {
            namespace: "pixelaw",
            name: "PaletteColors",
            types: ["u32", "u32", "u32"],
            customTypes: [],
          },
        },
      );
    })(),

    // Model definition for `pixelaw::core::models::permissions::Permissions` model
    Permissions: (() => {
      return defineComponent(
        world,
        {
          allowing_app: RecsType.BigInt,
          allowed_app: RecsType.BigInt,
          permission: PermissionDefinition,
        },
        {
          metadata: {
            namespace: "pixelaw",
            name: "Permissions",
            types: ["ContractAddress", "ContractAddress"],
            customTypes: ["Permission"],
          },
        },
      );
    })(),

    // Model definition for `pixelaw::core::models::pixel::Pixel` model
    Pixel: (() => {
      return defineComponent(
        world,
        {
          x: RecsType.Number,
          y: RecsType.Number,
          app: RecsType.BigInt,
          color: RecsType.Number,
          created_at: RecsType.Number,
          updated_at: RecsType.Number,
          timestamp: RecsType.Number,
          owner: RecsType.BigInt,
          text: RecsType.BigInt,
          action: RecsType.BigInt,
        },
        {
          metadata: {
            namespace: "pixelaw",
            name: "Pixel",
            types: [
              "u32",
              "u32",
              "ContractAddress",
              "u32",
              "u64",
              "u64",
              "u64",
              "ContractAddress",
              "felt252",
              "felt252",
            ],
            customTypes: [],
          },
        },
      );
    })(),

    // Model definition for `p_war::models::proposal::PixelRecoveryRate` model
    PixelRecoveryRate: (() => {
      return defineComponent(
        world,
        {
          game_id: RecsType.Number,
          rate: RecsType.Number,
        },
        {
          metadata: {
            namespace: "pixelaw",
            name: "PixelRecoveryRate",
            types: ["u32", "u64"],
            customTypes: [],
          },
        },
      );
    })(),

    // Model definition for `p_war::models::player::Player` model
    Player: (() => {
      return defineComponent(
        world,
        {
          address: RecsType.BigInt,
          num_owns: RecsType.Number,
          num_commit: RecsType.Number,
          last_date: RecsType.Number,
          is_banned: RecsType.Boolean,
        },
        {
          metadata: {
            namespace: "pixelaw",
            name: "Player",
            types: ["ContractAddress", "u32", "u32", "u64", "bool"],
            customTypes: [],
          },
        },
      );
    })(),

    // Model definition for `p_war::models::proposal::PlayerVote` model
    PlayerVote: (() => {
      return defineComponent(
        world,
        {
          player: RecsType.BigInt,
          game_id: RecsType.Number,
          index: RecsType.Number,
          is_in_favor: RecsType.Boolean,
          voting_power: RecsType.Number,
        },
        {
          metadata: {
            namespace: "pixelaw",
            name: "PlayerVote",
            types: ["ContractAddress", "u32", "u32", "bool", "u32"],
            customTypes: [],
          },
        },
      );
    })(),

    // Model definition for `p_war::models::proposal::Proposal` model
    Proposal: (() => {
      return defineComponent(
        world,
        {
          game_id: RecsType.Number,
          index: RecsType.Number,
          author: RecsType.BigInt,
          proposal_type: RecsType.Number,
          target_args_1: RecsType.Number,
          target_args_2: RecsType.Number,
          start: RecsType.Number,
          end: RecsType.Number,
          yes_voting_power: RecsType.Number,
          no_voting_power: RecsType.Number,
          is_activated: RecsType.Boolean,
        },
        {
          metadata: {
            namespace: "pixelaw",
            name: "Proposal",
            types: ["u32", "u32", "ContractAddress", "u8", "u32", "u32", "u64", "u64", "u32", "u32", "bool"],
            customTypes: [],
          },
        },
      );
    })(),

    // Model definition for `pixelaw::core::models::queue::QueueItem` model
    QueueItem: (() => {
      return defineComponent(
        world,
        {
          id: RecsType.BigInt,
          valid: RecsType.Boolean,
        },
        {
          metadata: {
            namespace: "pixelaw",
            name: "QueueItem",
            types: ["felt252", "bool"],
            customTypes: [],
          },
        },
      );
    })(),
  };
}
