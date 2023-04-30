# shellcheck disable=SC2154
# Node

# Add an icon if in a monorepo
function oroshi-prompt-populate:node_monorepo() {
  OROSHI_PROMPT_PARTS[node_monorepo]=""
  (( $GIT_DIRECTORY_IS_REPOSITORY )) || return
  yarn-is-monorepo || return

  OROSHI_PROMPT_PARTS[node_monorepo]="%F{$COLOR_ALIAS_LOCAL_DEPENDENCY} %f"
}

# Display project node version
# -  (red) if no global node
# - {nothing} if not a node repo (no .nvmrc)
# -  X.Y.Z (grey) if local version detected, but nvm hasn't been loaded
# -  X.Y.Z (red) if local version isn't installed
# -  X.Y.Z (yellow) if local and current don't match match
# -  X.Y.Z (green) if local and current match
function oroshi-prompt-populate:node_version() {
  OROSHI_PROMPT_PARTS[node_version]=""

  # Not even a system-wide node installation
  if [[ ! -v commands[node] ]]; then
    OROSHI_PROMPT_PARTS[node_version]+="%F{$COLOR_ALIAS_ERROR} %f"
    return
  fi

  local nvmrcPath="$(find-up .nvmrc)"

  # No local version defined, using global one
  if [[ $nvmrcPath = '' ]]; then
    local globalVersion="$(node --version)"
    OROSHI_PROMPT_PARTS[node_version]+="%F{$COLOR_ALIAS_WARNING} $globalVersion%f"
    return
  fi

  local expectedVersion="$(<$nvmrcPath)"

  # If nvm isn't loaded, we display in gray
  if [[ $OROSHI_NVM_LOADED == "0" ]]; then
    OROSHI_PROMPT_PARTS[node_version]+="%F{$COLOR_ALIAS_COMMENT} $expectedVersion%f"
    return
  fi

  # Local version is not even installed
  if [[ ! -d ~/.nvm/versions/node/v${expectedVersion} ]]; then
    OROSHI_PROMPT_PARTS[node_version]+="%F{$COLOR_ALIAS_ERROR} $expectedVersion%f"
    return
  fi

  local currentVersion="${$(node --version):s/v/}"

  # Local version is different than the current node version
  if [[ $currentVersion != "$expectedVersion" ]]; then
    OROSHI_PROMPT_PARTS[node_version]+="%F{$COLOR_ALIAS_WARNING} $expectedVersion%f"
    return
  fi

  # Local version is the same as the one in use
  OROSHI_PROMPT_PARTS[node_version]+="%F{$COLOR_ALIAS_SUCCESS} $expectedVersion%f"
}

