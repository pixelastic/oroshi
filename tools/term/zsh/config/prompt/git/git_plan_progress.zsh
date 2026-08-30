# Shows plan progress when inside a plan worktree
function oroshi-prompt-populate:git_plan_progress() {
  OROSHI_PROMPT_PARTS[git_plan_progress]=""
  (($GIT_DIRECTORY_IS_REPOSITORY)) || return
  (($GIT_DIRECTORY_IS_WORKTREE)) || return

  # No plan in this worktree → nothing to show
  git-worktree-has-plan || return

  local badge="$(plan-badge --zsh)"
  [[ "$badge" != "" ]] && OROSHI_PROMPT_PARTS[git_plan_progress]="$badge"
}
