// #########################
// ### APP CONFIGURATION ###
// #########################
const APP_KEY: felt252 = 'p_war';
const APP_ICON: felt252 = 'U+2694';

const OUT_OF_BOUNDS_GAME_ID: usize = 9999;
// ####################################
// ### GAME CONFIGURATION FOR pwar v2 ###
// ####################################
// # Initial settings
// const GAME_ID: usize = 1;
// const INITIAL_COLOR: u32 = 0xFFFFFFFF; // white
// const DEFAULT_AREA: u32 = 32; // 32x32 grid
// const DEFAULT_PX: u32 = 30; // 30 max PX per player
// const MAX_COLOR_SIZE: usize = 9; // 9 available colors
// const GAME_DURATION: u64 = 1209600 + 3600; // 2 weeks + 1 hour (for preparation) in seconds
// const DEFAULT_RECOVERY_RATE: u64 = 30; // 30 seconds to recover 1PX
// const BASE_COST: u32 = 1; // 1PX per pixel placement

// // # For Governance
// const PROPOSAL_FACTOR: u32 = 6; // cost of proposal is 6PX
// const PROPOSAL_DURATION: u64 = 10800; // 3 hours in seconds to vote on proposals
// const NEEDED_YES_PX: u32 = 1; // minimum of 1PX to pass a proposal

// // for additional rules
// const DISASTER_SIZE: u32 = 5; // 5x5 grid size for disasters

// // ###############################################
// // ### GAME CONFIGURATION FOR CLOSED BETA TEST ###
// // ###############################################
// // # Initial settings
// const GAME_ID: usize = 1;
// const INITIAL_COLOR: u32 = 0xFFFFFFFF;
// const DEFAULT_AREA: u32 = 16;
// const DEFAULT_PX: u32 = 10;
// const MAX_COLOR_SIZE: usize = 9;
// const GAME_DURATION: u64 = 15 * 60; // 15 minutes in seconds
// const DEFAULT_RECOVERY_RATE: u64 = 10; // 10 secs to recover 1PX
// const BASE_COST: u32 = 1;

// // # For Governance
// const PROPOSAL_FACTOR: u32 = 6;
// const PROPOSAL_DURATION: u64 = 60; // 1 min in seconds.
// // const PROPOSAL_DURATION: u64 = 0; // 0 for sozo test.
// const NEEDED_YES_PX: u32 = 1;

// // for additional rules
// const DISASTER_SIZE: u32 = 5;

// // ####################################
// // ### GAME CONFIGURATION FOR LOCAL ###
// // ####################################
// // # Initial settings
const GAME_ID: usize = 1;
const INITIAL_COLOR: u32 = 0xFFFFFFFF;
const DEFAULT_AREA: u32 = 50; // changed from 5
const DEFAULT_PX: u32 = 10;
const MAX_COLOR_SIZE: usize = 9;
const GAME_DURATION: u64 = 18000;
const DEFAULT_RECOVERY_RATE: u64 = 5; // 5 secs to recover 1PX
const BASE_COST: u32 = 1; // 1PX per pixel placement

// # For Governance
const PROPOSAL_FACTOR: u32 = 1; // 3 seconds in seconds.
const PROPOSAL_DURATION: u64 = 0; // for sozo test
const NEEDED_YES_PX: u32 = 1;

// for additional rules
const DISASTER_SIZE: u32 = 5;
