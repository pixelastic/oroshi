# shellcheck disable=SC2154
# Path
# Displays the current path in a shortened form:
# - Use a colored prefix icon for known paths
# - Shorten the actual path to no more than 3 items
# - Color the path if not writable
function oroshi-prompt-populate:path() {
  OROSHI_PROMPT_PARTS[path]=""
  local currentPath="${PWD/#$HOME/~}/"

  local projectName=""
  # Checking if part of a known project
  if (( GIT_DIRECTORY_IS_WORKTREE )); then
    # Inside a worktree: resolve project via main repo, strip worktree root
    projectName="$(git-worktree-project)"
  else
    projectName="$(project-by-path $currentPath)"
  fi

  # Add marker if connected through SSH
  if [[ $SSH_CLIENT != '' ]]; then
    local hostname="$(hostname)"
    OROSHI_PROMPT_PARTS[path]+="%F{$COLOR_ORANGE}${USER} ${hostname}%f%k"
  fi

  # Prefix with a shortened colored version of the project if in an active project
  if [[ $projectName != '' ]]; then
    local projectPrefix="$(OROSHI_IS_PROMPT=1; project-colorize $projectName)"
    OROSHI_PROMPT_PARTS[path]+=$projectPrefix
  fi

  # In worktrees: path only shows the project icon; filepath is in path_worktree_dir
  (( GIT_DIRECTORY_IS_WORKTREE )) && return

  # Simplifying the displayed path by removing the prefix
  if [[ $projectName != '' ]]; then
    local repoRoot="$(project-path "$projectName")"
    currentPath="${currentPath#"${repoRoot}"}"
  fi
  # Simplify string path if too long
  currentPath="$(simplify-path "$currentPath")"

  # Stop if no more path
  [[ $currentPath == '' ]] && return

  # In .git
  if git-directory-is-dot-git; then
    OROSHI_PROMPT_PARTS[path]+="%F{$COLOR_ORANGE}  "
    currentPath=${currentPath:s_.git/__}
    [[ $currentPath != "" ]] && OROSHI_PROMPT_PARTS[path]+=" $currentPath%f"
    return
  fi

  # Deleted path
  if [[ ! -r $PWD ]]; then
    OROSHI_PROMPT_PARTS[path]+="%F{$COLOR_ALIAS_COMMENT} ${currentPath}%f"
    return
  fi

  # Path is not writable
  if [[ ! -w $PWD ]]; then
    OROSHI_PROMPT_PARTS[path]+="%F{$COLOR_ALIAS_ERROR} ${currentPath}%f"
    return
  fi

  [[ $currentPath != "" ]] && OROSHI_PROMPT_PARTS[path]+=" %F{$COLOR_ALIAS_DIRECTORY}${currentPath}%f"
}

# Filepath relative to worktree root (only shown in worktrees, after the branch name)
function oroshi-prompt-populate:path_worktree_dir() {
  OROSHI_PROMPT_PARTS[path_worktree_dir]=""
  (( GIT_DIRECTORY_IS_WORKTREE )) || return

  local worktreeRoot="${$(git-directory-root)/#$HOME/~}/"
  local currentPath="${PWD/#$HOME/~}/"
  local subPath="${currentPath#"${worktreeRoot}"}"

  subPath="$(simplify-path "$subPath")"
  [[ "$subPath" == "" ]] && return

  OROSHI_PROMPT_PARTS[path_worktree_dir]=" %F{$COLOR_ALIAS_DIRECTORY}${subPath}%f"
}
