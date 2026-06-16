# Ctrl-L lists all files in the directory
oroshi-ctrl-l-widget() {
	echo ""
	ls
	zle reset-prompt
}
zle -N oroshi-ctrl-l-widget
bindkey '^L' oroshi-ctrl-l-widget
