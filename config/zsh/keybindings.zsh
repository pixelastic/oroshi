# Disable default terminal flow control through Ctrl+S/Ctrl+Q so it can be used
# as mapping (like in vim)
stty ixoff -ixon

# Enabling vim mode
bindkey -v
 
# Ctrl-O to go to ~/.oroshi/
bindkey -s '^O' '^U cdo^M'
# Ctrl-K to ls
bindkey -s '^K' '^U ls^M'
# Ctrl-J to git status
bindkey -s '^J' '^U vdl^M'
# Ctrl-E to edit the line in Vim
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^E' edit-command-line
# Ctrl-P for fuzzy finding
# Use ag for Ctrl-P fuzzy find
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
bindkey '^P' fzf-file-widget
 
# (re)enabling keybindings
# Note: press Ctrl-V followed by a key to see its keycode
bindkey -M viins "[3~" delete-char        # Delete
bindkey -M viins ""    backward-delete-char  # Backspace

# Beginning of line
bindkey -M viins "[1~" beginning-of-line  # Home (in termite)
bindkey -M viins "OH"  beginning-of-line  # Home (in terminator)
bindkey -M viins "[5~" beginning-of-line  # Page Up
bindkey -M vicmd "H"     beginning-of-line
bindkey -M vicmd "[1~" beginning-of-line  # Home (in termite)
bindkey -M vicmd "OH"  beginning-of-line  # Home (in terminator)
bindkey -M vicmd "[5~" beginning-of-line  # Page Up
# End of line
bindkey -M viins "[4~" end-of-line        # End (in termite)
bindkey -M viins "OF"  end-of-line        # End (in terminator)
bindkey -M viins "[6~" end-of-line        # Page Down
bindkey -M vicmd "L"     end-of-line
bindkey -M vicmd "[4~" end-of-line        # End (in termite)
bindkey -M vicmd "OF"  end-of-line        # End (in terminator)
bindkey -M vicmd "[6~" end-of-line        # Page Down
 
# Backward search
bindkey -M viins "" history-incremental-search-backward
bindkey -M vicmd "" history-incremental-search-backward
# Switching mode with CAPS LOCK
bindkey -M viins "[25~" vi-cmd-mode
bindkey -M vicmd "[25~" vi-insert
# As well as the classic Esc and i
bindkey -M viins "" vi-cmd-mode
bindkey -M vicmd "i"  vi-insert
 
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
function zle-keymap-select () {
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
# }}}
