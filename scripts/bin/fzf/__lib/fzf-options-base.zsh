# Shared FZF base options used by all FZF Scripts
# Source this file at the top of each script: source "${0:h}/__lib/fzf-options-base.zsh"

fzf-options-base() {
  echo "--ansi"
  echo "--layout=reverse"
  echo "--delimiter=▮"

  # Default prompt is bold, this reverts it to regular
  echo "--color=prompt::regular"
}
