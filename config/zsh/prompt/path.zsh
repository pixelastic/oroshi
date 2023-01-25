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
    # Simplifying the displayed path by removing the prefix
    local projectPath=${(P)${:-PROJECT_${projectKey}_PATH}}
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
    local projectPrefix="$(OROSHI_IS_PROMPT=1; colorize-project $projectKey)"
    echo -n $projectPrefix
  fi


  # Color the string path
  if [[ $currentPath != '' ]]; then
    git-is-dot-git-folder && echo "%F{$COLOR_ORANGE}${currentPath:s_.git/_ }%f" && return
    [[ ! -r $PWD ]] && echo "%F{$COLOR_ALIAS_COMMENT} ${currentPath}%f " && return
    # Path is not writable
    if [[ ! -w $PWD ]]; then
      echo -n "%K{$COLOR_ALIAS_ERROR}%F{$COLOR_WHITE}  %f%k%F{$COLOR_ALIAS_ERROR}%f"
      echo "%F{$COLOR_ALIAS_ERROR}/${currentPath}%f " && return
    fi

    echo "%F{$COLOR_ALIAS_DIRECTORY}${currentPath}%f " && return
  fi
}
