
function interact() {
  sozo \
  execute \
  0x2dc8bfc2e33f2e6966cbd9c2e0856d63250549c2a8258884cacb7ba35c427de \
  interact \
  -c 0,0,$1,"0xFFFF00FF"

  sleep 0.3
}

function create_proposal() {
  sozo \
  execute \
  0x481aadb9eab76d625be9d0ab0af0155c9f162fd3af1113abd0d0308ddb9346e \
  create_proposal \
  -c $1

  sleep 0.3
}

function activate_proposal() {
  sozo \
  execute \
  0x481aadb9eab76d625be9d0ab0af0155c9f162fd3af1113abd0d0308ddb9346e \
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
create_proposal 1,2,255,0 # 2->reset to white
create_proposal 1,1,3272281087,0 # 1-> add a color
create_proposal 1,3,100000,0 # 3-> extend end game
create_proposal 1,4,20,20 # 4-> expand area

# activate_proposal 1,13 # activate a proposal