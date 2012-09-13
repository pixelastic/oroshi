# Disable default terminal flow control through Ctrl+S/Ctrl+Q so it can be used
# as mapping (like in vim)
stty ixoff -ixon

# Extended F keys (F13-F20) seems mapped to ~ by default. We clear that so it
# won't interfere with our mappings 
bindkey -s "[25~" ""
bindkey -s "[26~" ""
bindkey -s "[27~" ""
bindkey -s "[28~" ""
bindkey -s "[29~" ""
bindkey -s "[30~" ""
bindkey -s "[31~" ""
bindkey -s "[32~" ""
bindkey -s "[33~" ""

# Prevent Page Up/Down to display a tilde
bindkey -s "[5~" ""
bindkey -s "[6~" ""
