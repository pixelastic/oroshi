# Shared filesystem source helper for FZF Scripts
# Source this: source "${0:h}/helpers/fs.zsh"

# List files in a directory, outputting two-column lines: absolute_path   relative_path
# Usage: fs-list-files /path/to/dir
fs-list-files() {
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
