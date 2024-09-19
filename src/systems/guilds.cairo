use p_war::models::game::Game;
use p_war::models::guilds::Guild;
use p_war::models::player::Player;
use starknet::{ContractAddress, get_caller_address};

#[dojo::interface]
trait IGuild {
    fn create_guild(
        ref world: IWorldDispatcher, game_id: usize, guild_name: felt252
    ) -> usize; //returns guild ID
    fn add_member(
        ref world: IWorldDispatcher, game_id: usize, guild_id: usize, new_member: ContractAddress
    );
    fn remove_member(
        ref world: IWorldDispatcher, game_id: usize, guild_id: usize, member: ContractAddress
    );
    fn get_guild_points(ref world: IWorldDispatcher, game_id: usize, guild_id: usize) -> usize;
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

    use super::{IGuild};

    #[abi(embed_v0)]
    impl GuildImpl of IGuild<ContractState> {
        fn create_guild(ref world: IWorldDispatcher, game_id: usize, guild_name: felt252) -> usize {
            let caller = get_caller_address();

            // Check if the game exists and get the game data
            let mut game = get!(world, game_id, (Game));
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
            set!(world, (new_guild, game));
            println!("set guild");
            guild_id
        }

        fn add_member(
            ref world: IWorldDispatcher,
            game_id: usize,
            guild_id: usize,
            new_member: ContractAddress
        ) {
            let caller = get_caller_address();

            // Get the guild
            let mut guild = get!(world, (game_id, guild_id), (Guild));

            // Check if the caller is the creator
            assert(guild.creator == caller, 'Only creator can add members');

            // Check if the member is not already in the guild
            let mut is_member = false;
            let mut i = 0;
            loop {
                if i == guild.members.len() {
                    break;
                }
                if guild.members.at(i) == @new_member {
                    is_member = true;
                }
                i += 1;
            };
            println!("is_member: {}", is_member);
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
            set!(world, (guild));
        }

        fn remove_member(
            ref world: IWorldDispatcher, game_id: usize, guild_id: usize, member: ContractAddress
        ) {
            let caller = get_caller_address();

            // Get the guild
            let mut guild = get!(world, (game_id, guild_id), (Guild));

            // Check if the caller is the creator
            assert(guild.creator == caller, 'Only creator can remove members');

            // Check if the member is in the guild
            let mut is_member = false;
            let mut i = 0;
            loop {
                if i == guild.members.len() {
                    break;
                }
                if guild.members.at(i) == @member {
                    is_member = true;
                }
                i += 1;
            };
            println!("is_member: {}", is_member);
            assert(is_member == true, 'Member not in guild');

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
            guild.member_count -= 1;

            // Save the updated guild
            set!(world, (guild));
        }

        // //this function is very inefficient. better implementation is updating guild points when
        // member points are updated.
        fn get_guild_points(ref world: IWorldDispatcher, game_id: usize, guild_id: usize) -> usize {
            // Get the guild
            let mut guild = get!(world, (game_id, guild_id), (Guild));

            let mut guild_total_points = 0;
            let mut i = 0;
            loop {
                println!("member_count: {}", guild.member_count);
                if i >= guild.member_count {
                    break;
                }
                let mut player = get!(world, (*guild.members.at(i), game_id), (Player));
                println!("player.num_commit: {}", player.num_commit);
                guild_total_points += player.num_commit;
                i += 1;
            };
            println!("contract: guild_total_points: {}", guild_total_points);
            guild_total_points
        }
    }
}
