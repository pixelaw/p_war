use starknet::{ContractAddress, get_caller_address, get_block_timestamp, contract_address_const};
use p_war::models::{game::{Game, Status}, proposal::{Args, ProposalType, Proposal}};

const PROPOSAL_DURATION: u64 = 0; // should change it later.
const NEEDED_YES_PX: u32 = 1;
const DISASTER_SIZE: u32 = 5;

// define the interface
#[dojo::interface]
trait IPropose {
    fn create_proposal(game_id: usize, proposal_type: ProposalType, args: Args) -> usize;
    fn activate_proposal(game_id: usize, index: usize);
}

// dojo decorator
#[dojo::contract]
mod propose {
    use super::{IPropose, can_propose, NEEDED_YES_PX, PROPOSAL_DURATION, DISASTER_SIZE};
    use p_war::models::{
        game::{Game, Status, GameTrait},
        proposal::{Args, ProposalType, Proposal, PixelRecoveryRate},
        board::{GameId, Board, Position, PWarPixel},
        player::{Player},
        allowed_app::AllowedApp,
        allowed_color::AllowedColor
    };
    use p_war::systems::utils::{ recover_px };
    use pixelaw::core::utils::{get_core_actions, DefaultParameters};
    use pixelaw::core::actions::{
        IActionsDispatcher as ICoreActionsDispatcher,
        IActionsDispatcherTrait as ICoreActionsDispatcherTrait
    };
    use pixelaw::core::models::{ pixel::PixelUpdate };
    use starknet::{ContractAddress, get_block_timestamp, get_caller_address, get_contract_address, get_tx_info};


    #[abi(embed_v0)]
    impl ProposeImpl of IPropose<ContractState> {

        fn create_proposal(world: IWorldDispatcher, game_id: usize, proposal_type: ProposalType, args: Args) -> usize {
            // get the game
            let mut game = get!(world, game_id, (Game));
            assert(can_propose(game.status()), 'cannot submit proposal');

            let player_address = get_tx_info().unbox().account_contract_address;

            // recover px
            recover_px(world, game_id, player_address);

            // if this is first time for the caller, let's set initial px.
            let mut player = get!(
                world,
                (player_address),
                (Player)
            );


            // check the current px is eq or larger than cost_paint
            assert(player.current_px >= game.base_cost, 'you cannot paint');

            // check the player is banned or not
            assert(player.is_banned == false, 'you are banned');


            let proposal = Proposal{
                game_id: game_id,
                index: game.proposal_idx,
                author: get_caller_address(),
                proposal_type: proposal_type,
                args: args,
                start: get_block_timestamp(),
                end: get_block_timestamp() + PROPOSAL_DURATION,
                yes_px: 0,
                no_px: 0
            };

            game.proposal_idx += 1;

            set!(
                world,
                (
                    proposal,
                    game
                )
            );

            // consume px
            set!(
                world,
                (Player{
                    address: player.address,
                    max_px: player.max_px,
                    num_owns: player.num_owns,
                    num_commit: player.num_commit + game.base_cost,
                    current_px: player.current_px - game.base_cost,
                    last_date: get_block_timestamp(),
                    is_banned: false,
                }),
            );


            proposal.index
        }


        fn activate_proposal(world: IWorldDispatcher, game_id: usize, index: usize){
            // get the proposal
            let proposal = get!(world, (game_id, index), (Proposal));
            let current_timestamp = get_block_timestamp();
            assert(current_timestamp >= proposal.end, 'proposal period has not ended');
            assert(proposal.yes_px >= NEEDED_YES_PX, 'did not reach minimum yes_px');

            // activate the proposal.

            match proposal.proposal_type {
                ProposalType::Unknown => 0,
                ProposalType::ToggleAllowedApp => 1, // TODO
                ProposalType::ToggleAllowedColor => {
                    let new_color: u32 = proposal.args.arg1.try_into().unwrap();
                    let mut allowed_color = get!(world, (game_id, new_color), (AllowedColor));
                    allowed_color.is_allowed = !allowed_color.is_allowed;
                    set!(
                        world,
                        (allowed_color)
                    );
                    2
                },
                ProposalType::ChangeGameDuration => {
                    let add_duration: u64 = proposal.args.arg1;
                    let mut game = get!(
                        world,
                        (game_id),
                        (Game)
                    );
                    game.end += add_duration;
                    set!(
                        world,
                        (game)
                    );
                    3
                },
                ProposalType::ChangePixelRecovery => {
                    set!(
                        world,
                        (PixelRecoveryRate{
                            game_id: game_id,
                            rate: proposal.args.arg1,
                        })
                    );
                    4
                },

                ProposalType::ExpandArea => {
                    let core_actions = get_core_actions(world);
                    let player_address = get_caller_address();
                    let system = get_caller_address();

                    let mut board = get!(
                        world,
                        (game_id),
                        (Board)
                    );
                    let origin: Position = board.origin;
                    let original_height = board.height;
                    let original_width = board.width;

                    let add_w: u32 = proposal.args.arg1.try_into().unwrap();
                    let add_h: u32 = proposal.args.arg2.try_into().unwrap();

                    // make sure that game board has been set with game id
                    let mut y = origin.y + original_height;
                    loop {
                        if y >= origin.y + original_height + add_h {
                            break;
                        };
                        let mut x = origin.x + original_width;
                        loop {
                            if x >= origin.x + original_width + add_w {
                                break;
                            };
                            core_actions
                                .update_pixel(
                                    player_address,
                                    system,
                                    PixelUpdate {
                                        x,
                                        y,
                                        color: Option::None,
                                        timestamp: Option::None,
                                        text: Option::None,
                                        app: Option::Some(system),
                                        owner: Option::None,
                                        action: Option::None
                                    }
                                );
                            set!(
                                world,
                                (
                                    GameId {
                                        x,
                                        y,
                                        value: game_id
                                    }
                                )
                            );
                            x += 1;
                        };
                        y += 1;
                    };

                    board.width += add_w;
                    board.height += add_h;


                    set!(
                        world,
                        (
                            board
                        )
                    );
                    5
                },

                ProposalType::BanPlayerAddress => {
                    let target_address: ContractAddress = proposal.args.address;
                    let mut target_player = get!(
                        world,
                        (target_address),
                        (Player)
                    );

                    target_player.is_banned = true;

                    set!(
                        world,
                        (
                            target_player
                        )
                    );
                    6
                },

                ProposalType::ChangeMaxPXConfig => {
                    // change config type by arg1
                    let mut game = get!(
                        world,
                        (game_id),
                        (Game)
                    );
                    match proposal.args.arg1 {

                        // change constant value for max_px
                        0 => {
                            game.const_val = proposal.args.arg2.try_into().unwrap();
                            0
                        },

                        // change coefficient for number of own pixels for max_px
                        1 => {
                            game.coeff_own_pixels = proposal.args.arg2.try_into().unwrap();
                            1
                        },

                        // change coefficient for the past commitments for max_px
                        2 => {
                            game.coeff_commits = proposal.args.arg2.try_into().unwrap();
                            1
                        },
                        _ => {7},
                    };
                    set!(
                        world,
                        (game)
                    );
                    7
                },
                ProposalType::ChangeWinnerConfig => {
                    // change config type by arg1
                    // 0: set the person with the most pixels at the end as the winner.
                    // 1: set the winner by the proposal directly.
                    // 2: winner is the person who has committied at the most.

                    let mut game = get!(
                        world,
                        (game_id),
                        (Game)
                    );
                    game.winner_config = proposal.args.arg1.try_into().unwrap();

                    if game.winner_config == 1 {
                        // set winner
                        game.winner = proposal.args.address;

                        // should we end the game instantly?? -> probably not.
                    };

                    set!(
                        world,
                        (game)
                    );
                    8
                },
                ProposalType::ChangePaintCost => {
                    // change the cost to paint 
                    let mut game = get!(
                        world,
                        (game_id),
                        (Game)
                    );
                    game.base_cost = proposal.args.arg1.try_into().unwrap();

                    set!(
                        world,
                        (game)
                    );
                    9
                },
                ProposalType::MakeADisaster => {
                    let core_actions = get_core_actions(world);
                    let system = get_caller_address();

                    // get the size of board
                    let mut board = get!(
                        world,
                        (game_id),
                        (Board)
                    );
                    let origin: Position = board.origin;

                    let top: u32 = proposal.args.arg2.try_into().unwrap();
                    let left: u32 = proposal.args.arg1.try_into().unwrap();
                    let mut y: u32 = proposal.args.arg2.try_into().unwrap();
                    loop {
                        if (y >= origin.y + board.height ||
                                y >= top + DISASTER_SIZE) {
                            break;
                        };
                        let mut x: u32 = proposal.args.arg1.try_into().unwrap();
                        loop {
                            if (x >= origin.x + board.width ||
                                    x >= left + DISASTER_SIZE) {
                                break;
                            };

                            core_actions
                                .update_pixel(
                                    get_caller_address(), // is it okay?
                                    system,
                                    PixelUpdate {
                                        x,
                                        y,
                                        color: Option::None, // should it be white?
                                        timestamp: Option::None,
                                        text: Option::None,
                                        app: Option::Some(system),
                                        owner: Option::None,
                                        action: Option::None
                                    }
                                );
                            
                            // decrease the previous player's num_owns
                            let position = Position {x, y};
                            let previous_pwarpixel = get!(
                                world,
                                (position),
                                (PWarPixel)
                            );
                            if (previous_pwarpixel.owner != starknet::contract_address_const::<0x0>()) {
                                // get the previous player's info
                                let mut previous_player = get!(
                                    world,
                                    (previous_pwarpixel.owner),
                                    (Player)
                                );

                                previous_player.num_owns -= 1;
                                set!(
                                    world,
                                    (previous_player)
                                );
                            }

                            x += 1;
                        };
                        y += 1;
                    };
                    10
                },
                _ => {
                    99
                },
            };

            // TODO: should we panish the author if the proposal is denied?
            // add author's commitment points
            let mut author = get!(
                world,
                (proposal.author),
                (Player)
            );

            author.num_commit += 10; // get 10 commitments if the proposal is accepted
            set!(
                world,
                (author)
            );
        }
    }
}

fn can_propose(status: Status) -> bool {
    status == Status::Pending || status == Status::Ongoing
}