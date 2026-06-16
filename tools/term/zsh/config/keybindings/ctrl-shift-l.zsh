# Ctrl-Shift-L clears the terminal
oroshi-ctrl-shift-l-widget() {
	tput reset
	zle redisplay
}
zle -N oroshi-ctrl-shift-l-widget
bindkey 'Ⓛ' oroshi-ctrl-shift-l-widget
