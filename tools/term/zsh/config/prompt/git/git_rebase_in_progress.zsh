# Check if rebase is in progress
function oroshi-prompt-populate:git_rebase_in_progress() {
  OROSHI_PROMPT_PARTS[git_rebase_in_progress]=""
  git-rebase-in-progress || return

  colors-load-definitions
  icons-load-definitions

  OROSHI_PROMPT_PARTS[git_rebase_in_progress]="%F{$COLORS[git-rebase]}$ICONS[git-rebase] %f"
}
