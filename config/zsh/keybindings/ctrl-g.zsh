# Ctrl-G search into files
oroshi-fzf-search-in-files-widget() {
  export PROMPT_PREVENT_REFRESH="1"
  local selection="$(fzf-search-in-files)"
  export PROMPT_PREVENT_REFRESH="0"

  # Stop if no selection is made
  if [[ "$selection" == "" ]]; then
    zle reset-prompt
    return 1
  fi

  # Find file and line number
  local split=(${=selection})
  local filepath=${split[1]:a}
  local lineNumber=$split[2]

  # Open it in vim
  nvim "$filepath" +$lineNumber
  return 0
}
zle -N oroshi-fzf-search-in-files-widget
bindkey '^G' oroshi-fzf-search-in-files-widget
