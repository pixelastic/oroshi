# Format a labeled badge as a colored FZF prompt
# Source this: source "${0:h}/__lib/fzf-options-prompt-label.zsh"

# Returns a colored badge (icon + label + powerline separator) for a FZF --prompt value.
# Usage: fzf-options-prompt-label <icon-key> <label> <bg-color-key> <fg-color-key>
fzf-options-prompt-label() {
  colors-load-definitions
  icons-load-definitions

  local iconKey="$1"
  local label="$2"
  local bgKey="$3"
  local fgKey="$4"

  local badge="$(colorize " $ICONS[$iconKey] $label " "$fgKey" "$bgKey")"
  local arrow="$(colorize "$ICONS[fzf-separator]" "black" "$bgKey")"

  echo "${badge}${arrow} "
}
