// define the interface
#[starknet::interface]
pub trait IVoting<T> {
    fn vote(ref self: T, game_id: u32, index: u32, use_px: u32, is_in_favor: bool);
}

// dojo decorator
#[dojo::contract]
pub mod voting_actions {
    use dojo::event::EventStorage;
    use dojo::model::ModelStorage;
    use pwar::models::{
        player::Player,
        proposal::{PlayerVote, Proposal}
    };
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp};
    use super::IVoting;

    #[derive(Copy, Drop, Serde)]
    #[dojo::event]
    struct Voted {
        #[key]
        game_id: u32,
        index: u32,
        timestamp: u64,
        voter: ContractAddress,
        is_in_favor: bool
    }

    #[abi(embed_v0)]
    impl VotingImpl of IVoting<ContractState> {
        fn vote(
            ref self: ContractState, game_id: u32, index: u32, use_px: u32, is_in_favor: bool
        ) {
            let mut app_world = self.world(@"pwar");
            let player_address = get_caller_address();
            let mut proposal: Proposal = app_world.read_model((game_id, index));
            let mut player_vote: PlayerVote = app_world.read_model((player_address, game_id, index));
            assert(player_vote.voting_power == 0, 'player already voted');

            let mut player: Player = app_world.read_model(player_address);

            // check the player is banned or not
            assert(player.is_banned == false, 'you are banned');

            if is_in_favor {
                proposal.yes_voting_power += 1;
            } else {
                proposal.no_voting_power += 1;
            }

            //player.current_px -= use_px;
            player.num_commit += use_px;
            app_world.write_model(@player);

            player_vote.is_in_favor = is_in_favor;
            player_vote.voting_power = 1;

            app_world.write_model(@proposal);
            app_world.write_model(@player_vote);

            app_world
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
