# NVM
# Switch node version
[[ -r ~/.nvm/nvm.sh ]] || return

# We add the default node version to the path
local defaultNodeVersion="$(<~/.nvm/alias/default)"
path+=($HOME/.nvm/versions/node/v${defaultNodeVersion}/bin $path)

# We don't load nvm on startup as it takes some time. 
# Instead, we define an alias that will load it and then execute it. 
# On first load, it will delete the alias, leaving only the real nvm for future
# commands
alias nvm="lazyloadNvm && nvm"
function lazyloadNvm {
  # If nvm is a function, and not an alias, it means it has been correctly
  # loaded. So we do nothing.  This can happen when using the alias inside
  # a function because aliases are expanded in the function body
  [[ ! $aliases[nvm] ]] && return;

  unalias nvm;

  # Using --no-use prevent nvm from running `nvm use` automatically, which takes
  # about 800ms
  source ~/.nvm/nvm.sh --no-use
}

# Automatically switch to local node version when entering a directory with
# .nvmrc
function chpwdAutoNvmUse() {
  local nvmrcPath="$(find-up .nvmrc)"

  # No local version defined, nothing to do
  if [[ $nvmrcPath = '' ]]; then
    return
  fi

  # Local version is not even installed
  # We won't install it automatically as it takes too long
  expectedVersion="$(<$nvmrcPath)"
  if [[ ! -d ~/.nvm/versions/node/v${expectedVersion} ]]; then
    return
  fi

  # Local version is already the right one, nothing to do
  local currentVersion="$(node --version)"
  currentVersion=${currentVersion:s/v/}
  if [[ $currentVersion == $expectedVersion ]]; then
    return
  fi

  # Switch to the correct nvm version
  nvm use --silent
}
autoload -U add-zsh-hook
add-zsh-hook chpwd chpwdAutoNvmUse
chpwdAutoNvmUse
