# Colorize a file path: directory in directory color, filename by filetype or executable
# Usage: fzf-colorize-path <display-path> [real-path]
#   real-path: actual filesystem path used for -x executable check (defaults to display-path)
# Result in $REPLY (no subprocess)
fzf-colorize-path() {
  local inputPath="$1"
  local realPath="${2:-$1}"
  local dirname="${inputPath%/*}"
  local filename="${inputPath##*/}"

  # Just a filename at the root (no directory component)
  if [[ "$dirname" == "$inputPath" ]]; then
    dirname=""
    filename="$inputPath"
  fi

  # Load FILETYPES and COLORS
  filetypes-load-definitions
  colors-load-definitions

  # Colorize filename by filetype key, fall back to executable color
  filetypes-key "$filename"
  local fileColor="${FILETYPES[${REPLY}:color]}"
  if [[ "$fileColor" == "" ]]; then
    [[ -x "$realPath" ]] && fileColor="$COLORS[executable]"
  fi

  if [[ "$fileColor" != "" ]]; then
    colorize --reply "$filename" "$fileColor"
    filename="$REPLY"
  fi
  if [[ "$dirname" != "" ]]; then
    colorize --reply "${dirname}/" directory
    dirname="$REPLY"
  fi

  REPLY="${dirname}${filename}"
}
