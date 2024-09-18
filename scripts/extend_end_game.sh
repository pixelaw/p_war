#!/bin/bash
set -euo pipefail

function interact() {
  sozo \
    --profile $SCARB_PROFILE \
    execute \
    pixelaw-p_war_actions \
    interact \
    -c 0,0,$1,"0xFFFF00FF"

  sleep 0.3
}

function create_proposal() {
  sozo \
    --profile $SCARB_PROFILE \
    execute \
    pixelaw-propose \
    create_proposal \
    -c $1

  sleep 0.3
}

function activate_proposal() {
  sozo \
    --profile $SCARB_PROFILE \
    execute \
    pixelaw-propose \
    activate_proposal \
    -c $1

  sleep 0.3
}

# create game
interact 1,1

# paint a pixel
# interact 2,2

# fn create_proposal(game_id: usize, proposal_type: ProposalType, target_args_1: u32, target_args_2: u32) -> usize;
# addNewColor -> 2
create_proposal 1,1,3272281087,0 # 1-> add a color
create_proposal 1,2,255,0        # 2->reset to white
create_proposal 1,3,86410,0      # 3-> extend end game
create_proposal 1,4,20,20        # 4-> expand area

# activate_proposal 1,1 # activate a proposal
# activate_proposal 1,3 # activate a proposal
