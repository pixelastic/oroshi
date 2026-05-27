# Ctrl-G: Search inside of text files in the whole project
oroshi-fzf-regexp-project-widget() {
	# Stop if not available
	if ! command -v fzf >/dev/null; then
		echo "fzf is not installed"
		zle reset-prompt
		return
	fi

  export PROMPT_PREVENT_REFRESH="1"
  local selection="$(fzf-regexp-project)"
  export PROMPT_PREVENT_REFRESH="0"

  # Stop if no selection is made
  if [[ "$selection" == "" ]]; then
    return 1
  fi

  local filesToOpen=()
  for item in ${=selection}; do
    local split=(${(@s/:/)item})
    filesToOpen+=($split[1])
  done

  nvim -p ${=filesToOpen}

  return 0
}
zle -N oroshi-fzf-regexp-project-widget
bindkey '^G' oroshi-fzf-regexp-project-widget
