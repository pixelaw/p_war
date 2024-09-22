#!/bin/bash
set -euo pipefail
pushd $(dirname "$0")/..

# Get the profile from $SCARB_PROFILE
profile=${SCARB_PROFILE:-"dev"}

# make sure all components/systems are deployed
CORE_MODELS=("pixelaw-App" "pixelaw-AppName" "pixelaw-CoreActionsAddress" "pixelaw-Pixel" "pixelaw-Permissions" "pixelaw-QueueItem" "pixelaw-Instruction")
P_WAR_MODELS=("pixelaw-PWarPixel" "pixelaw-AllowedColor" "pixelaw-PaletteColors" "pixelaw-AllowedApp" "pixelaw-Game" "pixelaw-GameId" "pixelaw-GamePalette" "pixelaw-InPalette" "pixelaw-Player" "pixelaw-PixelRecoveryRate" "pixelaw-Proposal" "pixelaw-Board")
PROPOSE_MODELS=("pixelaw-AllowedColor" "pixelaw-GamePalette" "pixelaw-InPalette" "pixelaw-PaletteColors" "pixelaw-Proposal")
VOTING_MODELS=("pixelaw-PlayerVote" "pixelaw-Proposal" "pixelaw-Player")
GUILDS_MODELS=("pixelaw-Guild")

echo "Writing permissions for all actions in parallel"

grant_permissions() {
    local action=$1
    shift
    local models=("$@")
    for model in "${models[@]}"; do
        echo "Granting write permissions for $action to $model"
        sozo --profile $SCARB_PROFILE auth grant writer model:$model,pixelaw-$action
        sleep 0.02
    done
    wait
    echo "Write permissions for $action: Done"
}

grant_permissions "actions" "${CORE_MODELS[@]}"
grant_permissions "p_war_actions" "${P_WAR_MODELS[@]}"
grant_permissions "propose_actions" "${PROPOSE_MODELS[@]}"
grant_permissions "voting_actions" "${VOTING_MODELS[@]}"
grant_permissions "guild_actions" "${GUILDS_MODELS[@]}"

wait

echo "All permissions granted"

echo "Initializing actions"
sozo --profile $SCARB_PROFILE execute pixelaw-actions init
sozo --profile $SCARB_PROFILE execute pixelaw-p_war_actions init
wait

echo "All actions initialized"
