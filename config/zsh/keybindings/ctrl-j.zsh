# Ctrl-J fuzzy find in common directories
oroshi-ctrl-j-widget() {
  BUFFER="cd $(fzf-directories-common)"
  zle accept-line
  zle reset-prompt
  return 0
}
zle -N oroshi-ctrl-j-widget
bindkey '^J' oroshi-ctrl-j-widget
