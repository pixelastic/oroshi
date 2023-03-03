# Ctrl-A selects all suggestions, and add them to the current line
#
# Note: I have no idea how it works, but it does
zle -C all-matches complete-word _generic
bindkey '^a' all-matches
zstyle ':completion:all-matches:*' old-matches only
zstyle ':completion:all-matches:*' completer _all_matches

