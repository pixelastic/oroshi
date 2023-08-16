# Husky runs its precommit in a sandboxed environment that doesn't inherit
# much from the terminal that launched it. For example, it doesn't know about
# nvm, so has trouble finding the right version of node/yarn.
#
# One could install node/yarn globally, but then the pre-commit tests and lint
# might run with the wrong node version, so it's better to force husky to load
# nvm before each hook, to be sure to run the right version

# Step One: Define the NVM_DIR variable. Without it, nvm can't find its binaries
export NVM_DIR="$HOME/.nvm"
# Step Two: Load nvm source code
. "$NVM_DIR/nvm.sh"
# Step Three: Switch to the defined version of nvm, silently
[ -f ".nvmrc" ] && nvm use --silent
