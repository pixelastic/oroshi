# Enabling vim mode
bindkey -v

# Switching mode with CAPS LOCK
bindkey -M viins "[25~" vi-cmd-mode
bindkey -M vicmd "[25~" vi-insert
# As well as the classic Esc and i
bindkey -M viins "" vi-cmd-mode
bindkey -M vicmd "i"  vi-insert

# (re)enabling keybindings in insert mode
bindkey -M viins "[3~" delete-char        # Delete
bindkey -M viins "" backward-delete-char  # Backspace
bindkey -M viins "" backward-kill-word    # Ctrl-w
bindkey -M viins "OH"  beginning-of-line  # Home
bindkey -M viins "[5~" beginning-of-line  # Page Up
bindkey -M viins "OF"  end-of-line        # End
bindkey -M viins "[6~" end-of-line        # Page Down

# Backward search
bindkey -M viins "" history-incremental-search-backward
bindkey -M vicmd "" history-incremental-search-backward


# Set the cursor for vi cmd mode
function cursor-cmd() {
	print -n '\e]12;red\a'
}
# Set the cursor for vi insert mode (default)
function cursor-ins() {
	print -n '\e]12;#AF8700\a'
}
# Set insert mode by default for new lines
function zle-line-init {
	zle vi-insert
	cursor-ins
}
# Force the cursor to its default (ins) color when finishing a line
function zle-line-finish {
	cursor-ins
}
# Change cursor color based on current mode
function zle-keymap-select () {
	if [[ $KEYMAP = 'vicmd' ]]; then
		cursor-cmd
	else
		cursor-ins
	fi
}
zle -N zle-line-init
zle -N zle-line-finish
zle -N zle-keymap-select





