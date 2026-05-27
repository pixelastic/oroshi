# Ctrl-Shift-C copies last command + output to clipboard
oroshi-copy-last-command-output-widget() {
  # Get last command from history
  local lastCommand=$(fc -ln -1)

  # Get last command output from Kitty terminal buffer
  local commandOutput=$(kitty@ get-text --extent last_cmd_output 2>/dev/null)

  local finalOutput="$PWD $ $lastCommand\n$commandOutput"
  clipboard-write "${finalOutput}"

  zle reset-prompt
  return 0
}
zle -N oroshi-copy-last-command-output-widget
bindkey 'Ⓨ' oroshi-copy-last-command-output-widget
