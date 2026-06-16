# Shared prompt formatting helper for FZF Scripts
# Source this: source "${0:h}/helpers/prompt.zsh"

# Format a directory path as a colored FZF prompt with context badge
# Usage: prompt-directory /path/to/dir
prompt-directory() {
  fzf-prompt-directory "${1:-$PWD}"
}
