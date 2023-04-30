# shellcheck disable=SC2154
# Path
# Displays the current path in a shortened form:
# - Use a colored prefix icon for known paths
# - Shorten the actual path to no more than 3 items
# - Color the path if not writable
function oroshi-prompt-path-populate() {
  OROSHI_PROMPT_PARTS[path]=""
  local currentPath="${PWD/#$HOME/~}/"

  # Checking if part of a known project
  local projectKey="$(project-by-path $currentPath)"
  if [[ $projectKey != "" ]]; then
    # Simplifying the displayed path by removing the prefix
    local projectPath=${(P)${:-PROJECT_${projectKey}_PATH}}
    eval "currentPath=\${currentPath:s_${projectPath}_}"
  fi

  # Simplify string path if too long
  currentPath="$(simplify-path "$currentPath")"

  # Add marker if connected through SSH
  if [[ $SSH_CLIENT != '' ]]; then
    local hostname="$(hostname)"
    OROSHI_PROMPT_PARTS[path]="%F{$COLOR_ORANGE}  $hostname %f%k"
  fi

  # Prefix with a shortened colored version of the project if in an active
  # project
  if [[ $projectKey != '' ]]; then
    local projectPrefix="$(OROSHI_IS_PROMPT=1; colorize-project $projectKey)"
    OROSHI_PROMPT_PARTS[path]+=$projectPrefix
  fi

  # Stop if no more path
  [[ $currentPath == '' ]] && return
 
  # In .git
  if git-directory-is-dot-git; then
    OROSHI_PROMPT_PARTS[path]+="%F{$COLOR_ORANGE}  "
    currentPath=${currentPath:s_.git/__}
    [[ $currentPath != "" ]] && OROSHI_PROMPT_PARTS[path]+=" $currentPath%f"
    return
  fi


  # Deleted path
  if [[ ! -r $PWD ]]; then
    OROSHI_PROMPT_PARTS[path]+="%F{$COLOR_ALIAS_COMMENT} ${currentPath}%f"
    return
  fi

  # Path is not writable
  if [[ ! -w $PWD ]]; then
    OROSHI_PROMPT_PARTS[path]+="%K{$COLOR_ALIAS_ERROR}%F{$COLOR_WHITE}  %f%k%F{$COLOR_ALIAS_ERROR}%f"
    OROSHI_PROMPT_PARTS[path]+="%F{$COLOR_ALIAS_ERROR}${currentPath}%f"
    return
  fi

  [[ $currentPath != "" ]] && OROSHI_PROMPT_PARTS[path]+=" %F{$COLOR_ALIAS_DIRECTORY}${currentPath}%f"
}
