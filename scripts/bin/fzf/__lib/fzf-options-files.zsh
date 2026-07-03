# Shared FZF options for file-search scripts (ctrl-p, ctrl-shift-p)
source "${0:h}/fzf-options-prompt-directory.zsh"

# Emits all fzf options for file-search scripts
# Usage: fzf-options-files <scriptName> <searchPath>
fzf-options-files() {
  local scriptName="$1"
  local searchPath="$2"

  colors-load-definitions

  echo "--delimiter=▮"
  echo "--with-nth=2"
  echo "--scheme=path"
  echo "--tiebreak=pathname,chunk"
  echo "--preview=${scriptName} --preview {1}"

  local prompt="$(fzf-options-prompt-directory "${searchPath}")"
  echo "--prompt=${prompt}"

  echo "--color=query:${COLORS[file]}:regular"
  echo "--color=info:${COLORS[file]}"
  echo "--color=separator:${COLORS[file]}"
}
