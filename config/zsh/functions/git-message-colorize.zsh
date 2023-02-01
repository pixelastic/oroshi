# Displays a colorized version of a commit message
# Usage:
# $ git-message-colorize "fix stuff"                  # fix stuff
# $ git-message-colorize "fix stuff" --with-icon      #  fix stuff
function git-message-colorize() {

  # Filter positional arguments and flags
  local argsp=()
  local -A argsf; argsf=()
  for arg in $argv; do
    [[ "$arg" =~ "^-" ]] && argsf[$arg]=1 || argsp+="$arg"
  done

  # Message {{{
  local message="$argsp[1]"
  # We need a message passed
  if [[ $message == '' ]]; then
    return 0
  fi
  # }}}

  # If --with-icon is not passed, we simply display the colored message
  if [[ "$argsf[--with-icon]" != 1 ]]; then
    colorize "$message" ALIAS_GIT_MESSAGE
    return
  fi

  # Otherwise we add the icon
  colorize " $message" ALIAS_GIT_MESSAGE
  return
}
