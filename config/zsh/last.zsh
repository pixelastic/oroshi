# Commands in this file will be executed very last in the zsh init process.

# NVM {{{
local nvmScript=~/.nvm/nvm.sh
if [[ -r $nvmScript ]]; then
  source $nvmScript
	nvm use 0.12 &>/dev/null
fi
# }}}

# RVM need to be loaded at the very last
local rvmScript=~/.rvm/scripts/rvm
if [[ -r $rvmScript ]]; then
  if [[ ! -z "$TMUX" ]]; then
    # It seems that $GEM_HOME and $GEM_PATH are not correctly set when starting
    # a tmux session, so we'll re-source the `rvm` function and manually set the
    # default. We suppress errors for not polluting the display.
    source $rvmScript &>/dev/null
    rvm use 2.2.2 &>/dev/null
  else
    # We simply source the rvmScript otherwise
    source $rvmScript
  fi
fi


