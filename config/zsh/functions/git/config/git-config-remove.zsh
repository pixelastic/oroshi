# Remove a config value
# Usage:
# $ git-config-remove branch.master.remote  # Remove the value
function git-config-remove() {
  local configName="$1"

  if [[ "$configName" == '' ]]; then
    echo "✘ You must pass a config name"
    return 1
  fi

  git config --unset "$configName" &>/dev/null

}
