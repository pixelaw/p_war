use starknet::{ContractAddress, get_caller_address};
use p_war::models::payments::{GamePayments, PlayerPayment, TreasuryInfo};
use p_war::models::game::Game;
use p_war::models::guilds::Guild;

#[starknet::interface]
pub trait IPayments<T> {
    fn initialize_game_payments(ref self: T, game_id: u32, participation_fee: u256);
    fn pay_participation_fee(ref self: T, game_id: u32);
    fn payout_winning_guild(ref self: T, game_id: u32, winning_guild_id: u32);
    fn set_treasury_address(ref self: T, treasury_address: ContractAddress);
}

#[dojo::contract(namespace: "pixelaw", nomapping: true)]
mod payments {
    // use super::*;

    use dojo::model::{ModelStorage, ModelValueStorage};
    use dojo::event::EventStorage;

    const PRIZE_POOL_PERCENTAGE: u256 = 90;
    const TREASURY_PERCENTAGE: u256 = 10;

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        ParticipationFeePaid: ParticipationFeePaid,
        WinningGuildPaidOut: WinningGuildPaidOut
    }

    #[derive(Drop, starknet::Event)]
    struct ParticipationFeePaid {
        game_id: u32,
        player: ContractAddress,
        amount: u256
    }

    #[derive(Drop, starknet::Event)]
    struct WinningGuildPaidOut {
        game_id: u32,
        guild_id: u32,
        total_amount: u256
    }

    #[abi(embed_v0)]
    impl PaymentsImpl of IPayments<ContractState> {
        fn initialize_game_payments(ref self: ContractState, game_id: u32, participation_fee: u256) {
            let game_payments = GamePayments {
                game_id: game_id,
                participation_fee: participation_fee,
                prize_pool: 0,
                treasury_balance: 0
            };
            set!(world, (game_payments));
        }

        fn pay_participation_fee(ref self: ContractState, game_id: u32) {
            let caller = get_caller_address();
            let mut game_payments = get!(world, game_id, (GamePayments));
            let fee = game_payments.participation_fee;

            // TODO: Implement actual token transfer here
            // For now, we'll just update the balances

            let prize_pool_amount = (fee * PRIZE_POOL_PERCENTAGE) / 100;
            let treasury_amount = (fee * TREASURY_PERCENTAGE) / 100;

            game_payments.prize_pool += prize_pool_amount;
            game_payments.treasury_balance += treasury_amount;

            let player_payment = PlayerPayment {
                game_id: game_id,
                player: caller,
                amount_paid: fee
            };

            set!(world, (game_payments, player_payment));

            emit!(world, ParticipationFeePaid { game_id: game_id, player: caller, amount: fee });
        }

        fn payout_winning_guild(ref self: ContractState, game_id: u32, winning_guild_id: u32) {
            let mut game_payments = get!(world, game_id, (GamePayments));
            let guild = get!(world, (game_id, winning_guild_id), (Guild));
            
            let total_payout = game_payments.prize_pool;
            let members_count = guild.member_count;
            let payout_per_member = total_payout / members_count.into();

            //assert the game state

            // Iterate through guild members and pay each one
            let mut i = 0;
            loop {
                if i == guild.members.len() {
                    break;
                }
                let member = *guild.members.at(i);
                // TODO: Implement actual token transfer to each member
                // For now, we'll just print the payout
                println!("Paying {} to member {}", payout_per_member, member);
                i += 1;
            };

            // Reset the prize pool
            game_payments.prize_pool = 0;
            set!(world, (game_payments));

            emit!(world, WinningGuildPaidOut { game_id: game_id, guild_id: winning_guild_id, total_amount: total_payout });
        }

        fn set_treasury_address(ref self: ContractState, treasury_address: ContractAddress) {
            let treasury_info = TreasuryInfo {
                dummy_key: 0,
                treasury_address: treasury_address
            };
            set!(world, (treasury_info));
        }
    }
}