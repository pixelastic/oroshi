# NVM
# Stop if nvm isn't installed
[[ -r ~/.nvm/nvm.sh ]] || return

# We add the default node version to the path
local defaultNodeVersion="$(<~/.nvm/alias/default)"
path+=($HOME/.nvm/versions/node/v${defaultNodeVersion}/bin $path)

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

export OROSHI_NVM_LOADED="0"
alias node="lazyloadNvm node"
alias npm="lazyloadNvm npm"
alias nvm="lazyloadNvm nvm"
alias yarn="lazyloadNvm yarn"
function lazyloadNvm {
  # When zsh starts, aliases in function bodies are expanded. So the `nvm use`
  # in this function is actually transformed into `lazyloadNvm nvm use`, which
  # trigger an infinite recursive loop.
  # To short-circuit it, we check if nvm is already loaded, and if so, we simply
  # run the method passed
  if [[ $OROSHI_NVM_LOADED == "1" ]]; then
    "$@"
    return
  fi

  # Unregister all the aliases, so the commands refer to the real commands now
  unalias node npm nvm yarn;

  # Source nvm
  source ~/.nvm/nvm.sh --no-use

  # Mark nvm as loaded
  OROSHI_NVM_LOADED="1"

  # Initialize nvm for real, using the locally defined node version (if any)
  # Note: This is slow, but it's as far away as we can delay it
  nvm use --quiet &>/dev/null

  # Run initial command
  "$@"
}
