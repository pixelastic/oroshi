
# Python {{{
# Note: Currently unused
function oroshi_prompt_python() {
  # # In a global pyenv environment
  # [[ ! $PYENV_VERSION == "" ]] && display=" $PYENV_VERSION "
  # # In a local pipenv shell (the [] help remember to press Ctrl-D to get out)
  # [[ $PIPENV_ACTIVE == "1" ]] && display="[ $(python-version)] "

  # if [[ $display == '' ]]; then
  #   return
  # fi
  # echo "$FG[green9]${display}%f"
}
# }}}
