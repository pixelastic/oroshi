# Pyenv
# Switch python version
[[ $commands[pyenv] ]] || return
# Make sure pyenv is found by putting it first
# --no-rehash should make this pretty quick
# https://github.com/pyenv/pyenv/issues/571
eval "$(pyenv init - --no-rehash)"
# Do not prefix the current virtual env in the prompt, neither for pyenv nor
# pipenv
export PYENV_VIRTUALENV_DISABLE_PROMPT='1'
export VIRTUAL_ENV_DISABLE_PROMPT='yes'
