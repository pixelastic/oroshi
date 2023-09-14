# Enabling vim mode
bindkey -v
# Note: In the terminal, start "cat" without arguments and press keys to see
# their keycodes.
# Alternatively, you can hit Ctrl-V here in vim, followed by the key to get its
# keycode as well

bindkey -M viins "[3~" delete-char       # Delete
bindkey -M viins "" backward-delete-char # Backspace
bindkey -M viins "↰" accept-line          # Shift-Enter works as Enter

# Beginning of line
bindkey -M viins "[H" beginning-of-line # Home
bindkey -M vicmd "[H" beginning-of-line # Home
bindkey -M vicmd "H" beginning-of-line
# End of line
bindkey -M viins "[F" end-of-line # End
bindkey -M vicmd "[F" end-of-line # End
bindkey -M vicmd "L" end-of-line

# Switching mode with CAPS LOCK
bindkey -M viins "⇪" vi-cmd-mode
bindkey -M vicmd "⇪" vi-insert
# As well as the classic Esc and i
bindkey -M viins "" vi-cmd-mode
bindkey -M vicmd "i" vi-insert

# Vim cursor {{{
function _cursor-cmd() {
	print -n '\e]12;#D70000\a'
}
function _cursor-ins() {
	print -n '\e]12;#AF8700\a'
}
function zle-line-finish {
	_cursor-ins
}
zle -N zle-line-finish
function zle-keymap-select() {
	if [[ $KEYMAP = 'vicmd' ]]; then
		_cursor-cmd
	else
		_cursor-ins
	fi
}
zle -N zle-keymap-select
zle-line-init() {
	zle vi-insert
	_cursor-ins
}
zle -N zle-line-init
