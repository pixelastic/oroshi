# NVM
export OROSHI_NVM_LOADED="0"
# Stop if nvm isn't installed
[[ -r ~/.nvm/nvm.sh ]] || return

# Running `nvm use` is slow. Sourcing nvm.sh actually runs `nvm use` by default
# (unless --no-use is passed). No matter what we do, `nvm use` will always be
# slow.
#
# So what we'll do instead, is to defer the call to `nvm use` as far away as
# possible. We won't do it automatically when zsh starts, when the prompt is
# displayed, and not even when switching directories.
#
# Instead, we'll call it once, the first time we actually need it: whenever we
# call node, npm, yarn or nvm.
#
# We'll manually craft something similar to the zsh autoload functions. We
# define dummy node, npm, yarn and nvm function that don't do much. They load
# nvm for real, destroy themselves, and run the real command

# Add aliases for all command that would need node, so nvm loads it on first
# invocation
export OROSHI_NVM_LAZYLOAD_ALIASES=(
	node
	npm
	nvm
	yarn
	yarn-link-remove
	yarn-link-remove-all
	yarn-run
	yarn-update
	node-module-add
	node-module-remove
	node-module-list
	node-module-list-raw
)
for command in $OROSHI_NVM_LAZYLOAD_ALIASES; do
	alias $command="lazyloadNvm $command"
done

function lazyloadNvm {
	# When zsh starts, aliases in function bodies are expanded. So the `nvm use`
	# in this function is actually transformed into `lazyloadNvm nvm use`, which
	# triggers an infinite recursive loop.
	# To short-circuit it, we check if nvm is already loaded, and if so, we simply
	# run the method passed
	if [[ $OROSHI_NVM_LOADED == "1" ]]; then
		"$@"
		return
	fi

	# Unregister all the aliases, so the commands refer to the real commands now
	unalias $OROSHI_NVM_LAZYLOAD_ALIASES

	# Source nvm
	source ~/.nvm/nvm.sh --no-use

	# Mark nvm as loaded
	OROSHI_NVM_LOADED="1"

	# ZSH completion methods set a PREFIX variable internally that leaks to here
	# when lazyloadNvm is called from a zsh completion. Unfortunately, nvm fails
	# if such a variable is set, so we unset it here
	unset PREFIX

	# Initialize nvm for real, using the locally defined node version (if any)
	# Note: This is slow, but it's as far away as we can delay it
	nvm use --silent &>/dev/null

	# Run initial command
	"$@"
}
