// define the interface
#[starknet::interface]
trait IVoting {
    fn vote(
        ref world: IWorldDispatcher, game_id: usize, index: usize, use_px: u32, is_in_favor: bool
    );
}

// dojo decorator
#[dojo::contract(namespace: "pixelaw", nomapping: true)]
mod voting_actions {
    use p_war::models::{player::{Player}, proposal::{PlayerVote, Proposal}};
    use p_war::systems::utils::{recover_px, update_max_px};
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
            use_px: u32,
            is_in_favor: bool
        ) {
            let player_address = get_caller_address();
            let mut proposal = get!(world, (game_id, index), (Proposal));
            let mut player_vote = get!(world, (player_address, game_id, index), (PlayerVote));
            assert(player_vote.px == 0, 'player already voted');

            recover_px(world, game_id, player_address);

            let mut player = get!(world, (player_address), (Player));

            print!("\n@@ASSERT: CUR: {}, USE: {}\n", player.current_px, use_px);
            assert(player.current_px >= use_px, 'player do not have enough px');

            // check the player is banned or not
            assert(player.is_banned == false, 'you are banned');

            if is_in_favor {
                proposal.yes_px += use_px;
            } else {
                proposal.no_px += use_px;
            }

            player.current_px -= use_px;
            player.num_commit += use_px;
            set!(world, (player));

            player_vote.is_in_favor = is_in_favor;
            player_vote.px = use_px;

            set!(world, (proposal, player_vote));

            update_max_px(world, game_id, player_address);

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
