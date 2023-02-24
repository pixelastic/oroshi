# Add all suggestions to the command line
#
# I have no idea how it works, but it does
zle -C all-matches complete-word _generic
bindkey '^a' all-matches
zstyle ':completion:all-matches:*' old-matches only
zstyle ':completion:all-matches:*' completer _all_matches

