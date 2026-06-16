# Ctrl-B to search in all the available command/aliases/functions
oroshi-ctrl-b-widget() {
	# Stop if not available
	if ! command -v fzf >/dev/null; then
		echo "fzf is not installed"
		zle reset-prompt
		return
	fi

	export PROMPT_PREVENT_REFRESH="1"
	local selection="$("$OROSHI_ROOT/scripts/bin/fzf/ctrl-b")"
	export PROMPT_PREVENT_REFRESH="0"

	# Stop if no selection is made
	if [[ "$selection" == "" ]]; then
		return 1
	fi

	LBUFFER="${LBUFFER}${selection} "
	return 0
}
zle -N oroshi-ctrl-b-widget
bindkey '^B' oroshi-ctrl-b-widget
# }}}
