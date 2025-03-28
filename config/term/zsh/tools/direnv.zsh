# Direnv
# Automatically load .envrc file when moving into a directory
[[ ! $commands[direnv] ]] && return

eval "$(direnv hook zsh)"
# Make it quietly
export DIRENV_LOG_FORMAT=
