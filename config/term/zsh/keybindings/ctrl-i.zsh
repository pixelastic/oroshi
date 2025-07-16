# Ctrl-i opens an AI chat window
oroshi-ai() {
  # export PROMPT_PREVENT_REFRESH="1"

  echo ""
  claude "${LBUFFER}"
  # export PROMPT_PREVENT_REFRESH="0"

  zle reset-prompt
  return 0

  # LBUFFER="${LBUFFER}same command "
  # return 0
}
zle -N oroshi-ai
bindkey '⒤' oroshi-ai
# }}}
