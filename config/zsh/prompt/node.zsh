# Node
# Display node-related information

# Display node flags:
# - If there are currently any "yarn linked" modules
function __prompt-node-flags() {
  # All yarn methods depend on git root, so better stop early if no git
  git-is-repository || return

  yarn-is-monorepo && echo -n "%F{$COLORS[yellow7]} %f"
  yarn-has-global-links && echo -n "%F{$COLORS[blue7]} %f"
}

# Display node version
# - Only if different from the one defined in the project
function __prompt-node-version() {
  # Not even a system-wide node installation
  if [[ ! -v commands[node] ]]; then
    echo -n "%F{$COLORS[red]} %f"
    return
  fi

  # No nvm
  if [[ ! -v commands[nvm] ]]; then
    echo -n "%F{$COLORS[orange]} %f"
    return
  fi

  nvmrcPath="$(find-up .nvmrc)"
  
  # Stop if project has no version specified
  [[ $nvmrcPath = '' ]] && return

  currentVersion="$(node --version)"
  currentVersion=${currentVersion:s/v/}
  expectedVersion="$(<$nvmrcPath)"

  # Not using the project specific version
  if [[ $currentVersion != $expectedVersion ]]; then
    echo -n "%F{$COLORS[red]} $currentVersion%f"
    echo -n "%F{$COLORS[yellow]}%f"
    echo "%F{$COLORS[green]}$expectedVersion %f"
    return
  fi
}
