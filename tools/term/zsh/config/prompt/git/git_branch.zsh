# Display a colored branch, with icons
function oroshi-prompt-populate:git_branch() {
  OROSHI_PROMPT_PARTS[git_branch]=""
  (($GIT_DIRECTORY_IS_REPOSITORY)) || return
  # In worktrees, the branch is on the left (context-badge)
  # But submodules inside worktrees need their own branch on the right
  (($GIT_DIRECTORY_IS_WORKTREE)) && ! (($GIT_DIRECTORY_IS_SUBMODULE)) && return

  OROSHI_PROMPT_PARTS[git_branch]="$(git-branch-colorize --with-icon --zsh)"
}
