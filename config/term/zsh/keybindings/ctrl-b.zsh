# Ctrl-B to search in all the available command/aliases/functions
oroshi-fzf-commands-widget() {
	export PROMPT_PREVENT_REFRESH="1"
	local selection="$(fzf-commands)"
	export PROMPT_PREVENT_REFRESH="0"

	# Stop if no selection is made
	if [[ "$selection" == "" ]]; then
		return 1
	fi

	LBUFFER="${LBUFFER}${selection} "
	return 0
}
zle -N oroshi-fzf-commands-widget
bindkey '^B' oroshi-fzf-commands-widget
# }}}
