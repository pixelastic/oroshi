# Path
# Displays the current path in a shortened form:
# - Use a colored prefix icon for known paths
# - Shorten the actual path to no more than 3 items
# - Color the path if not writable
function __prompt-path() {
  local currentPath="$(print -D $PWD)/"

  # We loop through each known project, to see if the current path matches one
  # of the projects
  local projectSlug=""
  # Note: 
  # - k: only keeping the keys (paths) of the array
  # - O: ordering them, so the most precise are coming first
  for projectPath in ${(kO)PROJECT_SLUG_BY_PATH}; do
    # Skip if do not start with this known path
    [[ $currentPath != $projectPath* ]] && continue

    # We remove the full path from the current path
    eval "currentPath=\${currentPath:s_${projectPath}_}"

    # We keep in memory the slug of the current project
    projectSlug=$PROJECT_SLUG_BY_PATH[$projectPath]

    # Stop the loop now, we found the best match
    break
  done

  # Simplify string path if too long
  local -a pathArray
  pathArray=(${(s:/:)currentPath})
  if [[ ${#pathArray[*]} -ge 4 ]]; then
    currentPath="${pathArray[1]}/…/${pathArray[-2]}/${pathArray[-1]}/"
  fi

  # Add marker if connected through SSH
  if [[ $SSH_CLIENT != '' ]]; then
    echo -n "%F{$COLORS[orange]}  $hostname %f%k"
  fi

  # Prefix with a shortened colored version of the project if in an active
  # project
  if [[ $projectSlug != '' ]]; then
    local displayBackground=$COLORS[$PROJECT_BACKGROUND[$projectSlug]]
    local displayText=$COLORS[$PROJECT_TEXT[$projectSlug]]
    local displayIcon=$PROJECT_ICON[$projectSlug]

    local displaySlug=$projectSlug
    [[ $PROJECT_HIDE_NAME_IN_PROMPT[$projectSlug] == "1" ]] && displaySlug=""

    local displayProjectPrefix="%K{$displayBackground}%F{$displayText} ${displayIcon}${displaySlug} %f%k%F{$displayBackground}%f "
    echo -n $displayProjectPrefix
  fi


  # Color the string path
  if [[ $currentPath != '' ]]; then
    git-is-dot-git-folder && echo "%F{$COLORS[orange]}${currentPath:s_.git/_ }%f" && return
    [[ ! -r $PWD ]] && echo "%F{$COLORS[gray]} ${currentPath}%f " && return
    [[ ! -w $PWD ]] && echo "%F{$COLORS[red]}!${currentPath}%f " && return

    echo "%F{$COLORS[green]}${currentPath}%f " && return
  fi
}
