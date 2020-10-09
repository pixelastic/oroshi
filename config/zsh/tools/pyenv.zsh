# Pyenv
# Switch python version
[[ $commands[pyenv] ]] || return

# Init pyenv
eval "$(pyenv init - --no-rehash)"
