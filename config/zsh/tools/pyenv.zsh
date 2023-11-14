# Pyenv
# Stop if pyenv isn't installed
[[ -r ~/.pyenv/bin/pyenv ]] || return

export PYENV_ROOT="$HOME/.pyenv"

source /home/tim/.pyenv/completions/pyenv.zsh
