# Check if has stashes
function oroshi-prompt-populate:git_has_stash() {
  OROSHI_PROMPT_PARTS[git_has_stash]=""
  (($GIT_DIRECTORY_IS_REPOSITORY)) || return
  git-stash-exists || return

  colors-load-definitions
  icons-load-definitions

  OROSHI_PROMPT_PARTS[git_has_stash]="%F{$COLORS[git-stash]}$ICONS[git-stash] %f"
}
