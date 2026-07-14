# Video preview
function fzf-preview-file-video() {
  local fullPath="${1:a}"

  fzf-preview-header "$fullPath"
  fzf-preview-metadata \
    "$(filesize-human "$fullPath")" \
    "$(video-duration "$fullPath")" \
    "$(video-dimensions "$fullPath")"
  fzf-preview-display-thumbnail "$fullPath" "video-thumbnail"
}
