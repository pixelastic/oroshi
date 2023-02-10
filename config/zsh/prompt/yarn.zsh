# Add icons for each known yarn linked project
function oroshi-prompt-yarn-link-populate() {
  OROSHI_PROMPT_PARTS[node-yarn-link]=""
  (( $GIT_DIRECTORY_IS_REPOSITORY )) || return

  local linkedModules="$(yll-raw)"
  local totalModuleCount=0
  local displayedModuleCount=0
  local displayedString=''

  for module in ${(f)linkedModules}; do
    local split=(${(s/:/)module})
    local moduleName=$split[1]
    local moduleLinkType=$split[2]

    # Keep only the global ones
    [[ $moduleLinkType = 'local' ]] && continue
    totalModuleCount=$(($totalModuleCount + 1));

    # Add the module icon to the string
    local projectKey=${moduleName:u}
    local projectIcon=${(P)${:-PROJECT_${projectKey}_ICON}}
    if [[ $projectIcon != '' ]]; then
      displayedString="${displayedString}${projectIcon}"
      displayedModuleCount=$(($displayedModuleCount + 1));
    fi
  done

  # If some linked modules don't have an icon, we add the default chain ico
  if [[ $displayedModuleCount != $totalModuleCount ]]; then
    displayedString="${displayedString} "
  fi

  # Save the full string
  OROSHI_PROMPT_PARTS[yarn-link]="%F{$COLOR_ALIAS_STRING}${displayedString}%f "
}

# Check if a yarn install is in progress
function oroshi-prompt-yarn-install-in-progress-populate() {
  OROSHI_PROMPT_PARTS[yarn-install-in-progress]=""

  if yarn-install-in-progress; then
    OROSHI_PROMPT_PARTS[yarn-install-in-progress]="%F{$COLOR_GREEN_8} %f"
  fi
}
