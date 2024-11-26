// define the interface
#[starknet::interface]
pub trait IVoting<T> {
    fn vote(
        ref self: T, game_id: usize, index: usize, use_px: u32, is_in_favor: bool
    );
}

// dojo decorator
#[dojo::contract(namespace: "pixelaw", nomapping: true)]
mod voting_actions {
    use p_war::models::{player::{Player}, proposal::{PlayerVote, Proposal}};
    use p_war::systems::utils::{recover_px, update_max_px};
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp};
    use super::IVoting;
    use dojo::model::{ModelStorage, ModelValueStorage};
    use dojo::event::EventStorage;

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
            ref self: ContractState,
            game_id: usize,
            index: usize,
            use_px: u32,
            is_in_favor: bool
        ) {
            let mut world = self.world(@"pixelaw");
            let player_address = get_caller_address();
            let mut proposal: Proposal = world.read_model((game_id, index));
            let mut player_vote: PlayerVote = world.read_model((player_address, game_id, index));
            assert(player_vote.px == 0, 'player already voted');

            recover_px(ref world, game_id, player_address);

            let mut player: Player = world.read_model(player_address);

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
            world.write_model(@player);

            player_vote.is_in_favor = is_in_favor;
            player_vote.px = use_px;

            world.write_model(@proposal);
            world.write_model(@player_vote);

            self.update_max_px(game_id, player_address);

            world.emit_event(@Voted {game_id, index, timestamp: get_block_timestamp(), voter: player_address, is_in_favor});
        }
    }
}
