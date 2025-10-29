# Ctrl-Y copies current directory to clipboard
oroshi-copy-current-directory-widget() {
	clipboard-write "$PWD"
	zle reset-prompt
	return 0
}
zle -N oroshi-copy-current-directory-widget
bindkey '^Y' oroshi-copy-current-directory-widget
