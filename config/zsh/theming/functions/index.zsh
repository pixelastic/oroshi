function () {
  # Stop loading the file if it has already been sourced once
  [[ $OROSHI_FUNCTIONS_LOADED == '1' ]] && return

  require 'theming/functions/colorize-project.zsh'
  require 'theming/functions/colorize.zsh'
  require 'theming/functions/project-by-path.zsh'

  OROSHI_FUNCTIONS_LOADED='1'
}
