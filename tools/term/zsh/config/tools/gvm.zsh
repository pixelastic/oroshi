# GVM - Lazy Loading
# Load GVM only when actually needed to improve ZSH startup time
export OROSHI_GVM_LOADED="0"

# Stop if gvm isn't installed
local gvmPath=~/.gvm/scripts/gvm
[[ -r $gvmPath ]] || return

# List of commands that should trigger GVM loading
# Main commands: gvm, go
export OROSHI_GVM_LAZYLOAD_ALIASES=(
  gvm
  go
)

# Create lazy-loading aliases for all these commands
for command in $OROSHI_GVM_LAZYLOAD_ALIASES; do
  alias $command="lazyloadGvm $command"
done

function lazyloadGvm {
  # Prevent infinite loop if already loaded
  if [[ $OROSHI_GVM_LOADED == "1" ]]; then
    "$@"
    return
  fi

  # Unregister all the aliases, so the commands refer to the real commands now
  for cmd in "${OROSHI_GVM_LAZYLOAD_ALIASES[@]}"; do
    unalias "$cmd" 2>/dev/null
  done

  # Source gvm for real
  source $gvmPath

  # Mark gvm as loaded
  OROSHI_GVM_LOADED="1"

  # Run the initial command that triggered the load
  "$@"
}
