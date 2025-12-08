# Highlighting as I type {{{
source $ZSH_CONFIG_PATH/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# Documentation:
# https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/main.md
# https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/highlighters/main/main-highlighter.zsh
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main)

typeset -A ZSH_HIGHLIGHT_STYLES=(
  # Fallback color
  'default' "fg=$COLOR_ALIAS_TEXT"

  # Methods
  'alias' "fg=$COLOR_ALIAS_FUNCTION"
  'global-alias' "fg=$COLOR_ALIAS_FUNCTION"
  'builtin' "fg=$COLOR_ALIAS_FUNCTION"
  'command' "fg=$COLOR_ALIAS_FUNCTION"
  'function' "fg=$COLOR_ALIAS_FUNCTION"
  'reserved-word' "fg=$COLOR_ALIAS_FUNCTION"

  # Arguments
  'double-hyphen-option' "fg=$COLOR_ALIAS_FLAG"
  'single-hyphen-option' "fg=$COLOR_ALIAS_FLAG"

  # Variables
  'dollar-double-quoted-argument' "fg=$COLOR_ALIAS_INTERPOLATION_VARIABLE"
  'assign' "fg=$COLOR_ALIAS_INTERPOLATION_VARIABLE"
  'comment' "fg=$COLOR_ALIAS_INTERPOLATION_VARIABLE" # $i in "for i in ./*; echo $i; done"

  # $() interpolation
  'command-substitution' "fg=$COLOR_ALIAS_INTERPOLATION_WRAPPER"
  'command-substitution-delimiter' "fg=$COLOR_ALIAS_INTERPOLATION_WRAPPER"

  # Punctuation
  'back-double-quoted-argument' "fg=$COLOR_ALIAS_PUNCTUATION"
  'commandseparator' "fg=$COLOR_ALIAS_PUNCTUATION"

  # Path
  'path' "fg=$COLOR_ALIAS_DIRECTORY"                      # Existing path
  'path_pathseparator' "fg=$COLOR_ALIAS_DIRECTORY"        # / in existing path
  'path_prefix' "fg=$COLOR_ALIAS_DIRECTORY"               # Incomplete path
  'path_prefix_pathseparator' "fg=$COLOR_ALIAS_DIRECTORY" # / in incomplete path
  'autodirectory' "fg=$COLOR_ALIAS_DIRECTORY"

  # Glob
  'globbing' "fg=$COLOR_ALIAS_GLOB"

  # Strings (blue)
  'back-quoted-argument' "fg=$COLOR_ALIAS_STRING"
  'back-quoted-argument-unclosed' "bg=$COLOR_ALIAS_STRING,fg=$COLOR_BLACK"
  'back-quoted-argument-delimiter' "fg=$COLOR_ALIAS_STRING"
  'double-quoted-argument' "fg=$COLOR_ALIAS_STRING"
  'double-quoted-argument-unclosed' "bg=$COLOR_ALIAS_STRING,fg=$COLOR_BLACK"
  'single-quoted-argument' "fg=$COLOR_ALIAS_STRING"
  'single-quoted-argument-unclosed' "bg=$COLOR_ALIAS_STRING,fg=$COLOR_BLACK"

  # Numbers (bold blue)
  'arithmetic-expansion' "fg=$COLOR_ALIAS_NUMBER"

  # Repetition of last command using !
  'history-expansion' "fg=$COLOR_NEUTRAL"

  # Errors
  'unknown-token' "fg=$COLOR_ALIAS_ERROR"

  # sudo
  'precommand' "fg=$COLOR_ALIAS_WARNING,bold"

  # &>, 1>, 2> redirection
  'redirection' "fg=$COLOR_ALIAS_SYMBOL"

  # ???
  'arg0' "bg=$COLOR_ALIAS_UNKNOWN"
  'arithmetic-expansion' "bg=$COLOR_ALIAS_UNKNOWN"
  'back-dollar-quoted-argument' "bg=$COLOR_ALIAS_UNKNOWN"
  'bracket-error' "bg=$COLOR_ALIAS_UNKNOWN"
  'bracket-level-1' "bg=$COLOR_ALIAS_UNKNOWN"
  'bracket-level-2' "bg=$COLOR_ALIAS_UNKNOWN"
  'bracket-level-3' "bg=$COLOR_ALIAS_UNKNOWN"
  'bracket-level-4' "bg=$COLOR_ALIAS_UNKNOWN"
  'bracket-level-5' "bg=$COLOR_ALIAS_UNKNOWN"
  'cursor' "bg=$COLOR_ALIAS_UNKNOWN"
  'cursor-matchingbracket' "bg=$COLOR_ALIAS_UNKNOWN"
  'dollar-quoted-argument' "bg=$COLOR_ALIAS_UNKNOWN"
  'hashed-command' "bg=$COLOR_ALIAS_UNKNOWN"
  'line' "bg=$COLOR_ALIAS_UNKNOWN"
  'named-fd' "bg=$COLOR_ALIAS_UNKNOWN"
  'numeric-fd' "bg=$COLOR_ALIAS_UNKNOWN"
  'path_approx' "bg=$COLOR_ALIAS_UNKNOWN"
  'process-substitution' "bg=$COLOR_ALIAS_UNKNOWN"
  'process-substitution-delimiter' "bg=$COLOR_ALIAS_UNKNOWN"
  'rc-quote' "bg=$COLOR_ALIAS_UNKNOWN"
  'root' "bg=$COLOR_ALIAS_UNKNOWN"
  'suffix-alias' "bg=$COLOR_ALIAS_UNKNOWN"
)
