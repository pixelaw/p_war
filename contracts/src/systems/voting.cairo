// define the interface
#[dojo::interface]
trait IVoting {
    fn vote(game_id: usize, index: usize, is_in_favor: bool);
}

// dojo decorator
#[dojo::contract]
mod voting {
    use super::IVoting;
    use starknet::{ContractAddress, get_caller_address};
    use p_war::models::proposal::{PlayerVote, Proposal};

    // one px vote per person

    #[abi(embed_v0)]
    impl VotingImpl of IVoting<ContractState> {
        fn vote(world: IWorldDispatcher, game_id: usize, index: usize, is_in_favor: bool) {
            let (mut player_vote, mut proposal) = get!(world, (game_id, index), (PlayerVote, Proposal));
            assert(player_vote.px == 0, 'player already voted');

            if is_in_favor {
                proposal.yes_px += 1;
            } else {
                proposal.no_px += 1;
            }

            player_vote.is_in_favor = is_in_favor;
            player_vote.px = 1;

            set!(
                world,
                (
                    proposal,
                    player_vote
                )
            )


        }
    }
}