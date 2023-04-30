# Ctrl-N opens current folder in explorer
oroshi-open-folder-in-explorer-widget() {
	# shellcheck disable:SC2091
	$(nohup nautilus $PWD &>/dev/null &)
	return 0
}
zle -N oroshi-open-folder-in-explorer-widget
bindkey '^N' oroshi-open-folder-in-explorer-widget
