use starknet::{ContractAddress, get_caller_address};
use p_war::models::guilds::Guild;
use p_war::models::game::Game;

#[dojo::interface]
trait IGuild {
    fn create_guild(game_id: usize, guild_name: felt252) -> usize;
    fn add_member(game_id: usize, guild_id: usize, member: ContractAddress);
    fn remove_member(game_id: usize, guild_id: usize, member: ContractAddress);


#[dojo::contract]
mod guild_actions {

    #[abi(embed_v0)]
    impl GuildImpl of IGuild<ContractState> {
        fn create_guild(world: IWorldDispatcher, game_id: usize, guild_name: felt252) -> usize {
            let caller = get_caller_address();
            
            // Check if the game exists and get the game data
            let mut game = get!(world, game_id, (Game));
            assert(game.id == game_id, 'Game does not exist');

            // Use the current guild_count as the new guild_id
            let guild_id = game.guild_count;
            game.guild_count += 1;

            // Create the new guild
            let new_guild = Guild {
                game_id: game_id,
                guild_id: guild_id,
                guild_name: guild_name,
                creator: caller,
                members: array![caller].span()
            };

            // Save the guild and update the game
            set!(world, (new_guild, game));

            guild_id
        }

        fn add_member(world: IWorldDispatcher, game_id: usize, guild_id: usize, member: ContractAddress) {
            let caller = get_caller_address();
            
            // Get the guild
            let mut guild = get!(world, (game_id, guild_id), (Guild));
            
            // Check if the caller is the creator
            assert(guild.creator == caller, 'Only creator can add members');

            // Check if the member is not already in the guild
            assert(!guild.members.contains(member), 'Member already in guild');

            // Add the new member
            let mut new_members = guild.members.to_array();
            new_members.append(member);
            guild.members = new_members.span();

            // Save the updated guild
            set!(world, (guild));
        }

        fn remove_member(world: IWorldDispatcher, game_id: usize, guild_id: usize, member: ContractAddress) {
            let caller = get_caller_address();
            
            // Get the guild
            let mut guild = get!(world, (game_id, guild_id), (Guild));
            
            // Check if the caller is the creator
            assert(guild.creator == caller, 'Only creator can remove members');

            // Check if the member is in the guild
            assert(guild.members.contains(member), 'Member not in guild');

            // Remove the member
            let mut new_members = ArrayTrait::new();
            let mut i = 0;
            loop {
                if i == guild.members.len() {
                    break;
                }
                if *guild.members.at(i) != member {
                    new_members.append(*guild.members.at(i));
                }
                i += 1;
            };
            guild.members = new_members.span();

            // Save the updated guild
            set!(world, (guild));
        }
    }
}