# Text preview: path + file metadata header, then bat output.
# Usage: fzf-preview-file-text <path> [highlightLine] [highlightQuery]
function fzf-preview-file-text() {
  local fullPath="${1:a}"

  # Path header
  fzf-preview-header "$fullPath"
  fzf-preview-metadata "$(filesize-human "$fullPath")" "$(wc -l < "$fullPath") lines"

  # File content
  bat \
    --paging=never \
    --style=numbers \
    --color=always \
    "$fullPath"
}
