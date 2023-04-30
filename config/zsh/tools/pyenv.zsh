# Pyenv
# Stop if pyenv isn't installed
[[ -r ~/.pyenv/bin/pyenv ]] || return

export PYENV_ROOT="$HOME/.pyenv"

# Lazyload pyenv automatically when needed:
# - pyenv
# - all its shims
# - ai-powered tools like sgpt and whisper that rely on python
export OROSHI_PYENV_LAZYLOAD_ALIASES=(
	pyenv
	~/.pyenv/shims/*(:t)
	~/.oroshi/scripts/bin/ai/*(:t)
)
for command in $OROSHI_PYENV_LAZYLOAD_ALIASES; do
	alias $command="lazyloadPyenv $command"
done

function lazyloadPyenv {
	# Unregister all the aliases, so the commands refer to the real commands now
	unalias $OROSHI_PYENV_LAZYLOAD_ALIASES

	# Init pyenv
	eval "$(pyenv init - --no-rehash --path)"

	# Run initial command
	"$@"
}

source /home/tim/.pyenv/completions/pyenv.zsh
