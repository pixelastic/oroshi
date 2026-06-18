# List directories in a directory for FZF source output
# Source this: source "${0:h}/__lib/fzf-source-directories.zsh"

# Outputs two-column lines: absolute_path▮relative_path
# Usage: fzf-source-directories /path/to/dir
fzf-source-directories() {
  local searchPath="$1"
  local items="$(fd \
    --hidden \
    --follow \
    --color=never \
    --type=directory \
    --exclude=.git \
    --base-directory "$searchPath" \
    .)"
  [[ "$items" == "" ]] && return 0
  colors-load-definitions
  local item
  for item in ${(f)items}; do
    item="${item#./}"
    local display="$(colorize "${item%/}/" $COLORS[directory])"
    echo "${searchPath}/${item%/}▮${display}"
  done
}
