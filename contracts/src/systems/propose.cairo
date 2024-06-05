use starknet::{ContractAddress, get_caller_address, get_block_timestamp};
use p_war::models::{game::{Game, Status}, proposal::{Args, ProposalType, Proposal}};

const PROPOSAL_DURATION: u64 = 0;
const NEEDED_YES_PX: u32 = 1;

// define the interface
#[dojo::interface]
trait IPropose {
    fn create_proposal(game_id: usize, proposal_type: ProposalType, args: Args) -> usize;
    // fn toggle_allowed_app(game_id: usize, app: ContractAddress);
    // fn toggle_allowed_color(game_id: usize, color: u32) -> usize;
    // fn change_game_duration(game_id: usize, duration: u64);
    // fn change_pixel_recovery(game_id: usize, rate: u32);
    // fn expand_area(game_id: usize, amount: u32);
    fn activate_proposal(game_id: usize, index: usize);
}

// dojo decorator
#[dojo::contract]
mod propose {
    use super::{IPropose, can_propose, NEEDED_YES_PX, PROPOSAL_DURATION};
    use p_war::models::{game::{Game, Status, GameTrait}, proposal::{Args, ProposalType, Proposal}, allowed_app::AllowedApp, allowed_color::AllowedColor};
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp};

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
                ProposalType::ToggleAllowedApp => 1,
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
                ProposalType::ChangeGameDuration => 3,
                ProposalType::ChangePixelRecovery => 4,            
                ProposalType::ExpandArea => 5,     

            };

        }
    }
}

fn can_propose(status: Status) -> bool {
    status == Status::Pending || status == Status::Ongoing
}