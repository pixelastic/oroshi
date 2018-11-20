# Commands in this file will be executed very last in the zsh init process.
# NVM {{{
source $zshConfigDir/nvm.zsh
# }}}

# Direnv {{{
# Loads environment variables from .envrc files
if [ $commands[direnv] ]; then
  eval "$(direnv hook zsh)"
  # Prevent direnv from displaying anything when switching to a new dir
  export DIRENV_LOG_FORMAT=
fi
# }}}


# Gvm
local gvmScript=~/.gvm/scripts/gvm
if [[ -r $gvmScript ]]; then
  source $gvmScript
  gvm use go1.11 &>/dev/null
fi

# Adding Chromium compilation tools to the path if present
local chromiumDepotTools=~/local/src/chromium/depot_tools
if [[ -r $chromiumDepotTools ]]; then
  export PATH=$PATH:$chromiumDepotTools
fi

# Pyenv / pipenv
export PATH="/home/tim/.pyenv/bin:$PATH"
if [ $commands[pyenv] ]; then
  # Make sure pyenv is found by putting it first
  eval "$(pyenv init -)"
  # Do not prefix the current virtual env in the prompt, neither for pyenv nor
  # pipenv
  export PYENV_VIRTUALENV_DISABLE_PROMPT='1'
  export VIRTUAL_ENV_DISABLE_PROMPT='yes'
fi

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/tim/local/src/google-cloud-sdk/path.zsh.inc' ]; then 
  source '/home/tim/local/src/google-cloud-sdk/path.zsh.inc'; 
fi

# Load fzf for fuzzy finding in Ctrl-R in terminal
if [ -f ~/.fzf.zsh ]; then
  source ~/.fzf.zsh
fi

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
