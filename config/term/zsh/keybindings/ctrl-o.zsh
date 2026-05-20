# Ctrl-O: Search for a specific directory, context-aware based on typed command
oroshi-fzf-directories-project-widget() {
	# Stop if not available
	if ! command -v fzf >/dev/null; then
		echo "fzf is not installed"
		zle reset-prompt
		return
	fi

	# Command-specific
	local commandName="default"
	[[ "${LBUFFER}" =~ "ralph( )?$" ]] && commandName="ralph"

	export PROMPT_PREVENT_REFRESH="1"
	local selection="$(oroshi-fzf-directories-${commandName}-selection)"
	export PROMPT_PREVENT_REFRESH="0"

	# Stop if no selection is made
	[[ "$selection" == "" ]] && return 1

	LBUFFER="${LBUFFER}${selection} "
	return 0
}
zle -N oroshi-fzf-directories-project-widget
bindkey '^O' oroshi-fzf-directories-project-widget

# Default: all project directories
function oroshi-fzf-directories-default-selection {
	fzf-fs-directories-project
}

# ralph: docs/ subdirectories only
function oroshi-fzf-directories-ralph-selection {
	fzf-fs-directories-ralph
}
