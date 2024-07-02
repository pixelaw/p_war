// 1 week in seconds
// const GAME_DURATION: u64 = 604800; // 1 week in seconds
// const DEFAULT_AREA: u64 = 259200; // 3 days in seconds for EthCC
// const GAME_DURATION: u64 = 1800; // 30 minutes in seconds for closed playtest
const GAME_DURATION: u64 = 300; // 5 minute in seconds for local testing

const DEFAULT_AREA: u32 = 10; // changed from 5
const DEFAULT_RECOVERY_RATE: u64 = 10;
const APP_KEY: felt252 = 'p_war';
const APP_ICON: felt252 = 'U+2694';
const MAX_COLOR_SIZE: usize = 9;
const INITIAL_COLOR: u32 = 0xFFFFFF00;


/// BASE means using the server's default manifest.json handler
const APP_MANIFEST: felt252 = 'BASE/manifests/p_war';

// const PROPOSAL_DURATION: u64 = 120; // 2 mins in seconds. for local test.
// const PROPOSAL_DURATION: u64 = 60 * 60 * 3; // 3 hours in seconds.
const PROPOSAL_DURATION: u64 = 0; // for sozo test
const NEEDED_YES_PX: u32 = 1;
const DISASTER_SIZE: u32 = 5;

const DEFAULT_PX: u32 = 10;
