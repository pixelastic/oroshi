# Disable default terminal flow control through Ctrl+S/Ctrl+Q so it can be used
# as mapping (like in vim)
stty ixoff -ixon

# Start and end of line
bindkey "OH"  beginning-of-line  # Home
bindkey "[5~" beginning-of-line  # Page Up
bindkey "OF"  end-of-line        # End
bindkey "[6~" end-of-line        # Page Down

# Making sure the delete key works
bindkey "[3~" delete-char

# Disabling some special keys
bindkey -s "[26~" "" # Square (F14)

# Enabling vim mode
bindkey -v
# Switching mode with CAPS LOCK
bindkey -M viins "[25~" vi-cmd-mode
