colors-load-definitions
icons-load-definitions

# Add icons for each known yarn linked project
function oroshi-prompt-populate:yarn_link() {
  OROSHI_PROMPT_PARTS[yarn_link]=""
  [[ $GIT_DIRECTORY_IS_REPOSITORY == 0 ]] && return

  local linkListRaw="$(yarn-link-list-raw --include-workspace-root)"
  local totalLinkCount=0
  local displayedLinkCount=0
  local displayedString=''

  projects-load-definitions

  for rawLine in ${(f)linkListRaw}; do
    local split=(${(s/▮/)rawLine})
    local linkName=$split[1]
    local linkType=$split[2]

    # Ignore workspace links
    [[ $linkType == 'workspace' ]] && continue
    totalLinkCount=$(($totalLinkCount + 1));

    # Add the module icon to the string
    local projectIcon="${PROJECTS[$linkName:icon]}"
    if [[ $projectIcon != '' ]]; then
      displayedString+="${projectIcon}"
      displayedLinkCount=$(($displayedLinkCount + 1));
    fi
  done

  # If some linked modules don't have an icon, we add the default chain ico
  if [[ $displayedLinkCount != "$totalLinkCount" ]]; then
    displayedString+="$ICONS[node-link] "
  fi

  if [[ $displayedString != "" ]]; then
    OROSHI_PROMPT_PARTS[yarn_link]="%F{$COLORS[string]}${displayedString}%f"
  fi
}

# Check if a yarn install is in progress
function oroshi-prompt-populate:yarn_install_in_progress() {
  OROSHI_PROMPT_PARTS[yarn_install_in_progress]=""

  if yarn-install-in-progress; then
    local installing="%F{$COLORS[green-8]}$ICONS[node-install-in-progress] %f"
    OROSHI_PROMPT_PARTS[yarn_install_in_progress]="$installing"
  fi
}
