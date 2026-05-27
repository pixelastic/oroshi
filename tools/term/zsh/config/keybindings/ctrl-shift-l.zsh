# Ctrl-Shift-L clears the terminal
oroshi-clear-terminal-widget() {
	tput reset
	zle redisplay
}
zle -N oroshi-clear-terminal-widget
bindkey 'Ⓛ' oroshi-clear-terminal-widget
