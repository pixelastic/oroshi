# Enabling vim mode
bindkey -v
# Note: press Ctrl-V followed by a key to see its keycode
bindkey -M viins "[3~" delete-char       # Delete
bindkey -M viins "" backward-delete-char # Backspace
bindkey -M viins "O2M" accept-line       # Shift-Enter works as Enter

# Beginning of line
bindkey -M viins "[1~" beginning-of-line # Home (in termite)
bindkey -M viins "[5~" beginning-of-line # Page Up
bindkey -M vicmd "H" beginning-of-line
bindkey -M vicmd "[1~" beginning-of-line # Home (in termite)
bindkey -M vicmd "[5~" beginning-of-line # Page Up
# End of line
bindkey -M viins "[4~" end-of-line # End (in termite)
bindkey -M viins "[6~" end-of-line # Page Down
bindkey -M vicmd "L" end-of-line
bindkey -M vicmd "[4~" end-of-line # End (in termite)
bindkey -M vicmd "[6~" end-of-line # Page Down

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
