// define the interface
#[dojo::interface]
trait IVoting {
    fn vote(game_id: usize, index: usize, use_px: u32, is_in_favor: bool);
}

// dojo decorator
#[dojo::contract]
mod voting {
    use super::IVoting;
    use starknet::{ContractAddress, get_caller_address};
    use p_war::models::{
        player::{Player},
        proposal::{PlayerVote, Args, ProposalType, Proposal}
    };
    use p_war::systems::utils::recover_px;

    // one px vote per person

    #[abi(embed_v0)]
    impl VotingImpl of IVoting<ContractState> {
        fn vote(world: IWorldDispatcher, game_id: usize, index: usize, use_px: u32, is_in_favor: bool) {
            let player_address = get_caller_address();
            let mut proposal = get!(world, (game_id, index), (Proposal));
            let mut player_vote = get!(world, (player_address, game_id, index), (PlayerVote));
            assert(player_vote.px == 0, 'player already voted');

            recover_px(world, game_id);

            let mut player = get!(
                world,
                (player_address),
                (Player)
            );

            print!("\n@@ASSERT: CUR: {}, USE: {}\n", player.current_px, use_px);
            assert(player.current_px >= use_px, 'player do not have enough px');

            if is_in_favor {
                proposal.yes_px += use_px;
            } else {
                proposal.no_px += use_px;
            }

            player.current_px -= use_px;
            set!(
                world,
                (player)
            );

            player_vote.is_in_favor = is_in_favor;
            player_vote.px = use_px;

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