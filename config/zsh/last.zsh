local DEBUG_STARTTIME=$(($(date +%s%N)/1000000))

# Commands in this file will be executed very last in the zsh init process.

# Direnv
# Loads environment variables from .envrc files
if [ $commands[direnv] ]; then
  eval "$(direnv hook zsh)"
  # Prevent direnv from displaying anything when switching to a new dir
  export DIRENV_LOG_FORMAT=
fi

# Load fzf for fuzzy finding in Ctrl-R in terminal
if [ -f ~/.fzf.zsh ]; then
  source ~/.fzf.zsh
fi

# Twilio cli
# Currently disabled: adds ~300ms on startup time
# local twilioCliAutocomplete=/home/tim/.twilio-cli/autocomplete/zsh_setup
# if [[ -r $twilioCliAutocomplete ]]; then
#   source $twilioCliAutocomplete
# fi

# Google Cloud SDK.
# Currently disabled: adds ~300ms on startup time
# if [ -f '/home/tim/local/src/google-cloud-sdk/path.zsh.inc' ]; then 
#   source '/home/tim/local/src/google-cloud-sdk/path.zsh.inc'; 
# fi

# NVM {{{
local nvmScript=~/.nvm/nvm.sh
if [[ -r $nvmScript ]]; then
  source $nvmScript
fi
# }}}

# Gvm
local gvmScript=~/.gvm/scripts/gvm
if [[ -r $gvmScript ]]; then
  source $gvmScript
  gvm use go1.11 &>/dev/null
fi

# Pyenv / pipenv
# Currently disabled: adds ~150ms on startup time
export PATH="/home/tim/.pyenv/bin:$PATH"
if [ $commands[pyenv] ]; then
  # Make sure pyenv is found by putting it first
  eval "$(pyenv init -)"
  # Do not prefix the current virtual env in the prompt, neither for pyenv nor
  # pipenv
  export PYENV_VIRTUALENV_DISABLE_PROMPT='1'
  export VIRTUAL_ENV_DISABLE_PROMPT='yes'
fi

# RVM
# RVM need to be loaded at the very last
local rvmScript=~/.rvm/scripts/rvm
if [[ -r $rvmScript ]]; then
 source $rvmScript
fi

local DEBUG_ENDTIME=$(($(date +%s%N)/1000000))
[[ $ZSH_DEBUG == 1 ]] && echo "[debug]: ${0:t}: $(($DEBUG_ENDTIME - $DEBUG_STARTTIME))ms"
