# Colorize a file path: directory in directory color, filename by filetype or executable
# Usage: fzf-colorize-path <path>
# Result in $REPLY (no subprocess)
fzf-colorize-path() {
  local inputPath="$1"
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

  # Colorize filename by extension, fall back to executable color
  local ext="${filename##*.}"
  local fileColor="${FILETYPES[${ext}:color]}"
  if [[ "$fileColor" == "" ]]; then
    [[ -x "$inputPath" ]] && fileColor="$COLORS[executable]"
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
