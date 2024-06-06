use starknet::{ContractAddress, get_caller_address, get_block_timestamp, contract_address_const};
use p_war::models::{game::{Game, Status}, proposal::{Args, ProposalType, Proposal}};

const PROPOSAL_DURATION: u64 = 0; // should change it later.
const NEEDED_YES_PX: u32 = 1;

// define the interface
#[dojo::interface]
trait IPropose {
    fn create_proposal(game_id: usize, proposal_type: ProposalType, args: Args) -> usize;
    fn activate_proposal(game_id: usize, index: usize);
}

// dojo decorator
#[dojo::contract]
mod propose {
    use super::{IPropose, can_propose, NEEDED_YES_PX, PROPOSAL_DURATION};
    use p_war::models::{
        game::{Game, Status, GameTrait},
        proposal::{Args, ProposalType, Proposal, PixelRecoveryRate},
        board::{GameId, Board, Position},
        player::{Player},
        allowed_app::AllowedApp,
        allowed_color::AllowedColor
    };
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
            };

        }
    }
}

fn can_propose(status: Status) -> bool {
    status == Status::Pending || status == Status::Ongoing
}