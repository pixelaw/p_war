// define the interface
#[starknet::interface]
pub trait IVoting<T> {
    fn vote(ref self: T, game_id: usize, index: usize, use_px: u32, is_in_favor: bool);
}

// dojo decorator
#[dojo::contract(namespace: "pixelaw", nomapping: true)]
mod voting_actions {
    use dojo::event::EventStorage;
    use dojo::model::{ModelStorage, ModelValueStorage};
    use dojo::world::WorldStorageTrait;
    use p_war::models::{player::{Player}, proposal::{PlayerVote, Proposal}};
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp};
    use super::IVoting;

    #[derive(Copy, Drop, Serde)]
    #[dojo::event]
    struct Voted {
        #[key]
        game_id: usize,
        index: usize,
        timestamp: u64,
        voter: ContractAddress,
        is_in_favor: bool
    }

    #[abi(embed_v0)]
    impl VotingImpl of IVoting<ContractState> {
        fn vote(
            ref self: ContractState, game_id: usize, index: usize, use_px: u32, is_in_favor: bool
        ) {
            let mut world = self.world(@"pixelaw");
            let player_address = get_caller_address();
            let mut proposal: Proposal = world.read_model((game_id, index));
            let mut player_vote: PlayerVote = world.read_model((player_address, game_id, index));
            assert(player_vote.voting_power == 0, 'player already voted');

            let mut player: Player = world.read_model(player_address);

            // check the player is banned or not
            assert(player.is_banned == false, 'you are banned');

            if is_in_favor {
                proposal.yes_voting_power += 1;
            } else {
                proposal.no_voting_power += 1;
            }

            //player.current_px -= use_px;
            player.num_commit += use_px;
            world.write_model(@player);

            player_vote.is_in_favor = is_in_favor;
            player_vote.voting_power = 1;

            world.write_model(@proposal);
            world.write_model(@player_vote);

            world
                .emit_event(
                    @Voted {
                        game_id,
                        index,
                        timestamp: get_block_timestamp(),
                        voter: player_address,
                        is_in_favor
                    }
                );
        }
    }
}
