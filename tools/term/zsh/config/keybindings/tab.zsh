oroshi-completion() {
	# We call the initial completion, but set PROMPT_PREVENT_REFRESH to 1, so the
	# display is not mangled by the async prompt update
	export PROMPT_PREVENT_REFRESH="1"

	zle expand-or-complete

	export PROMPT_PREVENT_REFRESH="0"
	return 0
}
zle -N oroshi-completion
bindkey '^I' oroshi-completion
# }}}
