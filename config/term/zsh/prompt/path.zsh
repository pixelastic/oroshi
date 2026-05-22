# shellcheck disable=SC2154
# Path
# Displays the current path in a shortened form:
# - Use a colored prefix icon for known paths
# - Shorten the actual path to no more than 3 items
# - Color the path if not writable
function oroshi-prompt-populate:path() {
  OROSHI_PROMPT_PARTS[path]=""
  local currentPath="${PWD/#$HOME/~}/"

  # Add marker if connected through SSH
  if [[ $SSH_CLIENT != '' ]]; then
    local hostname="$(hostname)"
    OROSHI_PROMPT_PARTS[path]+="%F{$COLOR_ORANGE}${USER} ${hostname}%f%k"
  fi

  # Context badge: project name + branch (for worktrees)
  local badge="$(context-badge --zsh "$PWD")"
  [[ "$badge" != "" ]] && OROSHI_PROMPT_PARTS[path]+="$badge"

  # In worktrees: badge only; filepath is in path_worktree_dir
  (( GIT_DIRECTORY_IS_WORKTREE )) && return

  # Strip context root prefix from current path
  local contextRoot="$(context-root "$PWD")"
  [[ "$contextRoot" != "" ]] && currentPath="${currentPath#"${contextRoot/#$HOME/~}/"}"

  # Simplify string path if too long
  currentPath="$(simplify-path "$currentPath")"

  # Stop if no more path
  [[ "$currentPath" == "" ]] && return

  # In .git
  if git-directory-is-dot-git; then
    OROSHI_PROMPT_PARTS[path]+="%F{$COLOR_ORANGE}  "
    currentPath="${currentPath:s_.git/__}"
    [[ "$currentPath" != "" ]] && OROSHI_PROMPT_PARTS[path]+=" $currentPath%f"
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

  [[ "$currentPath" != "" ]] && OROSHI_PROMPT_PARTS[path]+=" %F{$COLOR_ALIAS_DIRECTORY}${currentPath}%f"
}

# Filepath relative to worktree root (only shown in worktrees, after the badge)
function oroshi-prompt-populate:path_worktree_dir() {
  OROSHI_PROMPT_PARTS[path_worktree_dir]=""
  (( GIT_DIRECTORY_IS_WORKTREE )) || return

  local subPath="$(context-path "$PWD")"
  subPath="$(simplify-path "$subPath")"
  [[ "$subPath" == "" ]] && return

  OROSHI_PROMPT_PARTS[path_worktree_dir]=" %F{$COLOR_ALIAS_DIRECTORY}${subPath}%f"
}
