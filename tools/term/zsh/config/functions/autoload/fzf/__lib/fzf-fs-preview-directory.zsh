# Directory preview: path + size/counts header, then directory listing.
function fzf-preview-directory() {
  colors-load-definitions
  icons-load-definitions

  # First header line
  local fullPath="${1:a}"
  fzf-preview-header "$fullPath"

  # Display second header line: number of directories, number of files, size
  # #directories
  local directoryCount="$(( $(find "$fullPath" -maxdepth 1 -type d | wc -l) - 1 ))"
  local displayDirectoryCount=""
  displayDirectoryCount="$(colorize ${ICONS[filetype-directory]} yellow) "
  displayDirectoryCount+="$(colorize ${(r:2:: :)directoryCount} comment)"
  # #files
  local fileCount="$(find "$fullPath" -maxdepth 1 -type f | wc -l)"
  local displayFileCount=""
  displayFileCount="$(colorize ${ICONS[filetype-file]} file) "
  displayFileCount+="$(colorize ${(r:2:: :)fileCount} comment)"
  # size
  local dirSize="$(dirsize "$fullPath")"
  local displaySize="$(colorize ${dirSize} comment)"
  echo " ${displayDirectoryCount} ${displayFileCount} ${displaySize}"

  # Separator line
  echo ""

  # Content of the directory
  better-ls --all "$fullPath"
}
