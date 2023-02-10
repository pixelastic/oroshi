# Node

# Add an icon if in a monorepo
function oroshi-prompt-node-monorepo-populate() {
  OROSHI_PROMPT_PARTS[node-monorepo]=""
  (( $GIT_DIRECTORY_IS_REPOSITORY )) || return
  yarn-is-monorepo || return

  OROSHI_PROMPT_PARTS[node-monorepo]="%F{$COLOR_ALIAS_LOCAL_DEPENDENCY} %f"
}

# Display project node version
# -  (red) if no global node
# - {nothing} if not a node repo (no .nvmrc)
# -  X.Y.Z (red) if local version isn't installed
# -  X.Y.Z (yellow) if local and current don't match match
# -  X.Y.Z (green) if local and current match
function oroshi-prompt-node-version-populate() {
  OROSHI_PROMPT_PARTS[node-version]=""

  # Not even a system-wide node installation
  if [[ ! -v commands[node] ]]; then
    OROSHI_PROMPT_PARTS[node-version]="%F{$COLOR_ALIAS_ERROR} %f"
    return
  fi

  local nvmrcPath="$(find-up .nvmrc)"

  # No local version defined
  if [[ $nvmrcPath = '' ]]; then
    return
  fi

  local currentVersion="$(node --version)"
  currentVersion=${currentVersion:s/v/}
  local expectedVersion="$(<$nvmrcPath)"

  # Local version is the same as the current one
  if [[ $currentVersion == $expectedVersion ]]; then
    OROSHI_PROMPT_PARTS[node-version]="%F{$COLOR_ALIAS_SUCCESS} $expectedVersion%f "
    return
  fi

  # Local version is not even installed
  if nvm version $expectedVersion | grep -q "N/A"; then
    OROSHI_PROMPT_PARTS[node-version]="%F{$COLOR_ALIAS_ERROR} $expectedVersion%f "
    return
  fi

  # Local version is not in use
  OROSHI_PROMPT_PARTS[node-version]="%F{$COLOR_ALIAS_WARNING} $expectedVersion%f "
}

