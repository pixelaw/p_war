#!/bin/bash
set -euo pipefail
# shellcheck disable=SC2046
pushd $(dirname "$0")/..

echo "Building Contracts"

# build contracts
sozo build

echo "Deploying Contracts"

# deploy contracts
sozo migrate plan
sozo migrate apply

echo "Granting Authorization"

# grant writer to p_war_actions
sozo auth grant writer AllowedApp,0x2dc8bfc2e33f2e6966cbd9c2e0856d63250549c2a8258884cacb7ba35c427de
sozo auth grant writer AllowedColor,0x2dc8bfc2e33f2e6966cbd9c2e0856d63250549c2a8258884cacb7ba35c427de
sozo auth grant writer Board,0x2dc8bfc2e33f2e6966cbd9c2e0856d63250549c2a8258884cacb7ba35c427de
sozo auth grant writer GameId,0x2dc8bfc2e33f2e6966cbd9c2e0856d63250549c2a8258884cacb7ba35c427de
sozo auth grant writer Game,0x2dc8bfc2e33f2e6966cbd9c2e0856d63250549c2a8258884cacb7ba35c427de
sozo auth grant writer GamePalette,0x2dc8bfc2e33f2e6966cbd9c2e0856d63250549c2a8258884cacb7ba35c427de
sozo auth grant writer InPalette,0x2dc8bfc2e33f2e6966cbd9c2e0856d63250549c2a8258884cacb7ba35c427de 
sozo auth grant writer PaletteColors,0x2dc8bfc2e33f2e6966cbd9c2e0856d63250549c2a8258884cacb7ba35c427de 
sozo auth grant writer Player,0x2dc8bfc2e33f2e6966cbd9c2e0856d63250549c2a8258884cacb7ba35c427de
sozo auth grant writer PixelRecoveryRate,0x2dc8bfc2e33f2e6966cbd9c2e0856d63250549c2a8258884cacb7ba35c427de
sozo auth grant writer PWarPixel,0x2dc8bfc2e33f2e6966cbd9c2e0856d63250549c2a8258884cacb7ba35c427de

# grant writer to propose
sozo auth grant writer AllowedColor,0x481aadb9eab76d625be9d0ab0af0155c9f162fd3af1113abd0d0308ddb9346e
sozo auth grant writer GamePalette,0x481aadb9eab76d625be9d0ab0af0155c9f162fd3af1113abd0d0308ddb9346e
sozo auth grant writer InPalette,0x481aadb9eab76d625be9d0ab0af0155c9f162fd3af1113abd0d0308ddb9346e 
sozo auth grant writer PaletteColors,0x481aadb9eab76d625be9d0ab0af0155c9f162fd3af1113abd0d0308ddb9346e 
sozo auth grant writer Proposal,0x481aadb9eab76d625be9d0ab0af0155c9f162fd3af1113abd0d0308ddb9346e
sozo auth grant writer Player,0x481aadb9eab76d625be9d0ab0af0155c9f162fd3af1113abd0d0308ddb9346e
sozo auth grant writer Game,0x481aadb9eab76d625be9d0ab0af0155c9f162fd3af1113abd0d0308ddb9346e

# grant writer to voting
sozo auth grant writer Proposal,0x405fdfa192f0a756c50dc081d0a4a10afbc5ed29a774665ab6a34cef4d4a549
sozo auth grant writer Player,0x405fdfa192f0a756c50dc081d0a4a10afbc5ed29a774665ab6a34cef4d4a549
sozo auth grant writer PlayerVote,0x405fdfa192f0a756c50dc081d0a4a10afbc5ed29a774665ab6a34cef4d4a549

echo "Initializing p_war"

# # initialize p_war_actions
sozo execute 0x2dc8bfc2e33f2e6966cbd9c2e0856d63250549c2a8258884cacb7ba35c427de init

# echo "Default authorizations have been successfully set."
