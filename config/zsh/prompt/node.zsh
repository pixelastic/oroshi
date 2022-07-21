# Node
# Display node-related information

# Display node flags:
# - If there are currently any "yarn linked" modules
function __prompt-node-flags() {
  # All yarn methods depend on git root, so better stop early if no git
  git-is-repository || return

  yarn-is-monorepo && echo -n "%F{$COLORS[yellow7]} %f"
  __prompt-yarn-links
}

# Display node version
# - Only if different from the one defined in the project
function __prompt-node-version() {
  # Not even a system-wide node installation
  if [[ ! -v commands[node] ]]; then
    echo -n "%F{$COLORS[red]} %f"
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

# Display specific icons for each linked module
function __prompt-yarn-links() {
  local linkedModules=($(yll-raw))
  local totalModuleCount=0
  local displayedModuleCount=0
  local displayedString=''

  for module in $linkedModules; do
    local split=(${(s/:/)module})
    local moduleName=$split[1]
    local moduleLinkType=$split[2]

    # Keep only the global ones
    [[ $moduleLinkType = 'local' ]] && continue
    totalModuleCount=$(($totalModuleCount + 1));

    # Add the module icon to the string
    local moduleIcon=$PROJECT_ICON[$moduleName]
    if [[ $moduleIcon != '' ]]; then
      displayedString="${displayedString}${moduleIcon}"
      displayedModuleCount=$(($displayedModuleCount + 1));
    fi
  done

  # If some linked modules don't have an icon, we add the default chain ico
  if [[ $displayedModuleCount != $totalModuleCount ]]; then
    displayedString="${displayedString} "
  fi

  # Display the string
  echo -n "%F{$COLORS[blue7]}${displayedString}%f"
}
