# Pyenv
# Switch python version
[[ $commands[pyenv] ]] || return

# Init pyenv
eval "$(pyenv init - --no-rehash)"
# Do not prefix the current virtual env in the prompt, neither for pyenv nor
# pipenv
# export PYENV_VIRTUALENV_DISABLE_PROMPT='1'
# export VIRTUAL_ENV_DISABLE_PROMPT='yes'
