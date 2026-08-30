# Check if in a submodule
function oroshi-prompt-populate:git_is_submodule() {
  OROSHI_PROMPT_PARTS[git_is_submodule]=""
  (($GIT_DIRECTORY_IS_REPOSITORY)) || return

  git-is-submodule || return

  colors-load-definitions
  icons-load-definitions

  OROSHI_PROMPT_PARTS[git_is_submodule]="%F{$COLORS[git-submodule]}$ICONS[git-submodule] %f"
}
