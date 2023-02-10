# Set a config value
# Usage:
# $ git-config-set branch.master.remote origin # Update the value
function git-config-set() {;
  local configName="$1"
  local configValue="$2"

  # A config name is required
  if [[ "$configName" == '' ]]; then
    echo "✘ You must pass a config name"
    return 1
  fi

  # A value is required
  if [[ "$configValue" == '' ]]; then
    echo "✘ You must pass a config value"
    return 1
  fi

  # Removing it first
  git-config-remove "$configName"

  git config --add "$configName" "$configValue"
}
