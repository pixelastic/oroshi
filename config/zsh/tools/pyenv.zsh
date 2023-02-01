# Pyenv
# Currently disabling this, as I don't much python
return
# Switch python version
[[ $commands[pyenv] ]] || return

# Init pyenv
eval "$(pyenv init - --no-rehash --path)"
