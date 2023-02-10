# Display a config value
# Usage:
# $ git-config-get branch.master.remote  # Display the value
function git-config-get() {
  local configName="$1"

  if [[ "$configName" == '' ]]; then
    echo "✘ You must pass a config name"
    return 1
  fi

  local configValue="$(git config --get "$configName" 2>/dev/null)"
  if [[ "$configValue" == '' ]]; then
    return 1
  fi

  echo $configValue
}
