# Disable default terminal flow control through Ctrl+S/Ctrl+Q so it can be used
# as mapping (like in vim)
stty ixoff -ixon

# Enabling vim mode
bindkey -v

# Ctrl-O to go to ~/.oroshi/
bindkey -s '^O' '^U cdo^M'
# Ctrl-K to ls
bindkey -s '^K' '^U ls^M'
# Ctrl-S to git status
bindkey -s '^S' '^U vdl^M'
# Ctrl-B to git branch
bindkey -s '^B' '^U vbl^M'
# Ctrl-J copy previous word
bindkey "^J" copy-prev-shell-word
# Ctrl-V to edit the line in Vim
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^V' edit-command-line
# Ctrl-P for fuzzy finding
export FZF_COMPLETION_TRIGGER=''
bindkey '^P' fzf-completion
bindkey '^I' $fzf_default_completion

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
# Switching mode with CAPS LOCK
bindkey -M viins "[25~" vi-cmd-mode
bindkey -M vicmd "[25~" vi-insert
# As well as the classic Esc and i
bindkey -M viins "" vi-cmd-mode
bindkey -M vicmd "i"  vi-insert

# Move on line
bindkey -M vicmd "" beginning-of-line
bindkey -M vicmd "" end-of-line


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
