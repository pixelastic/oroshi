# Ctrl-J: Search for a specific directory, from all known locations
oroshi-fzf-common-directories-widget() {
	export PROMPT_PREVENT_REFRESH="1"
	local selection="$(fzf-fs-directories-common)"
	export PROMPT_PREVENT_REFRESH="0"

	# Stop if no selection is made
	if [[ "$selection" == "" ]]; then
		return 1
	fi

	# Add the path to the buffer
	LBUFFER="${LBUFFER}${selection} "
	return 0
}
zle -N oroshi-fzf-common-directories-widget
bindkey '^J' oroshi-fzf-common-directories-widget
