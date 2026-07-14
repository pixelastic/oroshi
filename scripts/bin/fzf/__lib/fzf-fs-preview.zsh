# Shared filesystem preview for FZF Scripts.

# Source type-specific preview handlers
source "${0:h}/fzf-fs-preview-directory.zsh"
source "${0:h}/fzf-fs-preview-image.zsh"
source "${0:h}/fzf-fs-preview-pdf.zsh"
source "${0:h}/fzf-fs-preview-video.zsh"
source "${0:h}/fzf-fs-preview-ebook.zsh"
source "${0:h}/fzf-fs-preview-text.zsh"

# Orchestrator: clears kitty image, dispatches by path type.
# Called by init.zsh when the script receives --preview.
# Override this in the script for custom preview behaviour.
function fzf-preview() {
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

  local filetypeGroup="$(filetypes-group "$fullPath")"

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

  # Video
  if [[ "$filetypeGroup" == "video" ]]; then
    fzf-preview-file-video "$fullPath"
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

# Shared metadata line: comma-separated items in comment color
function fzf-preview-metadata() {
  colorize " ${(j/, /)@}" comment
  echo ""
  echo ""
}

# Shared thumbnail generation, display, and cleanup
function fzf-preview-display-thumbnail() {
  local fullPath="$1"
  local extractor="$2"

  local thumbnailPath="$(fzf-preview-thumbnail "$fullPath" "$extractor")"

  img-display \
    --no-metadata \
    --fzf-preview \
    "$thumbnailPath"
  local imgDisplayExitCode="$?"

  # Delete thumbnail if it was corrupted
  if [[ "$imgDisplayExitCode" == 1 ]]; then
    rm -f "$thumbnailPath"
  fi
}

# Helper to get the cached thumbnail of a file
function fzf-preview-thumbnail() {
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

  # Create the thumbnail if not
  mkdir -p "$previewCacheFolder"
  $extractor "$filepath" "$previewCachePath"
  echo "$previewCachePath"
}

# First line shared across all preview types.
# Directory portion in directory color, filename in filetype color.
# Usage: fzf-preview-header <path>
function fzf-preview-header() {
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
  filetypes-key "$fullPath"
  local key="$REPLY"
  local icon="$FILETYPES[${key}:icon]"
  local color="$FILETYPES[${key}:color]"

  # No color from extension: check autoload, then executable
  if [[ "$color" == "" ]]; then
    # Is it a zsh autoload function?
    is-zsh-autoload-function "$fullPath"
    if [[ "$REPLY" == "1" ]]; then
      color="$FILETYPES[zsh:color]"
      icon="$FILETYPES[zsh:icon]"
    fi

    # Is it an executable?
    if [[ "$color" == "" && -x "$fullPath" ]]; then
      color="executable"
      icon=$ICONS[filetype-executable]
    fi
  fi

  colorize " ${icon} ${fullPath:t}" $color
  echo ""
}
