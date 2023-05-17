# shellcheck disable=SC2154
# Add icons for each known yarn linked project
function oroshi-prompt-populate:yarn_link() {
  OROSHI_PROMPT_PARTS[yarn_link]=""
  [[ $GIT_DIRECTORY_IS_REPOSITORY == 0 ]] && return

  local linkedModules="$(yarn-link-list-raw)"
  local totalModuleCount=0
  local displayedModuleCount=0
  local displayedString=''

  for module in ${(f)linkedModules}; do
    local split=(${(s/▮/)module})
    local moduleName=$split[1]
    local moduleLinkType=$split[2]

    # Keep only the global ones
    [[ $moduleLinkType = 'local' ]] && continue
    totalModuleCount=$(($totalModuleCount + 1));

    # Add the module icon to the string
    local projectKey=${moduleName:u}
    local projectIcon=${(P)${:-PROJECT_${projectKey}_ICON}}
    if [[ $projectIcon != '' ]]; then
      displayedString+="${projectIcon}"
      displayedModuleCount=$(($displayedModuleCount + 1));
    fi
  done

  # If some linked modules don't have an icon, we add the default chain ico
  if [[ $displayedModuleCount != "$totalModuleCount" ]]; then
    displayedString+=" "
  fi

  if [[ $displayedString != "" ]]; then
    OROSHI_PROMPT_PARTS[yarn_link]="%F{$COLOR_ALIAS_STRING}${displayedString}%f"
  fi
}

# Check if a yarn install is in progress
function oroshi-prompt-populate:yarn_install_in_progress() {
  OROSHI_PROMPT_PARTS[yarn_install_in_progress]=""

  if yarn-install-in-progress; then
    OROSHI_PROMPT_PARTS[yarn_install_in_progress]="%F{$COLOR_GREEN_8} %f"
  fi
}
