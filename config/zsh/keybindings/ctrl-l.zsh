# Ctrl-L lists all files in the directory
oroshi-list-files-widget() {
	echo ""
	ls
	zle reset-prompt
}
zle -N oroshi-list-files-widget
bindkey '^L' oroshi-list-files-widget
