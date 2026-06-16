# List files in a directory for FZF source output
# Source this: source "${0:h}/__lib/fzf-source-files.zsh"

# Outputs two-column lines: absolute_path▮relative_path
# Usage: fzf-source-files /path/to/dir
fzf-source-files() {
  local searchPath="$1"
  local items="$(fd \
    --hidden \
    --follow \
    --color=never \
    --type=file \
    --base-directory "$searchPath" \
    .)"
  [[ "$items" == "" ]] && return 0
  local item
  for item in ${(f)items}; do
    item="${item#./}"
    echo "${searchPath}/${item}▮${item}"
  done
}
