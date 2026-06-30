# Ctrl-Shift-G: Search inside of text files in the current directory
oroshi-ctrl-shift-g-widget() {
  # Stop if not available
  if ! command -v fzf >/dev/null; then
    echo "fzf is not installed"
    zle reset-prompt
    return
  fi

  export PROMPT_PREVENT_REFRESH="1"
  local selection="$(ctrl-shift-g)"
  export PROMPT_PREVENT_REFRESH="0"

  # Stop if no selection is made
  [[ "$selection" == "" ]] && return 1

  # Parse each selected line: filepath:lineNum:col
  local filesToOpen=()
  local lineNumbers=()
  for item in ${(f)selection}; do
    [[ "$item" == "" ]] && continue
    local split=(${(@s/:/)item})
    filesToOpen+=("${split[1]}")
    lineNumbers+=("${split[2]}")
  done

  local fileCount=${#filesToOpen[@]}

  # No selection
  [[ "$fileCount" -eq 0 ]] && return 1

  # Only one selection
  if [[ "$fileCount" -eq 1 ]]; then
    nvim "+${lineNumbers[1]}" "${filesToOpen[1]}"
    return 0
  fi

  # Multi-select: open each file in a tab, then jump to its matched line
  local nvimCmds=()
  for i in {1..$fileCount}; do
    nvimCmds+=("-c" "execute 'normal! ${i}gt'|normal! ${lineNumbers[$i]}G")
  done
  nvimCmds+=("-c" "execute 'normal! 1gt'")
  nvim -p "${filesToOpen[@]}" "${nvimCmds[@]}"
  return 0
}
zle -N oroshi-ctrl-shift-g-widget
bindkey 'Ⓖ' oroshi-ctrl-shift-g-widget
