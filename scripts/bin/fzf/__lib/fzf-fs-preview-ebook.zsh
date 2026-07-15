# Ebook preview
function fzf-preview-file-ebook() {
  local fullPath="${1:a}"

  fzf-preview-header "$fullPath"
  fzf-preview-metadata "$(filesize-human "$fullPath")"
  fzf-preview-display-thumbnail "$fullPath" "ebook-thumbnail"
}
