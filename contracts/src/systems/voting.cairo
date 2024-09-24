// define the interface
#[dojo::interface]
trait IVoting {
    fn vote(
        ref world: IWorldDispatcher, game_id: usize, index: usize, is_in_favor: bool
    );
}

// dojo decorator
#[dojo::contract(namespace: "pixelaw", nomapping: true)]
mod voting_actions {
    use p_war::models::{player::{Player}, proposal::{PlayerVote, Proposal}};
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp};
    use super::IVoting;

    #[derive(Drop, Serde, starknet::Event)]
    pub struct Voted {
        game_id: usize,
        index: usize,
        timestamp: u64,
        voter: ContractAddress,
        is_in_favor: bool
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        Voted: Voted
    }

    #[abi(embed_v0)]
    impl VotingImpl of IVoting<ContractState> {
        fn vote(
            ref world: IWorldDispatcher,
            game_id: usize,
            index: usize,
            is_in_favor: bool
        ) {
            let player_address = get_caller_address();
            let mut proposal = get!(world, (game_id, index), (Proposal));
            let mut player_vote = get!(world, (player_address, game_id, index), (PlayerVote));
            assert(player_vote.voting_power == 0, 'player already voted');

            let mut player = get!(world, (player_address), (Player));

            // check the player is banned or not
            assert(player.is_banned == false, 'you are banned');

            if is_in_favor {
                proposal.yes_voting_power += 1;
            } else {
                proposal.no_voting_power += 1;
            }

            player.num_commit += 1;
            set!(world, (player));

            player_vote.is_in_favor = is_in_favor;
            player_vote.voting_power = 1;

            set!(world, (proposal, player_vote));

            emit!(
                world,
                (Event::Voted(
                    Voted {
                        game_id,
                        index,
                        timestamp: get_block_timestamp(),
                        voter: player_address,
                        is_in_favor
                    }
                ))
            );
        }
    }
}
