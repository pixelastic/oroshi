# NVM
# Switch node version
[[ -r ~/.nvm/nvm.sh ]] || return

# We add the default node version to the path
local defaultNodeVersion="$(<~/.nvm/alias/default)"
export PATH="$HOME/.nvm/versions/node/v${defaultNodeVersion}/bin:$PATH"

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
  source ~/.nvm/nvm.sh
}
