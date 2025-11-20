#!/bin/zsh

# Sets the Docker mount point
# When calling this make certain you do . ./scripts/setrepohome.zsh
# The first dot means the shell runs the script in the current shell environment, not in a subshell.
MRHOME=$HOME/StrandsKitchen/MidiApps/MidiRouterProject/MidiRouter
export GITHUB_WORKSPACE="$MRHOME"


