// #########################
// ### APP CONFIGURATION ###
// #########################
const APP_KEY: felt252 = 'p_war';
const APP_ICON: felt252 = 'U+2694';
/// BASE means using the server's default manifest.json handler
const APP_MANIFEST: felt252 = 'BASE/manifests/p_war';

const OUT_OF_BOUNDS_GAME_ID: usize = 9999;
// // ####################################
// // ### GAME CONFIGURATION FOR EthCC ###
// // ####################################
// // # Initial settings
// const INITIAL_COLOR: u32 = 0xFFFFFFFF;
// const DEFAULT_AREA: u32 = 10; // changed from 5
// const DEFAULT_PX: u32 = 10;
// const MAX_COLOR_SIZE: usize = 9;
// const GAME_DURATION: u64 = 259200; // 3 days in seconds for EthCC
// const DEFAULT_RECOVERY_RATE: u64 = 300; // 5 mins to recover 1PX

// // # For Governance
// const PROPOSAL_DURATION: u64 = 60 * 60 * 3; // 3 hours in seconds.
// const NEEDED_YES_PX: u32 = 1;

// // for additional rules
// const DISASTER_SIZE: u32 = 5;

// ###############################################
// ### GAME CONFIGURATION FOR CLOSED BETA TEST ###
// ###############################################
// # Initial settings
const GAME_ID: usize = 1;
const INITIAL_COLOR: u32 = 0xFFFFFFFF;
const DEFAULT_AREA: u32 = 32;
const DEFAULT_PX: u32 = 10;
const MAX_COLOR_SIZE: usize = 9;
const GAME_DURATION: u64 = 10 * 60; // 10 minutes in seconds
const DEFAULT_RECOVERY_RATE: u64 = 10; // 10 secs to recover 1PX

// # For Governance
const PROPOSAL_DURATION: u64 = 60; // 1 min in seconds.
// const PROPOSAL_DURATION: u64 = 0; // 1 min in seconds.
const NEEDED_YES_PX: u32 = 1;

// for additional rules
const DISASTER_SIZE: u32 = 5;


// // ####################################
// // ### GAME CONFIGURATION FOR LOCAL ###
// // ####################################
// // # Initial settings
// const INITIAL_COLOR: u32 = 0xFFFFFFFF;
// const DEFAULT_AREA: u32 = 10; // changed from 5
// const DEFAULT_PX: u32 = 10;
// const MAX_COLOR_SIZE: usize = 9;
// const GAME_DURATION: u64 = 180; // 3 mins in seconds for EthCC
// const DEFAULT_RECOVERY_RATE: u64 = 5; // 5 secs to recover 1PX

// // # For Governance
// const PROPOSAL_DURATION: u64 = 30; // 3 seconds in seconds.
// const PROPOSAL_DURATION: u64 = 0; // for sozo test
// const NEEDED_YES_PX: u32 = 1;

// // for additional rules
// const DISASTER_SIZE: u32 = 5;
