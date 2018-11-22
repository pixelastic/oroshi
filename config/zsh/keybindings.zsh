# Disable default terminal flow control through Ctrl+S/Ctrl+Q so it can be used
# as mapping (like in vim)
stty ixoff -ixon

# Enabling vim mode
bindkey -v
 
# Ctrl-E to edit the line in Vim
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^E' edit-command-line

# Ctrl-J to run ls
bindkey -s '^J' ' ls'

# Ctrl-K to see git status
bindkey -s '^K' ' vdl'

# Ctrl-S to commit all
bindkey -s '^S' ' vca'

# Ctrl-H to go up one dir
bindkey -s '^H' ' cd ..'



# Ctrl-P fuzzy finding {{{
if [[ -r ~/.fzf.zsh ]]; then
  source ~/.fzf.zsh
  export FZF_DEFAULT_OPTS="
    --color fg:249,bg:233,hl:203,fg+:234,bg+:203,hl+:255
    --color info:136,prompt:203,pointer:233
   "
  export FZF_DEFAULT_COMMAND='fd --type file --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  bindkey '^P' fzf-file-widget
fi
# }}}
 
# (re)enabling keybindings
# Note: press Ctrl-V followed by a key to see its keycode
bindkey -M viins "[3~" delete-char        # Delete
bindkey -M viins ""    backward-delete-char  # Backspace
bindkey -M viins "O2M" accept-line # Shift-Enter works as Enter

# Beginning of line
bindkey -M viins "[1~" beginning-of-line  # Home (in termite)
bindkey -M viins "[5~" beginning-of-line  # Page Up
bindkey -M vicmd "H"     beginning-of-line
bindkey -M vicmd "[1~" beginning-of-line  # Home (in termite)
bindkey -M vicmd "[5~" beginning-of-line  # Page Up
# End of line
bindkey -M viins "[4~" end-of-line        # End (in termite)
bindkey -M viins "[6~" end-of-line        # Page Down
bindkey -M vicmd "L"     end-of-line
bindkey -M vicmd "[4~" end-of-line        # End (in termite)
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
