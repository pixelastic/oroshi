# List files in a directory for FZF source output
# Source this: source "${0:h}/__lib/fzf-source-files.zsh"
source "${0:h}/fzf-colorize-path.zsh"

# Outputs two-column lines: absolute_path▮colorized_relative_path
# Usage: fzf-source-files /path/to/dir
fzf-source-files() {
  local searchPath="$1"
  local items="$(fd \
    --hidden \
    --follow \
    --color=never \
    --type=file \
    --base-directory "$searchPath" \
    . \
    | sed 's|^\./||' \
    | sort-filepaths)"
  [[ "$items" == "" ]] && return 0
  local item
  for item in ${(f)items}; do
    fzf-colorize-path "$item" "${searchPath}/${item}"
    echo "${searchPath}/${item}▮${REPLY}"
  done
}
