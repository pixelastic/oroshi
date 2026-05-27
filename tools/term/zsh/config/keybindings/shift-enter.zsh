# Shift-Enter to add a new line
oroshi-new-line() {
  local newline=$'\n'
  LBUFFER="${LBUFFER}${newline}"
}
zle -N oroshi-new-line
bindkey '⏎' oroshi-new-line
