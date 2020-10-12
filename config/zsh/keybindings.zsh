local DEBUG_STARTTIME=$(($(date +%s%N)/1000000))

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
bindkey -s '^J' ' ls^M'

# Ctrl-K to see git status
bindkey -s '^K' ' vdl^M'

# Ctrl-S to commit all
bindkey -s '^S' ' vca^M'

# Ctrl-H to go up one dir
bindkey -s '^H' ' cd ..^M'

# Ctrl-P fuzzy finding {{{
if [[ -r ~/.fzf.zsh ]]; then
  source ~/.fzf.zsh
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
 
# Switching mode with CAPS LOCK
# F15 is mapped to ([28~) in termite/alacritty, but [1;2R in kitty
bindkey -M viins "[28~" vi-cmd-mode
bindkey -M viins "[1;2R" vi-cmd-mode
bindkey -M vicmd "[28~" vi-insert
bindkey -M vicmd "[1;2R" vi-insert
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

local DEBUG_ENDTIME=$(($(date +%s%N)/1000000))
[[ $ZSH_DEBUG == 1 ]] && echo "[debug]: ${0}: $(($DEBUG_ENDTIME - $DEBUG_STARTTIME))ms"
