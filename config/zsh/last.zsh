# Commands in this file will be executed very last in the zsh init process.

# NVM {{{
source $zshConfigDir/nvm.zsh
# }}}

# RVM need to be loaded at the very last
local rvmScript=~/.rvm/scripts/rvm
if [[ -r $rvmScript ]]; then
  if [[ ! -z "$TMUX" ]]; then
    # It seems that $GEM_HOME and $GEM_PATH are not correctly set when starting
    # a tmux session, so we'll re-source the `rvm` function and manually set the
    # default. We suppress errors for not polluting the display.
    source $rvmScript &>/dev/null
    rvm use 2.3.1 &>/dev/null
  else
    # We simply source the rvmScript otherwise
    source $rvmScript
    rvm use 2.3.1 &>/dev/null
  fi
fi

# Adding Chromium compilation tools to the path if present
local chromiumDepotTools=~/local/src/chromium/depot_tools
if [[ -r $chromiumDepotTools ]]; then
  export PATH=$PATH:$chromiumDepotTools
fi
