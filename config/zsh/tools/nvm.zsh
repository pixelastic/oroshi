# NVM
# Switch node version
[[ -r ~/.nvm/nvm.sh ]] || return

# We add the default node version to the path
local defaultNodeVersion="$(<~/.nvm/alias/default)"
export PATH="$HOME/.nvm/versions/node/v${defaultNodeVersion}/bin:$PATH"

# This enables lazyloading of nvm. It initially creates an alias. When the alias
# is called it unregister itself, load nvm and go through with the command. Next
# nvm calls will use the real nvm
alias nvm="unalias nvm; source ~/.nvm/nvm.sh; nvm $@"
