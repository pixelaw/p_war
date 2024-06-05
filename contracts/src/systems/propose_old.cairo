use starknet::{ContractAddress, get_caller_address, get_block_timestamp};
use p_war::models::{game::{Game, Status}, proposal::{Terms, Proposal}};

const PROPOSAL_DURATION: u64 = 0;
const NEEDED_YES_PX: u32 = 1;

// define the interface
#[dojo::interface]
trait IPropose {
    fn toggle_allowed_app(game_id: usize, app: ContractAddress);
    fn toggle_allowed_color(game_id: usize, color: u32) -> usize;
    fn change_game_duration(game_id: usize, duration: u64);
    fn change_pixel_recovery(game_id: usize, rate: u32);
    fn expand_area(game_id: usize, amount: u32);
    fn activate_proposal(game_id: usize, index: usize);
}

// dojo decorator
#[dojo::contract]
mod propose {
    use super::{IPropose, can_propose, create_proposal, NEEDED_YES_PX};
    use p_war::models::{game::{Game, Status, GameTrait}, proposal::{Terms, Proposal}, allowed_app::AllowedApp, allowed_color::AllowedColor};
    use starknet::{ContractAddress, get_block_timestamp};

    #[abi(embed_v0)]
    impl ProposeImpl of IPropose<ContractState> {
        fn toggle_allowed_app(world: IWorldDispatcher, game_id: usize, app: ContractAddress) {
            // get the game
            let mut game = get!(world, game_id, (Game));
            assert(can_propose(game.status()), 'cannot submit proposal');

            let proposal = create_proposal(
                game,
                Terms {
                    toggle_allowed_app: app,
                    toggle_allowed_color: 0,
                    change_game_duration: 0,
                    change_pixel_recovery: 0,
                    expand_area: 0
                }
            );

            game.proposals += 1;

            set!(
                world,
                (
                    proposal,
                    game
                )
            );
        }

        fn toggle_allowed_color(world: IWorldDispatcher, game_id: usize, color: u32) -> usize {
            // get the game
            let mut game = get!(world, game_id, (Game));
            assert(can_propose(game.status()), 'cannot submit proposal');

            let proposal = create_proposal(
                game,
                Terms {
                    toggle_allowed_app: starknet::contract_address_const::<0x0>(),
                    toggle_allowed_color: color,
                    change_game_duration: 0,
                    change_pixel_recovery: 0,
                    expand_area: 0
                }
            );

            game.proposals += 1;

            set!(
                world,
                (proposal,
                game)
            );

            proposal.index
        }

        fn change_game_duration(world: IWorldDispatcher, game_id: usize, duration: u64) {
            // get the game
            let mut game = get!(world, game_id, (Game));
            assert(can_propose(game.status()), 'cannot submit proposal');

            let proposal = create_proposal(
                game,
                Terms {
                    toggle_allowed_app: starknet::contract_address_const::<0x0>(),
                    toggle_allowed_color: 0,
                    change_game_duration: duration,
                    change_pixel_recovery: 0,
                    expand_area: 0
                }
            );

            game.proposals += 1;

            set!(
                world,
                (proposal,
                game)
            )
        }

        fn change_pixel_recovery(world: IWorldDispatcher, game_id: usize, rate: u32) {
            // get the game
            let mut game = get!(world, game_id, (Game));
            assert(can_propose(game.status()), 'cannot submit proposal');

            let proposal = create_proposal(
                game,
                Terms {
                    toggle_allowed_app: starknet::contract_address_const::<0x0>(),
                    toggle_allowed_color: 0,
                    change_game_duration: 0,
                    change_pixel_recovery: rate,
                    expand_area: 0
                }
            );

            game.proposals += 1;

            set!(
                world,
                (proposal,
                game)
            )
        }

        fn expand_area(world: IWorldDispatcher, game_id: usize, amount: u32) {
            // get the game
            let mut game = get!(world, game_id, (Game));
            assert(can_propose(game.status()), 'cannot submit proposal');

            let proposal = create_proposal(
                game,
                Terms {
                    toggle_allowed_app: starknet::contract_address_const::<0x0>(),
                    toggle_allowed_color: 0,
                    change_game_duration: 0,
                    change_pixel_recovery: 0,
                    expand_area: amount
                }
            );

            game.proposals += 1;

            set!(
                world,
                (proposal,
                game)
            )
        }

        fn activate_proposal(world: IWorldDispatcher, game_id: usize, index: usize){
            // get the proposal
            let proposal = get!(world, (game_id, index), (Proposal));
            let current_timestamp = get_block_timestamp();
            assert(current_timestamp >= proposal.end, 'proposal period has not ended');
            assert(proposal.yes_px >= NEEDED_YES_PX, 'did not reach minimum yes_px');

            if !proposal.terms.toggle_allowed_app.is_zero() {
                let mut allowed_app = get!(world, (game_id, proposal.terms.toggle_allowed_app), (AllowedApp));
                allowed_app.is_allowed = !allowed_app.is_allowed;
                set!(
                    world,
                    (allowed_app)
                );
            }

            if proposal.terms.toggle_allowed_color > 0 {
                let mut allowed_color = get!(world, (game_id, proposal.terms.toggle_allowed_color), (AllowedColor));
                allowed_color.is_allowed = !allowed_color.is_allowed;
                set!(
                    world,
                    (allowed_color)
                );
            }

        }
    }
}

fn can_propose(status: Status) -> bool {
    status == Status::Pending || status == Status::Ongoing
}

fn create_proposal(game: Game, terms: Terms) -> Proposal {
    let author = get_caller_address();
    let start = get_block_timestamp();
    let end = start + PROPOSAL_DURATION;

    Proposal {
        game_id: game.id,
        index: game.proposals,
        author,
        terms,
        start,
        end,
        yes_px: 0,
        no_px: 0
    }
}
