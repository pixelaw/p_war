use p_war::models::game::Game;
use p_war::models::guilds::Guild;
use p_war::models::player::Player;
use starknet::{ContractAddress, get_caller_address};

#[starknet::interface]
pub trait IGuild<T> {
    fn create_guild(
        ref self: T, game_id: usize, guild_name: felt252
    ) -> usize; //returns guild ID
    fn add_member(
        ref self: T, game_id: usize, guild_id: usize, new_member: ContractAddress
    );
    fn join_guild(ref self: T, game_id: usize, guild_id: usize);
    fn remove_member(
        ref self: T, game_id: usize, guild_id: usize, member: ContractAddress
    );
    fn is_member(ref self: T, game_id: usize, guild_id: usize, member: ContractAddress) -> bool;
    fn get_guild_contract_address(ref self: T) -> ContractAddress;
    fn get_guild_points(ref self: T, game_id: usize, guild_id: usize) -> usize;
}

#[dojo::contract(namespace: "pixelaw", nomapping: true)]
mod guild_actions {
    use p_war::models::{
        game::{Game, Status, GameTrait}, guilds::{Guild},
        board::{GameId, Board, Position, PWarPixel}, player::{Player}, allowed_app::AllowedApp,
    };
    use starknet::{
        ContractAddress, get_block_timestamp, get_caller_address, get_contract_address, get_tx_info
    };
    use dojo::model::{ModelStorage, ModelValueStorage};
    use dojo::world::WorldStorageTrait;
    use dojo::event::EventStorage;
    use super::{IGuild};
    
    #[derive(Copy, Drop, Serde)]
    #[dojo::event]
    pub struct GuildCreated {
        #[key]
        game_id: usize,
        guild_id: usize,
        guild_name: felt252,
        creator: ContractAddress
    }
    
    #[derive(Copy, Drop, Serde)]
    #[dojo::event]
    pub struct MemberAdded {
        #[key]
        game_id: usize,
        guild_id: usize,
        member: ContractAddress
    }
    
    #[derive(Copy, Drop, Serde)]
    #[dojo::event]
    pub struct MemberRemoved {
        #[key]
        game_id: usize,
        guild_id: usize,
        member: ContractAddress
    }

    #[abi(embed_v0)]
    impl GuildImpl of IGuild<ContractState> {
        fn create_guild(ref self: ContractState, game_id: usize, guild_name: felt252) -> usize {
            let mut world = self.world(@"pixelaw");
            let caller = get_caller_address();

            // Check if the game exists and get the game data
            let mut game: Game = world.read_model(game_id);
            assert(game.id == game_id, 'Game does not exist');

            // Use the current guild_count as the new guild_id
            let guild_id = game.guild_count;
            println!("guild_id: {}", guild_id);

            // Create a new Array and populate it with existing guild_ids
            let mut new_guild_ids = ArrayTrait::new();
            let mut i = 0;
            loop {
                println!("i: {}", i);
                if i == game.guild_ids.len() {
                    break;
                }
                println!("game.guild_ids.at(i): {}", *game.guild_ids.at(i));
                new_guild_ids.append(*game.guild_ids.at(i));
                i += 1;
            };

            // Append the new guild_id
            new_guild_ids.append(guild_id);
            println!("new_guild_ids.len(): {}", new_guild_ids.len());
            // Update the game with the new guild_ids
            game.guild_ids = new_guild_ids.span();
            game.guild_count += 1;

            // Create the new guild
            let new_guild = Guild {
                game_id: game_id,
                guild_id: guild_id,
                guild_name: guild_name,
                creator: caller,
                members: array![caller].span(),
                member_count: 1
            };
            println!("new_guild.guild_id: {}", new_guild.guild_id);

            // Save the guild and update the game
            world.write_model(@new_guild);
            world.write_model(@game);
            println!("set guild");
            let caller = get_caller_address();
            world.emit_event(@GuildCreated {game_id, guild_id, guild_name, creator: caller});
            guild_id
        }

        fn add_member(
            ref self: ContractState,
            game_id: usize,
            guild_id: usize,
            new_member: ContractAddress
        ) {
            let mut world = self.world(@"pixelaw");
            let caller = get_caller_address();

            // Get the guild
            let mut guild: Guild = world.read_model((game_id, guild_id));

            // Check if the caller is the creator
            assert(guild.creator == caller, 'Only creator can add members');

            // Check if the member is not already in the guild
            let is_member = self.is_member(game_id, guild_id, new_member);
            assert(is_member == false, 'New Member already in guild');

            // Create a new Array and populate it with existing guild_ids
            let mut new_guild_members = ArrayTrait::new();
            let mut i = 0;
            loop {
                if i == guild.members.len() {
                    break;
                }
                new_guild_members.append(*guild.members.at(i));
                i += 1;
            };

            // Append the new guild_id
            new_guild_members.append(new_member);

            // Update the game with the new guild_ids
            guild.members = new_guild_members.span();

            //update member count
            guild.member_count += 1;

            // Save the updated guild
            world.write_model(@guild);
            world.emit_event(@MemberAdded { game_id, guild_id, member: new_member });
        }

        fn join_guild(ref self: ContractState, game_id: usize, guild_id: usize) {
            let caller = get_caller_address();

            // Add the member to the guild
            self.add_member(game_id, guild_id, caller);
        }

        fn remove_member(
            ref self: ContractState, game_id: usize, guild_id: usize, member: ContractAddress
        ) {
            let mut world = self.world(@"pixelaw");
            let caller = get_caller_address();

            // Get the guild
            let mut guild: Guild = world.read_model((game_id, guild_id));

            // Check if the caller is the creator
            assert(guild.creator == caller, 'Only creator can remove members');

            // Remove the member and check if it existed
            let mut updated_members = ArrayTrait::new();
            let mut member_found = false;
            let mut i = 0;
            loop {
                if i == guild.member_count {
                    break;
                }
                if *guild.members.at(i) != member {
                    updated_members.append(*guild.members.at(i));
                } else {
                    member_found = true;
                }
                i += 1;
            };
            
            assert(member_found, 'Member not in guild');

            guild.members = updated_members.span();
            guild.member_count -= 1;

            // Save the updated guild
            world.write_model(@guild);
            world.emit_event(@MemberRemoved {game_id, guild_id, member})
        }

        fn is_member(ref self: ContractState, game_id: usize, guild_id: usize, member: ContractAddress) -> bool {
            let mut world = self.world(@"pixelaw");
            let guild: Guild = world.read_model((game_id, guild_id));
            let mut is_member = false;
            let mut i = 0;
            loop {
                if i == guild.members.len() {
                    break;
                }
                if guild.members.at(i) == @member {
                    is_member = true;
                    break;
                }
                i += 1;
            };
            is_member
        }

        fn get_guild_contract_address(ref self: ContractState) -> ContractAddress {
            let guild_contract_address = get_contract_address();
            
            guild_contract_address
        }

        fn get_guild_points(ref self: ContractState , game_id: usize, guild_id: usize) -> usize {
            // Get the guild
            let mut world = self.world(@"pixelaw");
            let mut guild: Guild = world.read_model((game_id, guild_id));

            let mut guild_total_points = 0;
            let mut i = 0;
            loop {
                println!("member_count: {}", guild.member_count);
                if i >= guild.member_count {
                    break;
                }
                let mut player: Player = world.read_model(*guild.members.at(i));
                guild_total_points += player.num_commit;
                i += 1;
                println!("player.num_commit: {}", player.num_commit);
            };
            println!("contract: guild_total_points: {}", guild_total_points);
            guild_total_points
        }
    }
}
