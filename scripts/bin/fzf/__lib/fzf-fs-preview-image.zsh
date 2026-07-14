# Image preview
function fzf-preview-file-image() {
  local fullPath="${1:a}"

  fzf-preview-header "$fullPath"
  fzf-preview-metadata "$(filesize-human "$fullPath")" "$(img-dimensions "$fullPath")"

  img-display \
    --no-metadata \
    --fzf-preview \
    "$fullPath"
}
