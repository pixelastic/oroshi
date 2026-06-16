# Shift-Enter to add a new line
oroshi-shift-enter-widget() {
  local newline=$'\n'
  LBUFFER="${LBUFFER}${newline}"
}
zle -N oroshi-shift-enter-widget
bindkey '⏎' oroshi-shift-enter-widget
