# Ctrl-Shift-O: Search for a specific directory, in the current directory
oroshi-fzf-directories-subdir-widget() {
	# Stop if not available
	if ! command -v fzf >/dev/null; then
		echo "fzf is not installed"
		zle reset-prompt
		return
	fi

	export PROMPT_PREVENT_REFRESH="1"
	local selection="$(fzf-fs-directories-subdir)"
	export PROMPT_PREVENT_REFRESH="0"

	# Stop if no selection is made
	if [[ "$selection" == "" ]]; then
		return 1
	fi

	LBUFFER="${LBUFFER}${selection} "
	return 0
}
zle -N oroshi-fzf-directories-subdir-widget
bindkey 'Ⓞ' oroshi-fzf-directories-subdir-widget
