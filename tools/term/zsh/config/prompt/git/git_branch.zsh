# Display a colored branch, with icons
function oroshi-prompt-populate:git_branch() {
  OROSHI_PROMPT_PARTS[git_branch]=""
  (($GIT_DIRECTORY_IS_REPOSITORY)) || return
  # In worktrees, we display the branch on the left
  (($GIT_DIRECTORY_IS_WORKTREE)) && return

  OROSHI_PROMPT_PARTS[git_branch]="$(git-branch-colorize --with-icon --zsh)"
}
