# shellcheck disable=SC2154
# Add icons for each known yarn linked project
function oroshi-prompt-populate:yarn_link() {
  OROSHI_PROMPT_PARTS[yarn_link]=""
  [[ $GIT_DIRECTORY_IS_REPOSITORY == 0 ]] && return

  local linkListRaw="$(yarn-link-list-raw --include-workspace-root)"
  local totalLinkCount=0
  local displayedLinkCount=0
  local displayedString=''

  for rawLine in ${(f)linkListRaw}; do
    local split=(${(s/▮/)rawLine})
    local linkName=$split[1]
    local linkType=$split[2]

    # Ignore workspace links
    [[ $linkType == 'workspace' ]] && continue
    totalLinkCount=$(($totalLinkCount + 1));

    # Add the module icon to the string
    local projectKey=${linkName:u}
    local projectIcon=${(P)${:-PROJECT_${projectKey}_ICON}}
    if [[ $projectIcon != '' ]]; then
      displayedString+="${projectIcon}"
      displayedLinkCount=$(($displayedLinkCount + 1));
    fi
  done

  # If some linked modules don't have an icon, we add the default chain ico
  if [[ $displayedLinkCount != "$totalLinkCount" ]]; then
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
