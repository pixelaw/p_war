use starknet::{ContractAddress, get_caller_address};
use p_war::models::guilds::Guild;
use p_war::models::game::Game;
use p_war::models::player::Player;

#[dojo::interface]
trait IGuild {
    fn create_guild(ref world: IWorldDispatcher, game_id: usize, guild_name: felt252) -> usize; //returns guild ID
    fn add_member(ref world: IWorldDispatcher, game_id: usize, guild_id: usize, member: ContractAddress);
    fn remove_member(ref world: IWorldDispatcher, game_id: usize, guild_id: usize, member: ContractAddress);
    fn get_guild_points(ref world: IWorldDispatcher, game_id: usize, guild_id: usize) -> usize;
}

#[dojo::contract(namespace: "pixelaw", nomapping: true)]
mod guild_actions {

    #[abi(embed_v0)]
    impl GuildImpl of IGuild<ContractState> {
        fn create_guild(ref world: IWorldDispatcher, game_id: usize, guild_name: felt252) -> usize {
            let caller = get_caller_address();
            
            // Check if the game exists and get the game data
            let mut game = get!(world, game_id, (Game));
            assert(game.id == game_id, 'Game does not exist');

            // Use the current guild_count as the new guild_id
            let guild_id = game.guild_count;
            game.guild_ids.append(guild_id);
            game.guild_count += 1;

            // Create the new guild
            let new_guild = Guild {
                game_id: game_id,
                guild_id: guild_id,
                guild_name: guild_name,
                creator: caller,
                members: array![caller].span()
            };

            //set member count to 1
            new_guild.member_count+= 1;

            // Save the guild and update the game
            set!(world, (new_guild, game));

            guild_id
        }

        fn add_member(ref world: IWorldDispatcher, game_id: usize, guild_id: usize, new_member: ContractAddress) {
            let caller = get_caller_address();
            
            // Get the guild
            let mut guild = get!(world, (game_id, guild_id), (Guild));
            
            // Check if the caller is the creator
            assert(guild.creator == caller, 'Only creator can add members');

            // Check if the member is not already in the guild
            assert(!guild.members.contains(new_member), 'New Member already in guild');

            // Add the new member
            guild.members.append(new_member);
            
            //update member count
            guild.member_count += 1;

            // Save the updated guild
            set!(world, (guild));
        }

        fn remove_member(ref world: IWorldDispatcher, game_id: usize, guild_id: usize, member: ContractAddress) {
            let caller = get_caller_address();
            
            // Get the guild
            let mut guild = get!(world, (game_id, guild_id), (Guild));
            
            // Check if the caller is the creator
            assert(guild.creator == caller, 'Only creator can remove members');

            // Check if the member is in the guild
            assert(guild.members.contains(member), 'Member not in guild');

            // Remove the member
            let mut updated_members = ArrayTrait::new();
            let mut i = 0;
            loop {
                if i == guild.member_count {
                    break;
                }
                if *guild.members.at(i) != member {
                    updated_members.append(*guild.members.at(i));
                }
                i += 1;
            };
            guild.members = updated_members.span();

            // Save the updated guild
            set!(world, (guild));
        }

        //this function is very inefficient. better implementation is updating guild points when member points are updated.
        fn get_guild_points(ref world: IWorldDispatcher, game_id: usize, guild_id: usize) -> usize {
            // Get the guild
            let mut guild = get!(world, (game_id, guild_id), (Guild));

            let mut guild_total_points = 0;
            let mut i = 0;
            loop {
                if i >= guild.member_count {
                    break;
                }
                let mut player = get!(
                    world,
                    (*guild.members.at(i), game_id),
                    (Player)
                );
                guild_total_points += player.num_commit;
            }
        }
    }
}