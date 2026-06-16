# Format a directory path as a colored FZF prompt with context badge
# Source this: source "${0:h}/__lib/fzf-options-prompt-directory.zsh"

# Returns a colored directory path suitable for a FZF --prompt value.
# Shows the project short code (if available) followed by a simplified path.
# Usage: fzf-options-prompt-directory /path/to/dir
fzf-options-prompt-directory() {
  colors-load-definitions
  local inputPath="${1:a}"
  local projectPrefix="$(context-badge "$inputPath")"

  local fzfPrompt
  if [[ "$projectPrefix" != "" ]]; then
    fzfPrompt="$(context-path "$inputPath")"
  else
    fzfPrompt="${inputPath/#$HOME/~}/"
  fi

  # Shorten paths with too many levels
  if [[ $fzfPrompt != "" ]]; then
    fzfPrompt=" $(simplify-path "$fzfPrompt")"
  fi
  # Colorize and prefix with project badge
  fzfPrompt="$(colorize "$fzfPrompt" $COLORS[directory])"
  fzfPrompt="${projectPrefix}${fzfPrompt}"

  echo $fzfPrompt
}
