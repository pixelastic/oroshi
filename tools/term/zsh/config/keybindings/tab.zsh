oroshi-tab-widget() {
	# We call the initial completion, but set PROMPT_PREVENT_REFRESH to 1, so the
	# display is not mangled by the async prompt update
	export PROMPT_PREVENT_REFRESH="1"

	zle expand-or-complete

	export PROMPT_PREVENT_REFRESH="0"
	return 0
}
zle -N oroshi-tab-widget
bindkey '^I' oroshi-tab-widget
# }}}
