# Ctrl-O: Search for a specific directory, in the whole project
oroshi-fzf-directories-project-widget() {
	export PROMPT_PREVENT_REFRESH="1"
	local selection="$(fzf-fs-directories-project)"
	export PROMPT_PREVENT_REFRESH="0"

	# Stop if no selection is made
	if [[ "$selection" == "" ]]; then
		return 1
	fi

	LBUFFER="${LBUFFER}${selection} "
	return 0
}
zle -N oroshi-fzf-directories-project-widget
bindkey '^O' oroshi-fzf-directories-project-widget
