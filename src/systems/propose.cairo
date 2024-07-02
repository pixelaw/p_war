use starknet::{ContractAddress, get_caller_address, get_block_timestamp, contract_address_const};
use p_war::models::{game::{Game, Status}, proposal::{Proposal}};

use p_war::constants::{PROPOSAL_DURATION, NEEDED_YES_PX, DISASTER_SIZE};

// define the interface
#[dojo::interface]
trait IPropose {
    fn create_proposal(game_id: usize, proposal_type: u8, target_color: u32) -> usize;
    fn activate_proposal(game_id: usize, index: usize);
}

// dojo decorator
#[dojo::contract]
mod propose {
    use super::{IPropose, can_propose, NEEDED_YES_PX, PROPOSAL_DURATION, DISASTER_SIZE};
    use p_war::models::{
        game::{Game, Status, GameTrait},
        proposal::{Proposal, PixelRecoveryRate},
        board::{GameId, Board, Position, PWarPixel},
        player::{Player},
        allowed_app::AllowedApp,
        allowed_color::{ AllowedColor, PaletteColors, InPalette, GamePalette }
    };
    use p_war::systems::utils::{ recover_px };
    use pixelaw::core::utils::{get_core_actions, DefaultParameters};
    use pixelaw::core::actions::{
        IActionsDispatcher as ICoreActionsDispatcher,
        IActionsDispatcherTrait as ICoreActionsDispatcherTrait
    };
    use pixelaw::core::models::{ pixel::PixelUpdate, pixel::Pixel };
    use starknet::{ContractAddress, get_block_timestamp, get_caller_address, get_contract_address, get_tx_info};


    #[abi(embed_v0)]
    impl ProposeImpl of IPropose<ContractState> {

        fn create_proposal(world: IWorldDispatcher, game_id: usize, proposal_type: u8, target_color: u32) -> usize {
            // get the game
            let mut game = get!(world, game_id, (Game));
            assert(can_propose(game.status()), 'cannot submit proposal');

            let player_address = get_tx_info().unbox().account_contract_address;

            // recover px
            recover_px(world, game_id, player_address);

            // if this is first time for the caller, let's set initial px.
            let mut player = get!(
                world,
                (player_address),
                (Player)
            );


            // check the current px is eq or larger than cost_paint
            assert(player.current_px >= game.base_cost, 'not enough PX');

            // check the player is banned or not
            assert(player.is_banned == false, 'you are banned');


            let proposal = Proposal{
                game_id: game_id,
                index: game.proposal_idx,
                author: get_caller_address(),
                proposal_type: proposal_type,
                target_color: target_color,
                start: get_block_timestamp(),
                end: get_block_timestamp() + PROPOSAL_DURATION,
                yes_px: 0,
                no_px: 0,
                is_activated: false
            };

            game.proposal_idx += 1;

            set!(
                world,
                (
                    proposal,
                    game
                )
            );

            // consume px
            set!(
                world,
                (Player{
                    address: player.address,
                    max_px: player.max_px,
                    num_owns: player.num_owns,
                    num_commit: player.num_commit + game.base_cost,
                    current_px: player.current_px - game.base_cost,
                    last_date: get_block_timestamp(),
                    is_banned: false,
                }),
            );


            proposal.index
        }


        fn activate_proposal(world: IWorldDispatcher, game_id: usize, index: usize){
            // get the proposal
            let mut proposal = get!(world, (game_id, index), (Proposal));
            let current_timestamp = get_block_timestamp();
            assert(current_timestamp >= proposal.end, 'proposal period has not ended');
            assert(proposal.yes_px >= NEEDED_YES_PX, 'did not reach minimum yes_px');
            assert(proposal.yes_px > proposal.no_px, 'yes_px is less than no_px');
            assert(proposal.is_activated == false, 'this is already activated');

            // activate the proposal.
            if proposal.proposal_type == 1 {
                // AddNewColor
                // new feature: if the color is added, the oldest color become unusable.
                // let mut game = get!(
                //     world,
                //     (game_id),
                //     (Game)
                // );

                let new_color: u32 = proposal.target_color;
                let mut new_color_allowed = get!(world, (game_id, new_color), (AllowedColor));

                // only change it if it's not allowed
                if !new_color_allowed.is_allowed {
                    new_color_allowed.is_allowed = !new_color_allowed.is_allowed;

                    set!(
                        world, (new_color_allowed)
                    );

                    // check if color already is in the palette
                    let is_in_palette = get!(world, 
                        (game_id, new_color), (InPalette)
                    );

                    // if aready in the palette early return
                    if is_in_palette.value {
                        return;
                    }

                    let mut game_palette = get!(world, 
                        (game_id), (GamePalette)
                    );

                    // check if there's less colors in place
                    if game_palette.length < 9 {
                        set!(
                            world,
                            (
                                PaletteColors {
                                    game_id,
                                    idx: game_palette.length,
                                    color: new_color
                                },
                                InPalette {
                                    game_id,
                                    color: new_color,
                                    value: true
                                },
                                GamePalette {
                                    game_id,
                                    length: game_palette.length + 1
                                }
                            )
                        );
                    } else {
                        // get 0 idx
                        let oldest_color = get!(world, (game_id, 0), (PaletteColors));

                        let mut idx = 1;

                        loop {

                            let palette_color = get!(world, (game_id, idx), (PaletteColors));

                            set!(
                                world,
                                (
                                    PaletteColors {
                                        game_id,
                                        idx: idx - 1,
                                        color: palette_color.color
                                    }
                                )
                            );

                            idx = idx + 1;

                            if idx == 9 {
                                break;
                            };
                        };
                        
                        set!(
                            world,
                            (
                                InPalette {
                                    game_id,
                                    color: oldest_color.color,
                                    value: false
                                },

                                InPalette {
                                    game_id,
                                    color: new_color,
                                    value: true
                                },

                                PaletteColors {
                                  game_id,
                                  idx: 8,
                                  color: new_color  
                                },

                                // make it unusable
                                AllowedColor {
                                    game_id,
                                    color: oldest_color.color,
                                    is_allowed: false
                                },
                            )
                        );
                    };
                };
            } else if proposal.proposal_type == 2 {
                // Reset to white by color
                let core_actions = get_core_actions(world); // TODO: should we use p_war_actions insted of core_actions???
                let system = get_caller_address();
                
                // get the size of board
                let mut board = get!(
                    world,
                    (game_id),
                    (Board)
                );

                let origin: Position = board.origin;

                let target_color: u32 = proposal.target_color;
                let mut y: u32 = origin.y;


                loop {
                    if (y >= origin.y + board.height) {
                        break;
                    };
                    let mut x: u32 = origin.x;
                    loop {
                        if (x >= origin.x + board.width) {
                            break;
                        };

                        let pixel_info = get!(
                            world,
                            (x, y),
                            (Pixel)
                        );

                        if pixel_info.color == target_color {
                            // make it white
                            core_actions
                                .update_pixel(
                                    get_caller_address(), // is it okay?
                                    system,
                                    PixelUpdate {
                                        x,
                                        y,
                                        color: Option::Some(0xffffffff),
                                        timestamp: Option::None,
                                        text: Option::None,
                                        app: Option::Some(system),
                                        owner: Option::None,
                                        action: Option::None
                                    }
                                );
                            
                            // decrease the previous owner's num_owns
                            let position = Position {x, y};
                            let previous_pwarpixel = get!(
                                world,
                                (position),
                                (PWarPixel)
                            );

                            if (previous_pwarpixel.owner != starknet::contract_address_const::<0x0>()) {
                                // get the previous player's info
                                let mut previous_player = get!(
                                    world,
                                    (previous_pwarpixel.owner),
                                    (Player)
                                );

                                previous_player.num_owns -= 1;
                                set!(
                                    world,
                                    (previous_player)
                                );
                            };

                        };
                        x += 1;
                    };
                    y += 1;
                };
            } else {
                return;
            };

            // make it activated.
            proposal.is_activated = true;

            set!(
                world,
                (proposal)
            );

            // // Qustion: should we panish the author if the proposal is denied?
            // // add author's commitment points
            // let mut author = get!(
            //     world,
            //     (proposal.author),
            //     (Player)
            // );

            // author.num_commit += 10; // get 10 commitments if the proposal is accepted
            // set!(
            //     world,
            //     (author)
            // );
        }
    }
}

fn can_propose(status: Status) -> bool {
    status == Status::Pending || status == Status::Ongoing
}