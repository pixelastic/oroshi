# Colorize a git status prefix + file path
# Usage:
# $ fzf-colorize-git-status-path <filepath> <gitStatus>
#   gitStatus: A (added), M (modified), D (deleted)
# Result in $REPLY (no subprocess)
source "${0:h}/fzf-colorize-path.zsh"

function fzf-colorize-git-status-path() {
  setopt local_options err_return
  local filepath="$1"
  local gitStatus="$2"

  # Map git status to prefix symbol and color
  local prefix=""
  local prefixColor=""
  case "$gitStatus" in
    A) prefix="+"; prefixColor="git-added" ;;
    M) prefix="~"; prefixColor="git-modified" ;;
    D) prefix="-"; prefixColor="git-removed" ;;
  esac

  # Colorize the prefix
  colorize --reply "$prefix" "$prefixColor"
  local coloredPrefix="$REPLY"

  # Colorize the filepath
  fzf-colorize-path "$filepath"
  local coloredPath="$REPLY"

  REPLY="${coloredPrefix} ${coloredPath}"
}
