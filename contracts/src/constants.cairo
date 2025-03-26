// #########################
// ### APP CONFIGURATION ###
// #########################
pub const APP_KEY: felt252 = 'p_war';
pub const APP_ICON: felt252 = 'U+2694';

pub const OUT_OF_BOUNDS_GAME_ID: u32 = 9999;
// ####################################
// ### GAME CONFIGURATION FOR pwar v2 ###
// ####################################
// # Initial settings
// const GAME_ID: u32 = 1;
// const INITIAL_COLOR: u32 = 0xFFFFFFFF; // white
// const DEFAULT_AREA: u32 = 32; // 32x32 grid
// const DEFAULT_PX: u32 = 30; // 30 max PX per player
// const MAX_COLOR_SIZE: u32 = 9; // 9 available colors
// const GAME_DURATION: u64 = 1209600 + 3600; // 2 weeks + 1 hour (for preparation) in seconds
// const DEFAULT_RECOVERY_RATE: u64 = 30; // 30 seconds to recover 1PX

// // # For Governance
// const PROPOSAL_FACTOR: u32 = 6; // cost of proposal is 6PX
// const PROPOSAL_DURATION: u64 = 10800; // 3 hours in seconds to vote on proposals

// // for additional rules
// const DISASTER_SIZE: u32 = 5; // 5x5 grid size for disasters

// // ###############################################
// // ### GAME CONFIGURATION FOR CLOSED BETA TEST ###
// // ###############################################
// // # Initial settings
// const GAME_ID: u32 = 1;
// const INITIAL_COLOR: u32 = 0xFFFFFFFF;
// const DEFAULT_AREA: u32 = 16;
// const MAX_COLOR_SIZE: u32 = 9;
// const GAME_DURATION: u64 = 15 * 60; // 15 minutes in seconds
// const DEFAULT_RECOVERY_RATE: u64 = 10; // 10 secs to recover 1PX

// // # For Governance
// const PROPOSAL_FACTOR: u32 = 6;
// const PROPOSAL_DURATION: u64 = 60; // 1 min in seconds.
// // const PROPOSAL_DURATION: u64 = 0; // 0 for sozo test.

// // for additional rules
// const DISASTER_SIZE: u32 = 5;

// // ####################################
// // ### GAME CONFIGURATION FOR LOCAL ###
// // ####################################
// // # Initial settings
pub const GAME_ID: u32 = 1;
pub const INITIAL_COLOR: u32 = 0xFFFFFFFF;
pub const DEFAULT_AREA: u32 = 50; // changed from 5
pub const MAX_COLOR_SIZE: u32 = 9;
pub const GAME_DURATION: u64 = 60 * 60 * 24 * 30 * 12; // 12 months
pub const DEFAULT_RECOVERY_RATE: u64 = 5; // 5 secs to recover 1PX

// # For Governance
pub const PROPOSAL_FACTOR: u32 = 1; // 3 seconds in seconds.
pub const PROPOSAL_DURATION: u64 = 3 * 60; // 3mins
pub const NEEDED_YES_VOTING_POWER: u32 = 1;

// for additional rules
pub const DISASTER_SIZE: u32 = 5;
