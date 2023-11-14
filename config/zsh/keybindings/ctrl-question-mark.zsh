# Ctrl-? explains what the current command does
oroshi-explain-command-widget() {
	# export PROMPT_PREVENT_REFRESH="1"

	echo ""
	ai-shell-explain "${LBUFFER}"
	# export PROMPT_PREVENT_REFRESH="0"

	zle reset-prompt
	return 0

	# LBUFFER="${LBUFFER}same command "
	# return 0
}
zle -N oroshi-explain-command-widget
bindkey '⁇' oroshi-explain-command-widget
# }}}
