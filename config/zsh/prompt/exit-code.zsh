# Exit code
# Display a color-coded prompt character based on the last command exit code:
# - Green if success
# - Red if error
# - Purple if any other error code
function __prompt-exit-code() {
  # Quick display: green symbol
  if [[ $OROSHI_PROMPT_ENHANCED_MODE == "0" ]]; then
    echo -n "%F{$COLOR_ALIAS_SUCCESS}❯ %f"
    return
  fi

  local exit=$OROSHI_LAST_COMMAND_EXIT
  [[ $exit = 1 ]] && echo -n "%B%F{$COLOR_ALIAS_ERROR}❯ %f%b" && return
  [[ $exit > 1 ]] && echo -n "%F{$COLOR_ALIAS_NOTICE}❯ %f" && return
  echo -n "%F{$COLOR_ALIAS_SUCCESS}❯ %f"
}
# }}}
