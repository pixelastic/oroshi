# Path
# Displays the current path in a shortened form:
# - Use a colored prefix icon for known paths
# - Shorten the actual path to no more than 3 items
# - Color the path if not writable
function __prompt-path() {
  local currentPath="$(print -D $PWD)/"

  # Checking if part of a known project
  local projectKey="$(project-by-path $currentPath)"
  if [[ $projectKey != "" ]]; then
    local projectName=${(P)${:-PROJECT_${projectKey}_NAME}}
    local projectPath=${(P)${:-PROJECT_${projectKey}_PATH}}
    local projectBackground=${(P)${:-PROJECT_${projectKey}_BACKGROUND}}
    local projectForeground=${(P)${:-PROJECT_${projectKey}_FOREGROUND}}
    local projectIcon=${(P)${:-PROJECT_${projectKey}_ICON}}
    local projectHideNameInPrompt=${(P)${:-PROJECT_${projectKey}_HIDE_NAME_IN_PROMPT}}
    
    # Simplifying the displayed path by removing the prefix
    eval "currentPath=\${currentPath:s_${projectPath}_}"
  fi

  # Simplify string path if too long
  local -a pathArray
  pathArray=(${(s:/:)currentPath})
  if [[ ${#pathArray[*]} -ge 4 ]]; then
    currentPath="${pathArray[1]}/…/${pathArray[-2]}/${pathArray[-1]}/"
  fi

  # Add marker if connected through SSH
  if [[ $SSH_CLIENT != '' ]]; then
    echo -n "%F{$COLOR_ORANGE}  $hostname %f%k"
  fi

  # Prefix with a shortened colored version of the project if in an active
  # project
  if [[ $projectKey != '' ]]; then
    # Some projects are only displayed with their icon
    local displayProjectName="${projectIcon}${projectName}"
    [[ $projectHideNameInPrompt == "1" ]] && displayProjectName="${projectIcon}"

    local displayProjectPrefix="%K{$projectBackground}%F{$projectForeground} ${displayProjectName} %f%k%F{$projectBackground}%f "
    echo -n $displayProjectPrefix
  fi


  # Color the string path
  if [[ $currentPath != '' ]]; then
    git-is-dot-git-folder && echo "%F{$COLOR_ORANGE}${currentPath:s_.git/_ }%f" && return
    [[ ! -r $PWD ]] && echo "%F{$COLOR_ALIAS_COMMENT} ${currentPath}%f " && return
    [[ ! -w $PWD ]] && echo "%F{$COLOR_ALIAS_ERROR}!${currentPath}%f " && return

    echo "%F{$COLOR_ALIAS_FILEPATH}${currentPath}%f " && return
  fi
}
