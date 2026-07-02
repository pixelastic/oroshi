# Shared filesystem preview for FZF Scripts.

# Orchestrator: clears kitty image, dispatches by path type.
# Called by init.zsh when the script receives --preview.
# Override this in the script for custom preview behaviour.
fzf-preview() {
  zmodload zsh/zutil
  zparseopts -E -D \
    -highlight-line:=flagHighlightLine \
    -highlight-query:=flagHighlightQuery

  local highlightLine="${flagHighlightLine[2]}"
  local highlightQuery="${flagHighlightQuery[2]}"
  local fullPath="${1:a}"

  # Cleanup any previously displayed image
  img-display --clear

  # Directory
  if [[ -d "$fullPath" ]]; then
    fzf-preview-directory "$fullPath"
    return 0
  fi

  local filetypeGroup="$(filetype-group "$fullPath")"

  # Images
  if [[ "$filetypeGroup" == "image" ]]; then
    fzf-preview-file-image "$fullPath"
    return 0
  fi

  # PDF
  if [[ "$filetypeGroup" == "pdf" ]]; then
    fzf-preview-file-pdf "$fullPath"
    return 0
  fi

  # Ebooks
  if [[ "$filetypeGroup" == "ebook" ]]; then
    fzf-preview-file-ebook "$fullPath"
    return 0
  fi

  # Text
  fzf-preview-file-text "$fullPath" "$highlightLine" "$highlightQuery"
}

# Directory preview: path + size/counts header, then directory listing.
fzf-preview-directory() {
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

# Image preview
fzf-preview-file-image() {
  local fullPath="${1:a}"

  # Header
  fzf-preview-header "$fullPath"

  # Metadata
  local -a metadata=()
  metadata+=("$(filesize-human "$fullPath")")
  metadata+=("$(img-dimensions "$fullPath")")
  colorize " ${(j/, /)metadata}" comment
  echo ""
  echo ""

  # Display image
  img-display \
    --no-metadata \
    --fzf-preview \
    "$fullPath"
}

# PDF preview
fzf-preview-file-pdf() {
  local fullPath="${1:a}"

  # Header
  fzf-preview-header "$fullPath"

  # Metadata
  local -a metadata=()
  metadata+=("$(filesize-human "$fullPath")")
  metadata+=("$(pdf-page-count "$fullPath") pages")
  colorize " ${(j/, /)metadata}" comment
  echo ""
  echo ""

  # Generate and display the cover
  local coverPath="$(fzf-preview-document-cover "$fullPath" "pdf-cover-extract")"

  img-display \
    --no-metadata \
    --fzf-preview \
    "$coverPath"
  local imgDisplayExitCode="$?"

  # Delete cover if it was corrupted
  if [[ "$imgDisplayExitCode" == 1 ]]; then
    rm -f "$coverPath"
  fi
}

# Ebook preview
fzf-preview-file-ebook() {
  local fullPath="${1:a}"

  # Header
  fzf-preview-header "$fullPath"

  # Metadata
  local -a metadata=()
  metadata+=("$(filesize-human "$fullPath")")
  metadata+=("$(ebook-page-count "$fullPath") pages")
  colorize " ${(j/, /)metadata}" comment
  echo ""
  echo ""

  # Generate and display the cover
  local coverPath="$(fzf-preview-document-cover "$fullPath" "ebook-cover-extract")"

  img-display \
    --no-metadata \
    --fzf-preview \
    "$coverPath"
  local imgDisplayExitCode="$?"

  # Delete cover if it was corrupted
  if [[ "$imgDisplayExitCode" == 1 ]]; then
    rm -f "$coverPath"
  fi
}

# Helper to get the cover of a pdf or ebook
fzf-preview-document-cover() {
  local filepath="$1"
  local extractor="$2"

  local previewCacheFolder="${OROSHI_TMP_FOLDER}/fzf/previews"
  local previewCacheHash="$(file-hash "$fullPath")"
  local previewCachePath="${previewCacheFolder}/${previewCacheHash}.png"

  # Return early if already exists
  if [[ -f "$previewCachePath" ]]; then
    echo "$previewCachePath"
    return 0
  fi

  # Create the cover if not
  mkdir -p "$previewCacheFolder"
  $extractor "$filepath" "$previewCachePath"
  echo "$previewCachePath"
}

# Text preview: path + file metadata header, then bat output.
# Usage: fzf-preview-file-text <path> [highlightLine] [highlightQuery]
fzf-preview-file-text() {
  local fullPath="${1:a}"

  # Path header
  fzf-preview-header "$fullPath"

  # Metadata
  local -a metadata=()
  metadata+=("$(filesize-human "$fullPath")")
  metadata+=("$(wc -l < "$fullPath") lines")
  colorize " ${(j/, /)metadata}" comment
  echo ""
  echo ""

  # File content
  bat \
    --paging=never \
    --style=numbers \
    --color=always \
    "$fullPath"
}

# First line shared across all preview types.
# Directory portion in directory color, filename in filetype color.
# Usage: fzf-preview-header <path>
fzf-preview-header() {
  local fullPath="${1:a}"

  # Context badge
  local contextDirectory=$fullPath
  [[ -f "$contextDirectory" ]] && contextDirectory="${contextDirectory:h}"
  local contextBadge="$(context-badge "$contextDirectory")"

  # Simplified path
  local displayedPath="${contextDirectory/#$HOME/\~}"
  [[ "$contextBadge" != "" ]] && displayedPath="$(context-path "$contextDirectory")"
  displayedPath="$(simplify-path "$displayedPath" )"
  [[ $displayedPath != "" ]] && displayedPath="${displayedPath}/"
  displayedPath="$(colorize "$displayedPath" directory)"

  echo "${contextBadge} ${displayedPath}"

  # Stop if directories
  [[ -d "$fullPath" ]] && return

  # Files: icon + filename in filetype color
  filetypes-load-definitions
  icons-load-definitions
  local fileExtension="${fullPath:e}"
  local icon="$FILETYPES[${fileExtension:l}:icon]"
  local color="$FILETYPES[${fileExtension:l}:color]"
  if [[ "$color" == "" && -x "$fullPath" ]]; then
    color="executable"
    icon=$ICONS[filetype-executable]
  fi

  colorize " ${icon} ${fullPath:t}" $color
  echo ""
}
