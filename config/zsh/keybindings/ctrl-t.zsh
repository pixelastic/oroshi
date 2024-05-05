# Ctrl-T fuzzy find in directory files
oroshi-fzf-files-subdir-widget() {
	export PROMPT_PREVENT_REFRESH="1"
	local selection="$(fzf-fs-files-subdir)"
	export PROMPT_PREVENT_REFRESH="0"

	# Stop if no selection is made
	if [[ "$selection" == "" ]]; then
		return 1
	fi

	LBUFFER="${LBUFFER}${selection} "
	return 0
}
zle -N oroshi-fzf-files-subdir-widget
bindkey '^T' oroshi-fzf-files-subdir-widget
