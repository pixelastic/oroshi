# Pyenv
# Switch python version
[[ $commands[pyenv] ]] || return
# Make sure pyenv is found by putting it first
eval "$(pyenv init -)"
# Do not prefix the current virtual env in the prompt, neither for pyenv nor
# pipenv
export PYENV_VIRTUALENV_DISABLE_PROMPT='1'
export VIRTUAL_ENV_DISABLE_PROMPT='yes'
