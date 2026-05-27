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
#
# -  (red) if no global node
#
# When not in a node repo
# - {nothing} if nvm hasn't been loaded
# -  (green) if using the default version
# -  X.Y.Z (violet) if using a specific node version
#
# When in a node repo
# -  X.Y.Z (grey) if local version detected, but nvm hasn't been loaded
# -  X.Y.Z (red) if local version isn't installed
# -  X.Y.Z (yellow) if local and current don't match
# -  X.Y.Z (green) if local and current match
function oroshi-prompt-populate:node_version() {
  OROSHI_PROMPT_PARTS[node_version]=""

  # Not even a global node installation
  if [[ ! -v commands[node] ]]; then
    OROSHI_PROMPT_PARTS[node_version]+="%F{$COLOR_ALIAS_ERROR} %f"
    return
  fi

  local nvmrcPath="$(find-up .nvmrc)"

  # No local version defined, we use the global node version
  # In that case we use the default node version
  if [[ $nvmrcPath = '' ]]; then
    # Nvm not loaded
    if [[ $OROSHI_NVM_LOADED == "0" ]]; then
      return
    fi

    local nvmDefaultVersion="$(<~/.nvm/alias/default)"
    local nvmCurrentVersion="$(nvm current)"

    # Using default version
    if [[ $nvmDefaultVersion == "$nvmCurrentVersion" ]]; then
      OROSHI_PROMPT_PARTS[node_version]+="%F{$COLOR_ALIAS_INFO} %f"
      return
    fi

    # Custom version
    OROSHI_PROMPT_PARTS[node_version]+="%F{$COLOR_ALIAS_INFO} $nvmCurrentVersion%f"
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

