# Ctrl-Shift-O fuzzy find in subdir directories
oroshi-fzf-directories-subdir-widget() {
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
