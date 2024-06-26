# Ctrl-P: Search for a specific file, in the whole project
oroshi-fzf-files-project-widget() {
	export PROMPT_PREVENT_REFRESH="1"
	local selection="$(fzf-fs-files-project)"
	export PROMPT_PREVENT_REFRESH="0"

	# Stop if no selection is made
	if [[ "$selection" == "" ]]; then
		return 1
	fi

	LBUFFER="${LBUFFER}${selection} "
	return 0
}
zle -N oroshi-fzf-files-project-widget
bindkey '^P' oroshi-fzf-files-project-widget
