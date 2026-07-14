# PDF preview
function fzf-preview-file-pdf() {
  local fullPath="${1:a}"

  fzf-preview-header "$fullPath"
  fzf-preview-metadata "$(filesize-human "$fullPath")" "$(pdf-page-count "$fullPath") pages"
  fzf-preview-display-thumbnail "$fullPath" "pdf-thumbnail"
}
