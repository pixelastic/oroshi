# Node
# Display node-related information
which nvm &>/dev/null && hasNvm=1

# Display node flags:
# - If there are currently any "yarn linked" modules
function __prompt-node-flags() {
  yarn-is-monorepo && echo -n "%F{$COLOR[yellow7]} %f"
  yarn-has-global-links && echo -n "%F{$COLOR[blue7]} %f"
}

# Display node version
# - Only if different from the one defined in the project
function __prompt-node-version() {
  [ ! -v hasNvm ] && return

  nvmrcPath="$(find-up .nvmrc)"
  
  # Stop if project has no version specified
  [[ $nvmrcPath = '' ]] && return

  currentVersion="$(node --version)"
  currentVersion=${currentVersion:s/v/}
  expectedVersion="$(<$nvmrcPath)"

  # Not using the project specific version
  if [[ $currentVersion != $expectedVersion ]]; then
    echo -n "%F{$COLOR[red]} $currentVersion%f"
    echo -n "%F{$COLOR[yellow]}%f"
    echo "%F{$COLOR[green]}$expectedVersion %f"
    return
  fi
}
