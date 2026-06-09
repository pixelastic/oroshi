# shellcheck disable=SC2154
# Node

# Add an icon if in a monorepo
function oroshi-prompt-populate:node_monorepo() {
  OROSHI_PROMPT_PARTS[node_monorepo]=""
  (( $GIT_DIRECTORY_IS_REPOSITORY )) || return
  yarn-is-monorepo || return

  OROSHI_PROMPT_PARTS[node_monorepo]="%F{$colors[LOCAL_DEPENDENCY]}$ICONS[node-monorepo] %f"
}

# Display project node version
#
# - $ICONS[node] (red) if no global node
#
# When not in a node repo
# - {nothing} if nvm hasn't been loaded
# - $ICONS[node] (green) if using the default version
# - $ICONS[node] X.Y.Z (violet) if using a specific node version
#
# When in a node repo
# - $ICONS[node] X.Y.Z (grey) if local version detected, but nvm hasn't been loaded
# - $ICONS[node] X.Y.Z (red) if local version isn't installed
# - $ICONS[node] X.Y.Z (yellow) if local and current don't match
# - $ICONS[node] X.Y.Z (green) if local and current match
function oroshi-prompt-populate:node_version() {
  OROSHI_PROMPT_PARTS[node_version]=""

  # Not even a global node installation
  if [[ ! -v commands[node] ]]; then
    OROSHI_PROMPT_PARTS[node_version]+="%F{$colors[ERROR]}$ICONS[node] %f"
    return
  fi

  local nvmrcPath="$(find-up .nvmrc)"

  # No local version defined, we use the global node version
  # In that case we use the default node version
  if [[ $nvmrcPath == '' ]]; then
    # Nvm not loaded
    if [[ $OROSHI_NVM_LOADED == "0" ]]; then
      return
    fi

    local nvmDefaultVersion="$(<~/.nvm/alias/default)"
    local nvmCurrentVersion="$(nvm current)"

    # Using default version
    if [[ $nvmDefaultVersion == "$nvmCurrentVersion" ]]; then
      OROSHI_PROMPT_PARTS[node_version]+="%F{$colors[INFO]}$ICONS[node] %f"
      return
    fi

    # Custom version
    OROSHI_PROMPT_PARTS[node_version]+="%F{$colors[INFO]}$ICONS[node] $nvmCurrentVersion%f"
    return


  fi

  local expectedVersion="$(<$nvmrcPath)"

  # If nvm isn't loaded, we display in gray
  if [[ $OROSHI_NVM_LOADED == "0" ]]; then
    OROSHI_PROMPT_PARTS[node_version]+="%F{$colors[COMMENT]}$ICONS[node] $expectedVersion%f"
    return
  fi

  # Local version is not even installed
  if [[ ! -d ~/.nvm/versions/node/v${expectedVersion} ]]; then
    OROSHI_PROMPT_PARTS[node_version]+="%F{$colors[ERROR]}$ICONS[node] $expectedVersion%f"
    return
  fi

  local currentVersion="${$(node --version):s/v/}"

  # Local version is different than the current node version
  if [[ $currentVersion != "$expectedVersion" ]]; then
    OROSHI_PROMPT_PARTS[node_version]+="%F{$colors[WARNING]}$ICONS[node] $expectedVersion%f"
    return
  fi

  # Local version is the same as the one in use
  OROSHI_PROMPT_PARTS[node_version]+="%F{$colors[SUCCESS]}$ICONS[node] $expectedVersion%f"
}

